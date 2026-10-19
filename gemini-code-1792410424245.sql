-- ============================================================================
-- BÀI TẬP: XÂY DỰNG CƠ SỞ DỮ LIỆU QUẢN LÝ SINH VIÊN
-- ============================================================================

-- 1. Khởi tạo và sử dụng CSDL 'student-management'
CREATE DATABASE IF NOT EXISTS `student-management`
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE `student-management`;

-- 2. Tạo Bảng 'Class' (Lớp học)
CREATE TABLE IF NOT EXISTS `Class` (
    `id` INT,
    `name` VARCHAR(255)
);

-- 3. Tạo Bảng 'Teacher' (Giảng viên)
CREATE TABLE IF NOT EXISTS `Teacher` (
    `id` INT,
    `name` VARCHAR(255),
    `age` INT,
    `country` VARCHAR(100)
);

-- ============================================================================
-- PHIÊN BẢN CHUẨN NÂNG CẤP (BEST PRACTICE IN PRODUCTION)
-- Bổ sung Khóa chính (PRIMARY KEY), Auto Increment và Ràng buộc Dữ liệu
-- ============================================================================
/*
CREATE TABLE IF NOT EXISTS `Class` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(150) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `Teacher` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(150) NOT NULL,
    `age` INT CHECK (`age` >= 18 AND `age` <= 100),
    `country` VARCHAR(100) DEFAULT 'Việt Nam',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;
*/