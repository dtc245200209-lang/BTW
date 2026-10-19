-- =============================================================================
-- BÀI TẬP: XÂY DỰNG CƠ SỞ DỮ LIỆU QUẢN LÝ BÁN HÀNG
-- CSDL: QuanLyBanHang (MySQL)
-- =============================================================================

-- 1. Tạo cơ sở dữ liệu
CREATE DATABASE IF NOT EXISTS QuanLyBanHang;
USE QuanLyBanHang;

-- 2. Tạo bảng Customer (Danh sách khách hàng)
CREATE TABLE Customer (
    cID INT AUTO_INCREMENT PRIMARY KEY,
    cName VARCHAR(50) NOT NULL,
    cAge TINYINT
);

-- 3. Tạo bảng Order (Hóa đơn mua hàng)
-- Lưu ý: 'Order' là từ khóa dự phòng (Reserved Keyword) trong MySQL nên cần bọc trong dấu ``
CREATE TABLE `Order` (
    oID INT AUTO_INCREMENT PRIMARY KEY,
    cID INT NOT NULL,
    oDate DATETIME NOT NULL,
    oTotalPrice INT DEFAULT NULL,
    FOREIGN KEY (cID) REFERENCES Customer(cID)
);

-- 4. Tạo bảng Product (Danh mục sản phẩm)
CREATE TABLE Product (
    pID INT AUTO_INCREMENT PRIMARY KEY,
    pName VARCHAR(50) NOT NULL,
    pPrice INT NOT NULL
);

-- 5. Tạo bảng OrderDetail (Chi tiết hóa đơn - Bảng trung gian cho quan hệ N-M)
CREATE TABLE OrderDetail (
    oID INT NOT NULL,
    pID INT NOT NULL,
    odQTY INT NOT NULL CHECK (odQTY > 0),
    PRIMARY KEY (oID, pID),
    FOREIGN KEY (oID) REFERENCES `Order`(oID),
    FOREIGN KEY (pID) REFERENCES Product(pID)
);