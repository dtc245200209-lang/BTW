-- ============================================================================
-- BÀI THỰC HÀNH: TẠO CƠ SỞ DỮ LIỆU VÀ BẢNG STUDENT
-- ============================================================================

-- Bước 1: Khởi tạo Cơ sở dữ liệu 'demo' (nếu chưa tồn tại)
CREATE DATABASE IF NOT EXISTS `demo`
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

-- Bước 2: Chọn Cơ sở dữ liệu 'demo' làm CSDL làm việc hiện tại
USE `demo`;

-- Bước 3: Tạo bảng 'Student' chứa thông tin sinh viên
CREATE TABLE IF NOT EXISTS `Student` (
    `id` INT,
    `name` VARCHAR(200),
    `age` INT,
    `country` VARCHAR(50)
);

-- ============================================================================
-- PHIÊN BẢN CHUẨN THỰC TẾ (BEST PRACTICE - THAM KHẢO NÂNG CẤP)
-- Bổ sung Khóa chính (PRIMARY KEY), Tự động tăng (AUTO_INCREMENT) và NOT NULL
-- ============================================================================
/*
CREATE TABLE IF NOT EXISTS `Student_Advanced` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(200) NOT NULL,
    `age` INT CHECK (`age` > 0 AND `age` < 120),
    `country` VARCHAR(50) DEFAULT 'Việt Nam',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;
*/