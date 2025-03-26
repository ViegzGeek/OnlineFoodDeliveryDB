
-- Trigger to Auto Update Restaurant Rating
DELIMITER $$
CREATE TRIGGER UpdateRestaurantRating
AFTER INSERT ON RestaurantRatings
FOR EACH ROW
BEGIN
    UPDATE Restaurants
    SET overall_rating = (SELECT AVG(rating) FROM RestaurantRatings WHERE restaurant_id = NEW.restaurant_id)
    WHERE restaurant_id = NEW.restaurant_id;
END $$
DELIMITER ;

-- Trigger to Update Loyalty Points and User Tier
DELIMITER $$
CREATE TRIGGER UpdateLoyaltyPoints
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    UPDATE Users
    SET loyalty_points = loyalty_points + (NEW.total_price * 0.1),
        user_tier = CASE
            WHEN loyalty_points >= 500 THEN 'Platinum'
            WHEN loyalty_points >= 300 THEN 'Gold'
            WHEN loyalty_points >= 100 THEN 'Silver'
            ELSE 'Bronze'
        END
    WHERE user_id = NEW.user_id;
END $$
DELIMITER ;
