-- PlaceOrder procedure
DELIMITER //
CREATE PROCEDURE PlaceOrder(
    IN p_customer_id INT,
    IN p_restaurant_id INT,
    IN p_delivery_address VARCHAR(255)
)
BEGIN
    DECLARE order_id_val INT;
    
    -- Create the order
    INSERT INTO Orders (customer_id, restaurant_id, delivery_address, status)
    VALUES (p_customer_id, p_restaurant_id, p_delivery_address, 'Placed');
    
    SET order_id_val = LAST_INSERT_ID();
    
    SELECT CONCAT('Order placed successfully. Order ID: ', order_id_val, 
                 '. Now you can add items to your order.') AS message,
           order_id_val AS order_id;
END //
DELIMITER ;

-- AddOrderItem procedure
DELIMITER //
CREATE PROCEDURE AddOrderItem(
    IN p_order_id INT,
    IN p_item_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE item_price DECIMAL(10,2);
    DECLARE order_status VARCHAR(20);
    DECLARE total_amount_val DECIMAL(10,2);
    
    -- Check if order can be modified
    SELECT status INTO order_status FROM Orders WHERE order_id = p_order_id;
    
    IF order_status != 'Placed' AND order_status != 'Pending' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot add items to an order that is not in Placed or Pending status';
    END IF;
    
    -- Get item price
    SELECT price INTO item_price FROM MenuItems WHERE item_id = p_item_id;
    
    -- Add item to order
    INSERT INTO OrderItems (order_id, item_id, quantity, price_at_order)
    VALUES (p_order_id, p_item_id, p_quantity, item_price);
    
    -- Update order total amount
    SELECT SUM(price_at_order * quantity) INTO total_amount_val 
    FROM OrderItems 
    WHERE order_id = p_order_id;
    
    UPDATE Orders 
    SET total_amount = total_amount_val,
        status = 'Pending'
    WHERE order_id = p_order_id;
    
    SELECT CONCAT('Item added to order successfully. Current order total: ', total_amount_val,
                 '. You can add more items or proceed to payment.') AS message,
           p_order_id AS order_id,
           total_amount_val AS total_amount;
END //
DELIMITER ;

-- RemoveOrderItem procedure
DELIMITER //
CREATE PROCEDURE RemoveOrderItem(
    IN p_order_item_id INT
)
BEGIN
    DECLARE order_id_val INT;
    DECLARE item_price DECIMAL(10,2);
    DECLARE item_quantity INT;
    DECLARE refund_amount DECIMAL(10,2);
    DECLARE order_status VARCHAR(20);
    DECLARE total_amount_val DECIMAL(10,2);
    
    -- Get order item details
    SELECT order_id, price_at_order, quantity 
    INTO order_id_val, item_price, item_quantity
    FROM OrderItems 
    WHERE order_item_id = p_order_item_id;
    
    -- Check if order can be modified
    SELECT status INTO order_status FROM Orders WHERE order_id = order_id_val;
    
    IF order_status != 'Placed' AND order_status != 'Pending' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot remove items from an order that is not in Placed or Pending status';
    END IF;
    
    -- Calculate refund amount
    SET refund_amount = item_price * item_quantity;
    
    -- Remove the item
    DELETE FROM OrderItems WHERE order_item_id = p_order_item_id;
    
    -- Update order total amount
    SELECT SUM(price_at_order * quantity) INTO total_amount_val 
    FROM OrderItems 
    WHERE order_id = order_id_val;
    
    UPDATE Orders 
    SET total_amount = IFNULL(total_amount_val, 0)
    WHERE order_id = order_id_val;
    
    SELECT CONCAT('Item removed from order. Refunded amount: ', refund_amount) AS message,
           order_id_val AS order_id,
           refund_amount AS refund_amount,
           IFNULL(total_amount_val, 0) AS new_total_amount;
END //
DELIMITER ;

-- UpdateOrderStatus procedure
DELIMITER //
CREATE PROCEDURE UpdateOrderStatus(
    IN p_order_id INT,
    IN p_status VARCHAR(20)
)
BEGIN
    DECLARE current_status VARCHAR(20);
    DECLARE current_delivery_status VARCHAR(20);
    
    -- Get current status
    SELECT status, delivery_status INTO current_status, current_delivery_status
    FROM Orders WHERE order_id = p_order_id;
    
    -- Validate status transition
    IF current_status = 'Completed' AND p_status != 'Completed' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot change status from Completed';
    ELSEIF current_status = 'Cancelled' AND p_status != 'Cancelled' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot change status from Cancelled';
    END IF;
    
    -- Update status
    UPDATE Orders 
    SET status = p_status
    WHERE order_id = p_order_id;
    
    -- If status is Preparing, set delivery status to Preparing
    IF p_status = 'Preparing' THEN
        UPDATE Orders 
        SET delivery_status = 'Preparing'
        WHERE order_id = p_order_id;
    END IF;
    
    SELECT CONCAT('Order status updated to ', p_status) AS message,
           p_order_id AS order_id;
END //
DELIMITER ;

-- CancelOrder procedure
DELIMITER //
CREATE PROCEDURE CancelOrder(
    IN p_order_id INT
)
BEGIN
    DECLARE order_status VARCHAR(20);
    DECLARE order_amount DECIMAL(10,2);
    DECLARE payment_status VARCHAR(20);
    DECLARE payment_id_val INT;
    DECLARE agent_id_val INT;
    DECLARE refund_id_val INT;
    
    -- Get order details
    SELECT o.status, o.total_amount, o.delivery_agent_id, 
           p.payment_id, p.status
    INTO order_status, order_amount, agent_id_val, 
         payment_id_val, payment_status
    FROM Orders o
    LEFT JOIN Payments p ON o.order_id = p.order_id AND p.status = 'Completed'
    WHERE o.order_id = p_order_id;
    
    -- Check if order can be cancelled
    IF order_status = 'Completed' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot cancel a completed order';
    ELSEIF order_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Order is already cancelled';
    END IF;
    
    -- Update order status
    UPDATE Orders 
    SET status = 'Cancelled',
        delivery_status = 'Preparing'
    WHERE order_id = p_order_id;
    
    -- Update delivery agent status if assigned
    IF agent_id_val IS NOT NULL THEN
        UPDATE DeliveryAgents 
        SET status = 'Active'
        WHERE agent_id = agent_id_val;
    END IF;
    
    -- Process refund if payment was made
    IF payment_id_val IS NOT NULL THEN
        -- Create refund record
        INSERT INTO Refunds (payment_id, amount, status)
        VALUES (payment_id_val, order_amount, 'Completed');
        
        SET refund_id_val = LAST_INSERT_ID();
        
        -- Update payment status
        UPDATE Payments 
        SET status = 'Refunded'
        WHERE payment_id = payment_id_val;
        
        -- Automatically process the refund
        CALL ProcessRefund(refund_id_val);
        
        SELECT CONCAT('Order cancelled successfully. Refund of ', order_amount, 
                     ' processed. Refund ID: ', refund_id_val) AS message,
               p_order_id AS order_id,
               order_amount AS refund_amount,
               refund_id_val AS refund_id;
    ELSE
        SELECT CONCAT('Order cancelled successfully. No payment was made.') AS message,
               p_order_id AS order_id;
    END IF;
END //
DELIMITER ;

-- CancelOrderedItem procedure
DELIMITER //
CREATE PROCEDURE CancelOrderedItem(
    IN p_order_item_id INT
)
BEGIN
    DECLARE order_id_val INT;
    DECLARE item_price DECIMAL(10,2);
    DECLARE item_quantity INT;
    DECLARE refund_amount DECIMAL(10,2);
    DECLARE order_status VARCHAR(20);
    DECLARE payment_status VARCHAR(20);
    DECLARE payment_id_val INT;
    DECLARE agent_id_val INT;
    DECLARE total_amount_val DECIMAL(10,2);
    DECLARE refund_id_val INT;
    
    -- Get order item details
    SELECT oi.order_id, oi.price_at_order, oi.quantity, o.status, 
           o.delivery_agent_id, p.payment_id, p.status
    INTO order_id_val, item_price, item_quantity, order_status,
         agent_id_val, payment_id_val, payment_status
    FROM OrderItems oi
    JOIN Orders o ON oi.order_id = o.order_id
    LEFT JOIN Payments p ON o.order_id = p.order_id AND p.status = 'Completed'
    WHERE oi.order_item_id = p_order_item_id;
    
    -- Check if order can be modified
    IF order_status = 'Completed' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot cancel items from a completed order';
    ELSEIF order_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Order is already cancelled';
    END IF;
    
    -- Calculate refund amount
    SET refund_amount = item_price * item_quantity;
    
    -- Remove the item
    DELETE FROM OrderItems WHERE order_item_id = p_order_item_id;
    
    -- Update order total amount
    SELECT SUM(price_at_order * quantity) INTO total_amount_val 
    FROM OrderItems 
    WHERE order_id = order_id_val;
    
    UPDATE Orders 
    SET total_amount = IFNULL(total_amount_val, 0)
    WHERE order_id = order_id_val;
    
    -- Update delivery agent status if order becomes empty
    IF IFNULL(total_amount_val, 0) = 0 AND agent_id_val IS NOT NULL THEN
        UPDATE DeliveryAgents 
        SET status = 'Active'
        WHERE agent_id = agent_id_val;
    END IF;
    
    -- Process refund if payment was made
    IF payment_id_val IS NOT NULL THEN
        -- Create refund record
        INSERT INTO Refunds (payment_id, amount, status, reason)
        VALUES (payment_id_val, refund_amount, 'Completed', 'Item cancellation');
        
        SET refund_id_val = LAST_INSERT_ID();
        
        -- Automatically process the refund
        CALL ProcessRefund(refund_id_val);
        
        SELECT CONCAT('Order item cancelled successfully. Refund of ', refund_amount, 
                     ' processed. Refund ID: ', refund_id_val) AS message,
               order_id_val AS order_id,
               refund_amount AS refund_amount,
               IFNULL(total_amount_val, 0) AS new_total_amount,
               refund_id_val AS refund_id;
    ELSE
        SELECT CONCAT('Order item cancelled successfully. Refund of ', refund_amount, 
                     ' will be processed if payment was made.') AS message,
               order_id_val AS order_id,
               refund_amount AS refund_amount,
               IFNULL(total_amount_val, 0) AS new_total_amount;
    END IF;
END //
DELIMITER ;