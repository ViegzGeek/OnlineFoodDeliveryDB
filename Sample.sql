-- Add a customer
CALL AddUser('Vignesh', '1234567890', 'securepass123', '123 Main St', 'Customer', 0, 'Bronze', NULL);
-- Output: Returns new_user_id (e.g., 1)

-- Add a restaurant owner
CALL AddUser('Loki', '9876543210', 'ownerpass', '456 Oak Ave', 'RestaurantOwner', NULL, NULL, NULL);
-- Output: Returns new_user_id (e.g., 2)

-- Add a delivery agent
CALL AddUser('Raj', '5551234567', 'delivery123', '789 Pine Rd', 'DeliveryAgent', NULL, NULL, 'Active');
-- Output: Returns new_user_id (e.g., 3)

-- Update user details
-- CALL UpdateUser(1, 'Johnathan Doe', NULL, 'newsecurepass', '123 Main Street Apt 4', NULL);
-- Output: Returns updated_user_id (1)

-- Delete a user
-- CALL DeleteUser();
-- Output: "User with ID 3 deleted successfully"

-- Add a restaurant (owner_id from RestaurantOwners table)
CALL AddRestaurant(1, 'Tasty Bites', '123 Food Street', '555-1111');
-- Output: Returns new_restaurant_id (e.g., 1)

-- Update restaurant details
-- CALL UpdateRestaurant(1, 'Tasty Bites Deluxe', NULL, '555-1112', NULL);
-- Output: Returns updated_restaurant_id (1)

-- Add menu category
-- INSERT INTO MenuCategories (name) VALUES ('Appetizers'), ('Main Course'), ('Desserts');

-- Add menu item
CALL AddMenuItem(1, 1, 'Garlic Bread', 'Freshly baked with garlic butter', 5.99, TRUE);
-- Output: Returns new_item_id (e.g., 1)

-- Place an order (customer_id from Customers table)
CALL PlaceOrder(1, 5, '123 Main Street Apt 4');
-- Output: "Order placed successfully. Order ID: 1. Now you can add items to your order."

-- Add items to order
CALL AddOrderItem(11, 13, 2); -- 2 orders of Garlic Bread
-- Output: "Item added to order successfully. Current order total: 11.98..."

-- Remove an item from order (order_item_id from OrderItems table)
-- CALL RemoveOrderItem(1);
-- Output: "Item removed from order. Refunded amount: 11.98..."

-- Update order status
CALL UpdateOrderStatus(11, 'Preparing');
-- Output: "Order status updated to Preparing"

-- Cancel an order
-- CALL CancelOrder(1);
-- Output: "Order cancelled successfully. No payment was made."

-- Make a payment (after order is in Pending status)
CALL MakePayment(11, 25.99, 'CreditCard', 'TXN123456');
-- Output: "Payment processed successfully. Payment ID: 1..."

-- Process a refund
-- CALL ProcessRefund(1);
-- Output: "Refund processed successfully. Amount: 25.99"

-- Assign delivery agent
CALL AssignDeliveryAgent(11, 1);
-- Output: "Delivery agent assigned successfully..."

-- Update delivery status
CALL UpdateDeliveryStatus(11, 'Delivered');
-- Output: "Delivery status updated to Delivered"

-- Rate a restaurant
CALL RateRestaurant(5, 1, 5, 'Excellent food and service!');
-- Output: "Thank you for your review! Rating of 5 submitted for restaurant."

-- Rate a menu item
CALL RateMenuItem(13, 1, 4, 'Very tasty but a bit salty');
-- Output: "Thank you for your review! Rating of 4 submitted for menu item."

-- View active restaurants with ratings
SELECT * FROM ActiveRestaurantsWithRatings;
-- Output: List of all active restaurants with their details and ratings

-- View available menu items
SELECT * FROM AvailableMenuItems WHERE restaurant_name = 'Tasty Bites Deluxe';
-- Output: All available menu items from this restaurant

-- View order details
SELECT * FROM OrderDetails WHERE order_id = 1;
-- Output: Complete details of order with ID 1

-- View delivery agent performance
SELECT * FROM DeliveryAgentPerformance WHERE successful_deliveries > 10;
-- Output: Agents with more than 10 successful deliveries

