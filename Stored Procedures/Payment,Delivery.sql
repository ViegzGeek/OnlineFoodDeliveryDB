--  ---------------Payments & Refunds----------------------------
-- MakePayment procedure
DELIMITER //
CREATE PROCEDURE MakePayment(
    IN p_order_id INT,
    IN p_amount DECIMAL(10,2),
    IN p_payment_method VARCHAR(20),
    IN p_transaction_id VARCHAR(100)
)
BEGIN
    DECLARE order_status VARCHAR(20);
    DECLARE order_amount DECIMAL(10,2);
    DECLARE delivery_status VARCHAR(20);
    DECLARE payment_id_val INT;
    DECLARE agent_id_val INT;
    
    -- Get order details
    SELECT status, total_amount, delivery_status 
    INTO order_status, order_amount, delivery_status
    FROM Orders WHERE order_id = p_order_id;
    
    -- Validate order status
    IF order_status != 'Pending' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Payment can only be made for orders in Pending status';
    END IF;
    
    -- Validate amount
    IF p_amount < order_amount THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Payment amount is less than order total';
    END IF;
    
    -- Process payment
    INSERT INTO Payments (order_id, amount, payment_method, transaction_id, status)
    VALUES (p_order_id, p_amount, p_payment_method, p_transaction_id, 'Completed');
    
    SET payment_id_val = LAST_INSERT_ID();
    
    -- Update order status
    UPDATE Orders 
    SET status = 'Preparing',
        delivery_status = 'Preparing'
    WHERE order_id = p_order_id;
    
    -- Assign delivery agent (find first available agent)
    SELECT agent_id INTO agent_id_val
    FROM DeliveryAgents
    WHERE status = 'Active'
    LIMIT 1;
    
    IF agent_id_val IS NOT NULL THEN
        UPDATE Orders 
        SET delivery_agent_id = agent_id_val
        WHERE order_id = p_order_id;
        
        SELECT CONCAT('Payment processed successfully. Payment ID: ', payment_id_val, 
                     '. Order is now being prepared. Delivery agent assigned: ', agent_id_val) AS message,
               payment_id_val AS payment_id,
               agent_id_val AS delivery_agent_id;
    ELSE
        SELECT CONCAT('Payment processed successfully. Payment ID: ', payment_id_val, 
                     '. Order is now being prepared. No available delivery agents at this time.') AS message,
               payment_id_val AS payment_id;
    END IF;
END //
DELIMITER ;

-- ProcessRefund procedure
DELIMITER //
CREATE PROCEDURE ProcessRefund(
    IN p_refund_id INT
)
BEGIN
    DECLARE payment_id_val INT;
    DECLARE refund_amount DECIMAL(10,2);
    DECLARE order_id_val INT;
    
    -- Get refund details
    SELECT payment_id, amount INTO payment_id_val, refund_amount
    FROM Refunds 
    WHERE refund_id = p_refund_id AND status = 'Pending';
    
    IF payment_id_val IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Refund not found or already processed';
    END IF;
    
    -- Get order ID for updating customer points
    SELECT order_id INTO order_id_val
    FROM Payments
    WHERE payment_id = payment_id_val;
    
    -- Mark refund as completed
    UPDATE Refunds 
    SET status = 'Completed',
        refund_date = CURRENT_TIMESTAMP
    WHERE refund_id = p_refund_id;
    
    -- Update payment status
    UPDATE Payments 
    SET status = 'Refunded'
    WHERE payment_id = payment_id_val;
    
    -- Deduct royalty points if this was a customer order
    UPDATE Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    SET c.royalty_points = GREATEST(0, c.royalty_points - FLOOR(refund_amount))
    WHERE o.order_id = order_id_val;
    
    SELECT CONCAT('Refund processed successfully. Amount: ', refund_amount) AS message,
           p_refund_id AS refund_id,
           refund_amount AS refund_amount;
END //
DELIMITER ;
-- ----------------------------------------------------------------------------------
-- ------------------------Delivery Management---------------------------------------
-- ----------------------------------------------------------------------------------

-- AssignDeliveryAgent procedure
DELIMITER //
CREATE PROCEDURE AssignDeliveryAgent(
    IN p_order_id INT,
    IN p_agent_id INT
)
BEGIN
    DECLARE order_status VARCHAR(20);
    DECLARE delivery_status VARCHAR(20);
    DECLARE agent_status VARCHAR(10);
    
    -- Get order details
    SELECT o.status, o.delivery_status, da.status
    INTO order_status, delivery_status, agent_status
    FROM Orders o
    LEFT JOIN DeliveryAgents da ON p_agent_id = da.agent_id
    WHERE o.order_id = p_order_id;
    
    -- Validate order status
    IF order_status != 'Preparing' AND order_status != 'Pending' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot assign agent to an order that is not in Preparing or Pending status';
    END IF;
    
    -- Validate agent status
    IF agent_status != 'Active' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot assign an inactive delivery agent';
    END IF;
    
    -- Assign agent and update status
    UPDATE Orders 
    SET delivery_agent_id = p_agent_id,
        delivery_status = 'OutForDelivery'
    WHERE order_id = p_order_id;
    
    SELECT CONCAT('Delivery agent assigned successfully. Order is now out for delivery.') AS message,
           p_order_id AS order_id,
           p_agent_id AS delivery_agent_id;
END //
DELIMITER ;

-- UpdateDeliveryStatus procedure
DELIMITER //
CREATE PROCEDURE UpdateDeliveryStatus(
    IN p_order_id INT,
    IN p_delivery_status VARCHAR(20)
)
BEGIN
    DECLARE current_status VARCHAR(20);
    DECLARE current_delivery_status VARCHAR(20);
    
    -- Get current status
    SELECT status, delivery_status INTO current_status, current_delivery_status
    FROM Orders WHERE order_id = p_order_id;
    
    -- Validate status transition
    IF current_delivery_status = 'Delivered' AND p_delivery_status != 'Delivered' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot change delivery status from Delivered';
    END IF;
    
    -- Update delivery status
    UPDATE Orders 
    SET delivery_status = p_delivery_status
    WHERE order_id = p_order_id;
    
    -- If delivered, update order status to completed
    IF p_delivery_status = 'Delivered' THEN
        UPDATE Orders 
        SET status = 'Completed'
        WHERE order_id = p_order_id;
    END IF;
    
    SELECT CONCAT('Delivery status updated to ', p_delivery_status) AS message,
           p_order_id AS order_id;
END //
DELIMITER ;
