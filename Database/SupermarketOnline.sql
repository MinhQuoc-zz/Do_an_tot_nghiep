DROP DATABASE IF EXISTS SupermarketOnline;
CREATE DATABASE SupermarketOnline;
USE SupermarketOnline;

-- Bảng Người Dùng
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATETIME,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    phone VARCHAR(20) CHECK (phone REGEXP '^[0-9]{10,15}$'),
    address TEXT,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('Admin','Customer') DEFAULT 'Customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Danh Mục Sản Phẩm
DROP TABLE IF EXISTS Categories;
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Nhà Cung Cấp
DROP TABLE IF EXISTS Suppliers;
CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(255) NOT NULL,
    supplier_address TEXT,
    supplier_phone VARCHAR(20) CHECK (supplier_phone REGEXP '^[0-9]{10,15}$')
);

-- Bảng Sản Phẩm
DROP TABLE IF EXISTS Products;
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    category_id INT,
    supplier_id INT,
    price DECIMAL(10,2) NOT NULL,
    unit VARCHAR(50),
    stock_quantity INT NOT NULL,
    manufacture_date DATE,
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Bảng Giảm Giá
DROP TABLE IF EXISTS Discounts;
CREATE TABLE Discounts (
    discount_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    discount_percentage DECIMAL(5,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Bảng Đơn Hàng
DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('created', 'running', 'done', 'failure') DEFAULT 'created',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Bảng Chi Tiết Đơn Hàng
DROP TABLE IF EXISTS OrderDetails;
CREATE TABLE OrderDetails (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    item_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Bảng Giỏ Hàng
DROP TABLE IF EXISTS Cart;
CREATE TABLE Cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    product_id INT,
    quantity INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Bảng Thanh Toán
DROP TABLE IF EXISTS Payments;
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_method ENUM('credit_card', 'paypal', 'cash_on_delivery') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    transaction_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Bảng Vận Chuyển
DROP TABLE IF EXISTS Deliveries;
CREATE TABLE Deliveries (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    delivery_address TEXT NOT NULL,
    delivery_phone VARCHAR(20) NOT NULL CHECK (delivery_phone REGEXP '^[0-9]{10,15}$'),
    delivery_status ENUM('pending', 'shipped', 'delivered', 'failed') DEFAULT 'pending',
    expected_delivery_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Bảng Đánh Giá Sản Phẩm
DROP TABLE IF EXISTS Reviews;
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    product_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Trigger cập nhật số lượng sản phẩm khi đơn hàng hoàn thành
DELIMITER $$
CREATE TRIGGER update_stock_after_order_done
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'done' THEN
        UPDATE Products p
        JOIN OrderDetails od ON p.product_id = od.product_id
        SET p.stock_quantity = p.stock_quantity - od.quantity
        WHERE od.order_id = NEW.order_id;
    END IF;
END $$
DELIMITER ;

-- Dữ liệu cho bảng Users
INSERT INTO Users (full_name, date_of_birth, email, phone, address, username, password, role) VALUES
('Nguyễn Văn A', '1990-01-15', 'nguyenvana@gmail.com', '0912345678', 'Hà Nội', 'nguyenvana', 'pass123', 'Customer'),
('Trần Thị B', '1995-06-20', 'tranthib@gmail.com', '0987654321', 'TP.HCM', 'tranthib', 'pass123', 'Customer'),
('Lê Văn C', '1988-04-10', 'levanc@gmail.com', '0978123456', 'Đà Nẵng', 'levanc', 'pass123', 'Customer'),
('Phạm Thị D', '2000-09-25', 'phamthid@gmail.com', '0967456789', 'Hải Phòng', 'phamthid', 'pass123', 'Admin');

-- Dữ liệu cho bảng Categories
INSERT INTO Categories (category_name) VALUES
('Đồ uống'), ('Thực phẩm'), ('Gia vị'), ('Bánh kẹo');

-- Dữ liệu cho bảng Suppliers
INSERT INTO Suppliers (supplier_name, supplier_address, supplier_phone) VALUES
('Công ty A', 'Hà Nội', '0912345678'),
('Công ty B', 'TP.HCM', '0987654321');

-- Dữ liệu cho bảng Products
INSERT INTO Products (product_name, category_id, supplier_id, price, unit, stock_quantity, manufacture_date, expiry_date, description) VALUES
('Coca Cola', 1, 1, 10000, 'chai', 100, '2024-01-01', '2025-01-01', 'Nước giải khát'),
('Pepsi', 1, 1, 10000, 'chai', 80, '2024-01-05', '2025-01-05', 'Nước giải khát'),
('Bánh Chocopie', 4, 2, 25000, 'hộp', 50, '2024-02-01', '2025-02-01', 'Bánh ngọt'),
('Muối i-ốt', 3, 2, 5000, 'gói', 200, '2024-03-01', '2026-03-01', 'Gia vị');

-- Dữ liệu cho bảng Discounts
INSERT INTO Discounts (product_id, discount_percentage, start_date, end_date) VALUES
(1, 10, '2024-03-01', '2024-03-15'),
(3, 5, '2024-04-01', '2024-04-10');

-- Dữ liệu cho bảng Orders
INSERT INTO Orders (user_id, total_amount, status, payment_id) VALUES
(1, 20000, 'created', NULL),
(2, 50000, 'running', NULL),
(3, 75000, 'done', NULL);

-- Dữ liệu cho bảng OrderDetails
INSERT INTO OrderDetails (order_id, product_id, quantity, item_price) VALUES
(1, 1, 2, 10000),
(2, 3, 2, 25000),
(3, 4, 3, 5000);

-- Dữ liệu cho bảng Cart
INSERT INTO Cart (user_id, product_id, quantity) VALUES
(1, 2, 3),
(2, 3, 1),
(3, 1, 2);

-- Dữ liệu cho bảng Payments
INSERT INTO Payments (order_id, payment_method, payment_status, transaction_id) VALUES
(1, 'credit_card', 'completed', 'TXN12345'),
(2, 'paypal', 'pending', 'TXN67890'),
(3, 'cash_on_delivery', 'completed', NULL);

-- Dữ liệu cho bảng Deliveries
INSERT INTO Deliveries (order_id, delivery_address, delivery_phone, delivery_status, expected_delivery_date) VALUES
(1, 'Hà Nội', '0912345678', 'shipped', '2024-03-10'),
(2, 'TP.HCM', '0987654321', 'pending', '2024-03-15'),
(3, 'Đà Nẵng', '0978123456', 'delivered', '2024-03-05');

-- Dữ liệu cho bảng Reviews
INSERT INTO Reviews (user_id, product_id, rating, comment) VALUES
(1, 1, 5, 'Rất ngon'),
(2, 3, 4, 'Hương vị tuyệt vời'),
(3, 4, 3, 'Bình thường');

