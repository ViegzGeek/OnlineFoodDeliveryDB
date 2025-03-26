INSERT INTO Users (name, contact, password, location, user_type) VALUES
('Kalai', '5551112222', 'pass123', '123 Main St, Cityville', 'Customer'),
('Loki', '5552223333', 'pass456', '456 Oak Ave, Townsville', 'Customer'),
('Thennavan', '5553334444', 'pass789', '789 Pine Rd, Villageton', 'Customer'),
('Sheik', '5554445555', 'pass012', '321 Elm St, Hamletown', 'Customer'),
('Raj', '5555556666', 'pass345', '654 Maple Dr, Boroughburg', 'Customer'),
('Sekar', '5556667777', 'ownerpass1', '987 Food Plaza, Cityville', 'RestaurantOwner'),
('Kumar', '5557778888', 'ownerpass2', '654 Diner Lane, Townsville', 'RestaurantOwner'),
('Gokul', '5558889999', 'agentpass1', '123 Delivery Rd, Cityville', 'DeliveryAgent'),
('Arasu', '5559990000', 'agentpass2', '456 Courier Ave, Townsville', 'DeliveryAgent'),
('VIGNESH', '5550001111', 'adminpass', '789 HQ Blvd, Cityville', 'Admin');

-- Customers
INSERT INTO Customers (user_id, royalty_points, tier) VALUES
(1, 120, 'Silver'),
(2, 75, 'Bronze'),
(3, 350, 'Gold'),
(4, 25, 'Bronze'),
(5, 600, 'Gold');

-- RestaurantOwners
INSERT INTO RestaurantOwners (user_id) VALUES (6), (7);

-- DeliveryAgents
INSERT INTO DeliveryAgents (user_id, status) VALUES
(8, 'Active'),
(9, 'Active');

-- Admins
INSERT INTO Admins (user_id) VALUES (10);



INSERT INTO Restaurants (owner_id, name, location, contact, rating) VALUES
(1, 'Tasty Bites', '123 Food Street, Cityville', '5551111111', 4.5),
(1, 'Burger Palace', '456 Fast Food Ave, Townsville', '5552222222', 4.2),
(2, 'Pizza Heaven', '789 Italian Rd, Cityville', '5553333333', 4.7),
(2, 'Sushi World', '321 Japanese St, Townsville', '5554444444', 4.8);

INSERT INTO MenuCategories (name) VALUES
('Appetizers'),
('Main Course'),
('Desserts'),
('Beverages'),
('Specials');

INSERT INTO MenuItems (restaurant_id, category_id, name, description, price, rating) VALUES
(1, 1, 'Garlic Bread', 'Freshly baked with garlic butter', 5.99, 4.5),
(1, 2, 'Spaghetti Bolognese', 'Classic pasta with meat sauce', 12.99, 4.7),
(1, 3, 'Tiramisu', 'Italian coffee-flavored dessert', 7.99, 4.8),
(2, 1, 'Onion Rings', 'Crispy fried onion rings', 4.99, 4.2),
(2, 2, 'Classic Burger', 'Beef patty with cheese and veggies', 9.99, 4.5),
(2, 4, 'Milkshake', 'Vanilla, chocolate or strawberry', 4.99, 4.6),
(3, 1, 'Bruschetta', 'Toasted bread with tomato and garlic', 6.99, 4.7),
(3, 2, 'Margherita Pizza', 'Classic tomato and mozzarella', 14.99, 4.8),
(3, 5, 'Chef Special Pizza', 'Daily special ingredients', 16.99, 4.9),
(4, 1, 'Edamame', 'Steamed soybeans with salt', 4.99, 4.5),
(4, 2, 'California Roll', 'Crab, avocado and cucumber', 10.99, 4.7),
(4, 2, 'Salmon Nigiri', 'Fresh salmon over rice', 12.99, 4.8);



INSERT INTO Orders (customer_id, restaurant_id, order_date, status, delivery_status, total_amount, delivery_agent_id, delivery_address) VALUES
(1, 1, '2025-01-01 12:00:00', 'Completed', 'Delivered', 25.97, 1, '123 Main St, Cityville'),
(2, 2, '2025-01-02 12:30:00', 'Completed', 'Delivered', 19.97, 2, '456 Oak Ave, Townsville'),
(3, 3, '2025-01-03 13:00:00', 'Completed', 'Delivered', 28.97, 1, '789 Pine Rd, Villageton'),
(4, 4, '2025-01-04 18:00:00', 'Completed', 'Delivered', 34.97, 2, '321 Elm St, Hamletown'),
(5, 1, '2025-01-05 19:00:00', 'Completed', 'Delivered', 18.98, 1, '654 Maple Dr, Boroughburg'),
(1, 2, '2025-01-06 12:15:00', 'Preparing', 'Preparing', 24.97, NULL, '123 Main St, Cityville'),
(2, 3, '2025-01-07 13:30:00', 'Pending', 'Preparing', 31.97, NULL, '456 Oak Ave, Townsville'),
(3, 4, '2025-01-08 18:45:00', 'Placed', 'Preparing', 27.98, NULL, '789 Pine Rd, Villageton'),
(4, 1, '2025-01-09 19:30:00', 'Cancelled', 'Preparing', 15.99, NULL, '321 Elm St, Hamletown'),
(5, 2, '2025-01-10 20:00:00', 'Pending', 'Preparing', 22.97, NULL, '654 Maple Dr, Boroughburg');

INSERT INTO OrderItems (order_id, item_id, quantity, price_at_order) VALUES
(1, 1, 2, 5.99), (1, 2, 1, 12.99),
(2, 4, 1, 4.99), (2, 5, 1, 9.99), (2, 6, 1, 4.99),
(3, 7, 1, 6.99), (3, 8, 1, 14.99), (3, 3, 1, 7.99),
(4, 10, 1, 4.99), (4, 11, 2, 10.99), (4, 12, 1, 12.99),
(5, 1, 1, 5.99), (5, 3, 1, 7.99), (5, 2, 1, 12.99),
(6, 4, 2, 4.99), (6, 5, 1, 9.99), (6, 6, 1, 4.99),
(7, 7, 1, 6.99), (7, 9, 1, 16.99), (7, 3, 1, 7.99),
(8, 10, 1, 4.99), (8, 11, 1, 10.99), (8, 12, 1, 12.99),
(9, 1, 1, 5.99), (9, 2, 1, 12.99),
(10, 4, 1, 4.99), (10, 5, 1, 9.99), (10, 6, 1, 4.99);

INSERT INTO Payments (order_id, amount, payment_method, payment_date, transaction_id, status) VALUES
(1, 25.97, 'CreditCard', '2025-01-01 12:05:00', 'TXN001', 'Completed'),
(2, 19.97, 'DebitCard', '2025-01-02 12:35:00', 'TXN002', 'Completed'),
(3, 28.97, 'UPI', '2025-01-03 13:05:00', 'TXN003', 'Completed'),
(4, 34.97, 'CreditCard', '2025-01-04 18:05:00', 'TXN004', 'Completed'),
(5, 18.98, 'Wallet', '2025-01-05 19:05:00', 'TXN005', 'Completed'),
(6, 24.97, 'CreditCard', '2025-01-06 12:20:00', 'TXN006', 'Pending'),
(7, 31.97, 'DebitCard', '2025-01-07 13:35:00', 'TXN007', 'Pending'),
(9, 15.99, 'UPI', '2025-01-09 19:35:00', 'TXN009', 'Refunded'),
(10, 22.97, 'CreditCard', '2025-01-10 20:05:00', 'TXN010', 'Pending');

INSERT INTO Refunds (payment_id, amount, refund_date, reason, status) VALUES
(8, 15.99, '2025-01-09 19:40:00', 'Order cancelled by customer', 'Completed');

INSERT INTO RestaurantReviews (restaurant_id, customer_id, rating, comment) VALUES
(1, 1, 5, 'Excellent food and service!'),
(2, 2, 4, 'Great burgers but a bit slow'),
(3, 3, 5, 'Best pizza in town!'),
(4, 4, 4, 'Fresh sushi, will come again'),
(1, 5, 4, 'Good pasta but pricey');

INSERT INTO MenuItemReviews (item_id, customer_id, rating, comment) VALUES
(2, 1, 5, 'Perfect Bolognese sauce'),
(5, 2, 4, 'Juicy burger but bun was dry'),
(8, 3, 5, 'Perfect crust and cheese'),
(11, 4, 4, 'Fresh ingredients, well made'),
(3, 5, 5, 'Best tiramisu I ever had');