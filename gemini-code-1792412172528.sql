-- ========================================================
-- HỆ THỐNG FLASHMART - BÁO CÁO CẢI TIẾN VÀ TỐI ƯU HÓA
-- Data Engineer: Student
-- ========================================================

CREATE DATABASE IF NOT EXISTS flashmart_db;
USE flashmart_db;

-- 1. TẠO CẤU TRÚC BẢNG VÀ CHÈN DỮ LIỆU MẪU
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Products;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY, 
    name VARCHAR(50)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY, 
    product_name VARCHAR(50)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY, 
    customer_id INT, 
    product_id INT
);

INSERT INTO Customers VALUES (1, 'Alice'), (2, 'Bob'), (3, 'Charlie'); 
INSERT INTO Products VALUES (101, 'Laptop'), (102, 'Mouse'), (103, 'Keyboard'); 
INSERT INTO Orders VALUES (1001, 1, 101), (1002, 1, 102), (1003, 2, 101);

-- ========================================================
-- BÁO CÁO 1: Dành cho Giám đốc Marketing
-- Yêu cầu: Tất cả khách hàng + Số lượng đơn (Giữ lại Charlie với 0 đơn)
-- Giải pháp: LEFT JOIN + COUNT(o.order_id)
-- ========================================================
SELECT 
    c.customer_id, 
    c.name, 
    COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- ========================================================
-- BÁO CÁO 2: Dành cho Giám đốc Kho vận (Kỹ thuật Anti-Join)
-- Yêu cầu: Danh sách sản phẩm chưa từng bán ra (Tìm Keyboard)
-- Giải pháp: LEFT JOIN + WHERE o.order_id IS NULL
-- ========================================================
SELECT 
    p.product_id, 
    p.product_name
FROM Products p
LEFT JOIN Orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;