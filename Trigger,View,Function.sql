-- ------------------------Triggers-----------------------------------------------------
-- Trigger to update restaurant rating when a new review is added
DELIMITER //
CREATE TRIGGER after_restaurant_review_insert
AFTER INSERT ON RestaurantReviews
FOR EACH ROW
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    
    SELECT AVG(rating) INTO avg_rating
    FROM RestaurantReviews
    WHERE restaurant_id = NEW.restaurant_id;
    
    UPDATE Restaurants
    SET rating = avg_rating
    WHERE restaurant_id = NEW.restaurant_id;
END //
DELIMITER ;

-- Trigger to update menu item rating when a new review is added
DELIMITER //
CREATE TRIGGER after_menu_item_review_insert
AFTER INSERT ON MenuItemReviews
FOR EACH ROW
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    
    SELECT AVG(rating) INTO avg_rating
    FROM MenuItemReviews
    WHERE item_id = NEW.item_id;
    
    UPDATE MenuItems
    SET rating = avg_rating
    WHERE item_id = NEW.item_id;
END //
DELIMITER ;

-- Trigger to update customer tier based on royalty points
DELIMITER //
CREATE TRIGGER before_customer_update
BEFORE UPDATE ON Customers
FOR EACH ROW
BEGIN
    -- Update tier based on royalty points
    IF NEW.royalty_points >= 1000 THEN
        SET NEW.tier = 'Platinum';
    ELSEIF NEW.royalty_points >= 500 THEN
        SET NEW.tier = 'Gold';
    ELSEIF NEW.royalty_points >= 100 THEN
        SET NEW.tier = 'Silver';
    ELSE
        SET NEW.tier = 'Bronze';
    END IF;
END //
DELIMITER ;

-- Trigger to add royalty points when an order is completed
DELIMITER //
CREATE TRIGGER after_order_completed
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    DECLARE customer_id_val INT;
    
    -- Check if status changed to Completed
    IF NEW.status = 'Completed' AND OLD.status != 'Completed' THEN
        -- Get customer ID
        SET customer_id_val = NEW.customer_id;
        
        -- Add royalty points (1 point for every 10 currency units)
        UPDATE Customers
        SET royalty_points = royalty_points + FLOOR(NEW.total_amount / 10)
        WHERE customer_id = customer_id_val;
    END IF;
END //
DELIMITER ;
-- ----------------------------------------------------------------------------------
-- ------------------------Views-----------------------------------------------------
-- ----------------------------------------------------------------------------------
-- View for active restaurants with their ratings
CREATE VIEW ActiveRestaurantsWithRatings AS
SELECT r.restaurant_id, r.name, r.location, r.contact, r.rating, u.name AS owner_name
FROM Restaurants r
JOIN RestaurantOwners ro ON r.owner_id = ro.owner_id
JOIN Users u ON ro.user_id = u.user_id
WHERE r.is_active = TRUE
ORDER BY r.rating DESC;

-- View for available menu items with their ratings
CREATE VIEW AvailableMenuItems AS
SELECT mi.item_id, mi.name, mi.description, mi.price, mi.rating, 
       r.name AS restaurant_name, mc.name AS category_name
FROM MenuItems mi
JOIN Restaurants r ON mi.restaurant_id = r.restaurant_id
LEFT JOIN MenuCategories mc ON mi.category_id = mc.category_id
WHERE mi.is_available = TRUE AND r.is_active = TRUE
ORDER BY mi.rating DESC;

-- View for order details
CREATE VIEW OrderDetails AS
SELECT o.order_id, c.customer_id, u.name AS customer_name, 
       res.restaurant_id, res.name AS restaurant_name,
       o.order_date, o.status, o.delivery_status, o.total_amount,
       da.agent_id, ua.name AS delivery_agent_name,
       p.payment_method, p.status AS payment_status
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
JOIN Restaurants res ON o.restaurant_id = res.restaurant_id
LEFT JOIN DeliveryAgents da ON o.delivery_agent_id = da.agent_id
LEFT JOIN Users ua ON da.user_id = ua.user_id
LEFT JOIN Payments p ON o.order_id = p.order_id;

-- View for delivery agent performance
CREATE VIEW DeliveryAgentPerformance AS
SELECT da.agent_id, u.name AS agent_name, da.status AS agent_status,
       COUNT(o.order_id) AS total_deliveries,
       SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) AS successful_deliveries,
       AVG(o.total_amount) AS avg_order_value
FROM DeliveryAgents da
JOIN Users u ON da.user_id = u.user_id
LEFT JOIN Orders o ON da.agent_id = o.delivery_agent_id
GROUP BY da.agent_id, u.name, da.status;

-- ----------------------------------------------------------------------------------
-- ------------------------Functions-------------------------------------------------
-- ----------------------------------------------------------------------------------
-- Function to calculate delivery time estimate
DELIMITER //
CREATE FUNCTION CalculateDeliveryEstimate(p_order_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE distance_km INT;
    DECLARE estimate_minutes INT;
    
    -- In a real system, you would calculate actual distance
    -- Here we're using a simple estimate based on order value
    SELECT 
        CASE 
            WHEN total_amount < 20 THEN 45
            WHEN total_amount < 50 THEN 35
            ELSE 25
        END INTO estimate_minutes
    FROM Orders 
    WHERE order_id = p_order_id;
    
    RETURN estimate_minutes;
END //
DELIMITER ;

-- Usage:
SELECT CalculateDeliveryEstimate(1) AS delivery_estimate_minutes;

-- Function to check if restaurant is open
DELIMITER //
CREATE FUNCTION IsRestaurantOpen(p_restaurant_id INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE is_open BOOLEAN;
    DECLARE current_hour INT;
    
    SET current_hour = HOUR(CURRENT_TIME());
    
    -- Simple check - assuming restaurants are open 10AM-10PM
    SELECT is_active AND current_hour BETWEEN 10 AND 22 INTO is_open
    FROM Restaurants
    WHERE restaurant_id = p_restaurant_id;
    
    RETURN is_open;
END //
DELIMITER ;

-- Usage:
-- SELECT IsRestaurantOpen(1) AS is_restaurant_open;