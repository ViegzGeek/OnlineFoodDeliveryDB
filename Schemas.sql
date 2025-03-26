-- Create database
CREATE DATABASE IF NOT EXISTS MadXonFoodDeliveryDB;
USE MadXonFoodDeliveryDB;

-- UserType enum
DROP TABLE IF EXISTS UserTypes;
CREATE TABLE UserTypes (
    type_name VARCHAR(20) PRIMARY KEY
);
INSERT INTO UserTypes VALUES ('Customer'), ('RestaurantOwner'), ('DeliveryAgent'), ('Admin');

-- Main User table
DROP TABLE IF EXISTS Users;
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    user_type VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_type) REFERENCES UserTypes(type_name),
    CHECK (LENGTH(contact) >= 10)
);

-- Customer table
DROP TABLE IF EXISTS Customers;
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    royalty_points INT DEFAULT 0,
    tier VARCHAR(20) DEFAULT 'Bronze',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Restaurant Owner table
DROP TABLE IF EXISTS RestaurantOwners;
CREATE TABLE RestaurantOwners (
    owner_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Delivery Agent table
DROP TABLE IF EXISTS DeliveryAgents;
CREATE TABLE DeliveryAgents (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Admin table
DROP TABLE IF EXISTS Admins;
CREATE TABLE Admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Restaurant table
DROP TABLE IF EXISTS Restaurants;
CREATE TABLE Restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    contact VARCHAR(20) NOT NULL,
    rating DECIMAL(3,2) DEFAULT 0.0,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (owner_id) REFERENCES RestaurantOwners(owner_id) ON DELETE CASCADE
);

-- Menu Category table
DROP TABLE IF EXISTS MenuCategories;
CREATE TABLE MenuCategories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Menu Items table
DROP TABLE IF EXISTS MenuItems;
CREATE TABLE MenuItems (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    category_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3,2) DEFAULT 0.0,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES MenuCategories(category_id),
    CHECK (price > 0)
);

-- Order Status enum table
DROP TABLE IF EXISTS OrderStatuses;
CREATE TABLE OrderStatuses (
    status_name VARCHAR(20) PRIMARY KEY
);
INSERT INTO OrderStatuses VALUES ('Placed'), ('Preparing'), ('Pending'), ('Completed'), ('Cancelled');

-- Delivery Status enum table
DROP TABLE IF EXISTS DeliveryStatuses;
CREATE TABLE DeliveryStatuses (
    status_name VARCHAR(20) PRIMARY KEY
);
INSERT INTO DeliveryStatuses VALUES ('Preparing'), ('OutForDelivery'), ('Delivered');

-- Orders table
DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Placed',
    delivery_status VARCHAR(20) DEFAULT 'Preparing',
    total_amount DECIMAL(10,2) DEFAULT 0.0,
    delivery_agent_id INT,
    delivery_address VARCHAR(255) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id),
    FOREIGN KEY (status) REFERENCES OrderStatuses(status_name),
    FOREIGN KEY (delivery_status) REFERENCES DeliveryStatuses(status_name),
    FOREIGN KEY (delivery_agent_id) REFERENCES DeliveryAgents(agent_id)
);

-- Order Items table
DROP TABLE IF EXISTS OrderItems;
CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price_at_order DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES MenuItems(item_id),
    CHECK (quantity > 0)
);

-- Payment Methods enum table
DROP TABLE IF EXISTS PaymentMethods;
CREATE TABLE PaymentMethods (
    method_name VARCHAR(20) PRIMARY KEY
);
INSERT INTO PaymentMethods VALUES ('Cash'), ('CreditCard'), ('DebitCard'), ('UPI'), ('Wallet');

-- Payments table
DROP TABLE IF EXISTS Payments;
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_id VARCHAR(100),
    status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (payment_method) REFERENCES PaymentMethods(method_name),
    CHECK (amount > 0)
);

-- Refunds table
DROP TABLE IF EXISTS Refunds;
CREATE TABLE Refunds (
    refund_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    refund_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    FOREIGN KEY (payment_id) REFERENCES Payments(payment_id),
    CHECK (amount > 0)
);

-- Restaurant Reviews table
DROP TABLE IF EXISTS RestaurantReviews;
CREATE TABLE RestaurantReviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    CHECK (rating BETWEEN 1 AND 5)
);

-- Menu Item Reviews table
DROP TABLE IF EXISTS MenuItemReviews;
CREATE TABLE MenuItemReviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES MenuItems(item_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    CHECK (rating BETWEEN 1 AND 5)
);