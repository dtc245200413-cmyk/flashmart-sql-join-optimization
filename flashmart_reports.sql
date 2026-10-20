-- ==============================================================================
-- DỰ ÁN: HỆ THỐNG THƯƠNG MẠI ĐIỆN TỬ FLASHMART
-- TỐI ƯU HÓA TRUY VẤN DỮ LIỆU BÁO CÁO (INNER JOIN VS LEFT JOIN & ANTI-JOIN)
-- Data Engineer: DTC245200413
-- Repository: https://github.com/dtc245200413-cmyk/flashmart-sql-join-optimization
-- ==============================================================================

-- 1. Khởi tạo Cơ sở dữ liệu FlashMart
CREATE DATABASE IF NOT EXISTS flashmart_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE flashmart_db;

-- 2. Dọn dẹp và Tạo các bảng nghiệp vụ
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 3. Chèn dữ liệu mẫu (Seed Data)
INSERT INTO Customers VALUES 
(1, 'Alice'), 
(2, 'Bob'), 
(3, 'Charlie'); 
-- Ghi chú: Charlie là khách hàng mới đăng ký, CHƯA TỪNG mua hàng

INSERT INTO Products VALUES 
(101, 'Laptop'), 
(102, 'Mouse'), 
(103, 'Keyboard'); 
-- Ghi chú: Keyboard là sản phẩm tồn kho, CHƯA TỪNG được ai mua

INSERT INTO Orders VALUES 
(1001, 1, 101), 
(1002, 1, 102), 
(1003, 2, 101);

-- ==============================================================================
-- BÁO CÁO 1: YÊU CẦU TỪ GIÁM ĐỐC MARKETING
-- "Danh sách tất cả khách hàng đã đăng ký kèm số lượng đơn hàng đã mua.
--  Những người chưa từng mua (0 đơn) sẽ được nhận Voucher 50% kích cầu."
-- ==============================================================================
-- Giải pháp tối ưu:
-- + Driving Table (bảng bên trái): Customers (đảm bảo giữ lại 100% khách hàng)
-- + Reference Table (bảng bên phải): Orders
-- + Loại JOIN: LEFT JOIN
-- + Hàm đếm: COUNT(o.order_id) thay vì COUNT(*) để Charlie có 0 đơn hàng chính xác.

SELECT 
    c.customer_id, 
    c.name, 
    COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_orders DESC, c.customer_id ASC;

-- Báo cáo lọc riêng nhóm khách hàng đủ điều kiện nhận Voucher 50% (total_orders = 0):
SELECT 
    c.customer_id, 
    c.name, 
    COUNT(o.order_id) AS total_orders,
    'Tặng Voucher 50%' AS promotion_action
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING total_orders = 0;


-- ==============================================================================
-- BÁO CÁO 2: YÊU CẦU TỪ GIÁM ĐỐC KHO VẬN
-- "Danh sách các sản phẩm chưa từng được bán ra lần nào để thanh lý thu hồi vốn."
-- ==============================================================================
-- Giải pháp tối ưu:
-- + Driving Table: Products
-- + Reference Table: Orders
-- + Loại JOIN: LEFT JOIN kết hợp lọc Anti-Join (WHERE o.order_id IS NULL)
-- + Giải thích: Những sản phẩm không có đơn hàng thì các cột bên bảng Orders sẽ là NULL.

SELECT 
    p.product_id, 
    p.product_name,
    'Cần thanh lý tồn kho' AS inventory_status
FROM Products p
LEFT JOIN Orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;


-- ==============================================================================
-- MỞ RỘNG KIẾN THỨC NÂNG CAO CHO DATA ENGINEER:
-- CÁCH 2 ĐỂ VIẾT ANTI-JOIN: SỬ DỤNG NOT EXISTS (Tối ưu chỉ mục tốt)
-- ==============================================================================
SELECT 
    p.product_id, 
    p.product_name
FROM Products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.product_id = p.product_id
);
