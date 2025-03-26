--  ---------------User Management----------------------------
-- AddUser procedure
DELIMITER //
CREATE PROCEDURE AddUser(
    IN p_name VARCHAR(100),
    IN p_contact VARCHAR(20),
    IN p_password VARCHAR(255),
    IN p_location VARCHAR(255),
    IN p_user_type VARCHAR(20),
    IN p_royalty_points INT,
    IN p_tier VARCHAR(20),
    IN p_status ENUM('Active', 'Inactive')
)
BEGIN
    DECLARE user_id_val INT;
    
    -- Insert into Users table
    INSERT INTO Users (name, contact, password, location, user_type)
    VALUES (p_name, p_contact, p_password, p_location, p_user_type);
    
    SET user_id_val = LAST_INSERT_ID();
    
    -- Insert into respective user type table
    IF p_user_type = 'Customer' THEN
        INSERT INTO Customers (user_id, royalty_points, tier)
        VALUES (user_id_val, IFNULL(p_royalty_points, 0), IFNULL(p_tier, 'Bronze'));
    ELSEIF p_user_type = 'RestaurantOwner' THEN
        INSERT INTO RestaurantOwners (user_id)
        VALUES (user_id_val);
    ELSEIF p_user_type = 'DeliveryAgent' THEN
        INSERT INTO DeliveryAgents (user_id, status)
        VALUES (user_id_val, IFNULL(p_status, 'Active'));
    ELSEIF p_user_type = 'Admin' THEN
        INSERT INTO Admins (user_id)
        VALUES (user_id_val);
    END IF;
    
    SELECT user_id_val AS new_user_id;
END //
DELIMITER ;

-- UpdateUser procedure
DELIMITER //
CREATE PROCEDURE UpdateUser(
    IN p_user_id INT,
    IN p_name VARCHAR(100),
    IN p_contact VARCHAR(20),
    IN p_password VARCHAR(255),
    IN p_location VARCHAR(255),
    IN p_status ENUM('Active', 'Inactive')
)
BEGIN
    DECLARE user_type_val VARCHAR(20);
    
    -- Get user type
    SELECT user_type INTO user_type_val FROM Users WHERE user_id = p_user_id;
    
    -- Update Users table
    UPDATE Users 
    SET name = IFNULL(p_name, name),
        contact = IFNULL(p_contact, contact),
        password = IFNULL(p_password, password),
        location = IFNULL(p_location, location)
    WHERE user_id = p_user_id;
    
    -- Update status if DeliveryAgent
    IF user_type_val = 'DeliveryAgent' AND p_status IS NOT NULL THEN
        UPDATE DeliveryAgents 
        SET status = p_status
        WHERE user_id = p_user_id;
    END IF;
    
    SELECT p_user_id AS updated_user_id;
END //
DELIMITER ;

-- DeleteUser procedure
DELIMITER //
CREATE PROCEDURE DeleteUser(IN p_user_id INT)
BEGIN
    -- Deleting from Users will cascade to the specific user type table
    DELETE FROM Users WHERE user_id = p_user_id;
    
    SELECT CONCAT('User with ID ', p_user_id, ' deleted successfully') AS message;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------------
-- ------------------------Restaurant & Menu Management------------------------------
-- ----------------------------------------------------------------------------------
-- AddRestaurant procedure
DELIMITER //
CREATE PROCEDURE AddRestaurant(
    IN p_owner_id INT,
    IN p_name VARCHAR(100),
    IN p_location VARCHAR(255),
    IN p_contact VARCHAR(20)
)
BEGIN
    DECLARE restaurant_id_val INT;
    
    INSERT INTO Restaurants (owner_id, name, location, contact)
    VALUES (p_owner_id, p_name, p_location, p_contact);
    
    SET restaurant_id_val = LAST_INSERT_ID();
    
    SELECT restaurant_id_val AS new_restaurant_id;
END //
DELIMITER ;

-- UpdateRestaurant procedure
DELIMITER //
CREATE PROCEDURE UpdateRestaurant(
    IN p_restaurant_id INT,
    IN p_name VARCHAR(100),
    IN p_location VARCHAR(255),
    IN p_contact VARCHAR(20),
    IN p_is_active BOOLEAN
)
BEGIN
    UPDATE Restaurants
    SET name = IFNULL(p_name, name),
        location = IFNULL(p_location, location),
        contact = IFNULL(p_contact, contact),
        is_active = IFNULL(p_is_active, is_active)
    WHERE restaurant_id = p_restaurant_id;
    
    SELECT p_restaurant_id AS updated_restaurant_id;
END //
DELIMITER ;

-- DeleteRestaurant procedure
DELIMITER //
CREATE PROCEDURE DeleteRestaurant(IN p_restaurant_id INT)
BEGIN
    DELETE FROM Restaurants WHERE restaurant_id = p_restaurant_id;
    
    SELECT CONCAT('Restaurant with ID ', p_restaurant_id, ' deleted successfully') AS message;
END //
DELIMITER ;

-- AddMenuItem procedure
DELIMITER //
CREATE PROCEDURE AddMenuItem(
    IN p_restaurant_id INT,
    IN p_category_id INT,
    IN p_name VARCHAR(100),
    IN p_description TEXT,
    IN p_price DECIMAL(10,2),
    IN p_is_available BOOLEAN
)
BEGIN
    DECLARE item_id_val INT;
    
    INSERT INTO MenuItems (restaurant_id, category_id, name, description, price, is_available)
    VALUES (p_restaurant_id, p_category_id, p_name, p_description, p_price, IFNULL(p_is_available, TRUE));
    
    SET item_id_val = LAST_INSERT_ID();
    
    SELECT item_id_val AS new_item_id;
END //
DELIMITER ;

-- UpdateMenuItem procedure
DELIMITER //
CREATE PROCEDURE UpdateMenuItem(
    IN p_item_id INT,
    IN p_name VARCHAR(100),
    IN p_description TEXT,
    IN p_price DECIMAL(10,2),
    IN p_is_available BOOLEAN
)
BEGIN
    UPDATE MenuItems
    SET name = IFNULL(p_name, name),
        description = IFNULL(p_description, description),
        price = IFNULL(p_price, price),
        is_available = IFNULL(p_is_available, is_available)
    WHERE item_id = p_item_id;
    
    SELECT p_item_id AS updated_item_id;
END //
DELIMITER ;

-- DeleteMenuItem procedure
DELIMITER //
CREATE PROCEDURE DeleteMenuItem(IN p_item_id INT)
BEGIN
    DELETE FROM MenuItems WHERE item_id = p_item_id;
    
    SELECT CONCAT('Menu item with ID ', p_item_id, ' deleted successfully') AS message;
END //
DELIMITER ;


-- ----------------------------------------------------------------------------------
-- ------------------------Ratings & Reviews-----------------------------------------
-- ----------------------------------------------------------------------------------

-- RateRestaurant procedure
DELIMITER //
CREATE PROCEDURE RateRestaurant(
    IN p_restaurant_id INT,
    IN p_customer_id INT,
    IN p_rating INT,
    IN p_comment TEXT
)
BEGIN
    -- Validate rating
    IF p_rating < 1 OR p_rating > 5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Rating must be between 1 and 5';
    END IF;
    
    -- Add review
    INSERT INTO RestaurantReviews (restaurant_id, customer_id, rating, comment)
    VALUES (p_restaurant_id, p_customer_id, p_rating, p_comment);
    
    SELECT CONCAT('Thank you for your review! Rating of ', p_rating, ' submitted for restaurant.') AS message,
           p_restaurant_id AS restaurant_id,
           p_rating AS rating;
END //
DELIMITER ;

-- RateMenuItem procedure
DELIMITER //
CREATE PROCEDURE RateMenuItem(
    IN p_item_id INT,
    IN p_customer_id INT,
    IN p_rating INT,
    IN p_comment TEXT
)
BEGIN
    -- Validate rating
    IF p_rating < 1 OR p_rating > 5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Rating must be between 1 and 5';
    END IF;
    
    -- Add review
    INSERT INTO MenuItemReviews (item_id, customer_id, rating, comment)
    VALUES (p_item_id, p_customer_id, p_rating, p_comment);
    
    SELECT CONCAT('Thank you for your review! Rating of ', p_rating, ' submitted for menu item.') AS message,
           p_item_id AS item_id,
           p_rating AS rating;
END //
DELIMITER ;