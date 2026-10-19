-- =============================================================================
-- THIẾT KẾ CƠ SỞ DỮ LIỆU HEALTHSYNC (ĐÃ TỐI ƯU HÓA & CHUẨN HÓA)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS healthsync_db;
USE healthsync_db;

-- 1. BẢNG PATIENTS
DROP TABLE IF EXISTS Prescriptions;
DROP TABLE IF EXISTS Appointments;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Patients;

CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. BẢNG DOCTORS
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. BẢNG APPOINTMENTS (Đã loại bỏ is_active, bổ sung ENUM và dữ liệu tài chính)
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    
    -- Trạng thái vòng đời 5 cấp
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    
    -- Thông tin tài chính & hủy lịch (sử dụng DECIMAL tránh lỗi làm tròn)
    deposit_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    penalty_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    cancel_reason VARCHAR(255) NULL,
    
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. BẢNG PRESCRIPTIONS (Tạo mới thực thể đơn thuốc)
CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE, -- Quan hệ 1-1 với lịch hẹn hoàn tất
    medication_details TEXT NOT NULL,
    issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- RÀNG BUỘC NGHIỆP VỤ Ở TẦNG CSDL (TRIGGER CHẶN KÊ ĐƠN SAI TRẠNG THÁI)
-- =============================================================================
DELIMITER //
CREATE TRIGGER trg_check_prescription_status
BEFORE INSERT ON Prescriptions
FOR EACH ROW
BEGIN
    DECLARE app_status VARCHAR(20);
    
    SELECT status INTO app_status 
    FROM Appointments 
    WHERE appointment_id = NEW.appointment_id;
    
    IF app_status != 'COMPLETED' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Chỉ được kê đơn thuốc cho lịch hẹn đã hoàn thành (COMPLETED)!';
    END IF;
END //
DELIMITER ;

-- =============================================================================
-- DML: MÔ PHỎNG KỊCH BẢN NGHIỆP VỤ THỰC TẾ
-- =============================================================================

-- Khởi tạo dữ liệu mẫu
INSERT INTO Patients (full_name, phone) VALUES 
('Nguyen Van A', '0901234567'),
('Tran Thi B', '0987654321');

INSERT INTO Doctors (full_name, specialty) VALUES 
('BS. Le Van C', 'Noi khoa'),
('BS. Pham Thi D', 'Nhi khoa');

-- -----------------------------------------------------------------------------
-- KỊCH BẢN 1: Luồng khám bệnh thành công trọn vẹn
-- -----------------------------------------------------------------------------
-- 1.1 Bệnh nhân A đặt lịch, cọc 500.000 VNĐ (PENDING)
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (1, 1, '2026-10-20 09:00:00', 'PENDING', 500000.00);

-- 1.2 Duyệt cọc -> CONFIRMED -> Bệnh nhân đến phòng khám -> CHECKED_IN
UPDATE Appointments SET status = 'CONFIRMED' WHERE appointment_id = 1;
UPDATE Appointments SET status = 'CHECKED_IN' WHERE appointment_id = 1;

-- 1.3 Khám xong -> COMPLETED
UPDATE Appointments SET status = 'COMPLETED' WHERE appointment_id = 1;

-- 1.4 Bác sĩ kê đơn thuốc cho lịch hẹn #1
INSERT INTO Prescriptions (appointment_id, medication_details)
VALUES (1, 'Paracetamol 500mg (10 viên), Vitamin C 1000mg (10 viên). Uong ngay 2 lan.');

-- -----------------------------------------------------------------------------
-- KỊCH BẢN 2: Luồng hủy lịch và tính phí phạt
-- -----------------------------------------------------------------------------
-- 2.1 Bệnh nhân B đặt lịch, cọc 300.000 VNĐ
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (2, 2, '2026-10-21 14:00:00', 'CONFIRMED', 300000.00);

-- 2.2 Bệnh nhân B báo hủy lịch -> CANCELLED, phạt 150.000 VNĐ
UPDATE Appointments 
SET status = 'CANCELLED',
    cancel_reason = 'Ban viec dot xuat',
    penalty_fee = 150000.00
WHERE appointment_id = 2;

-- =============================================================================
-- TRUY VẤN KIỂM TRA (SELECT VERIFICATION)
-- =============================================================================

-- Truy vấn 1: Danh sách bệnh nhân đã hoàn tất khám kèm chi tiết đơn thuốc
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    d.full_name AS doctor_name,
    a.appointment_date,
    a.deposit_amount,
    pr.medication_details,
    pr.issued_date
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
JOIN Prescriptions pr ON a.appointment_id = pr.appointment_id
WHERE a.status = 'COMPLETED';

-- Truy vấn 2: Báo cáo danh sách hủy lịch và đối soát tiền cọc/phí phạt
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    a.deposit_amount,
    a.penalty_fee,
    (a.deposit_amount - a.penalty_fee) AS refund_amount,
    a.cancel_reason
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
WHERE a.status = 'CANCELLED';