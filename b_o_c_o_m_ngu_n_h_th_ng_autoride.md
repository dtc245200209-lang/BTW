# BÁO CÁO TỔNG HỢP VÀ MÃ NGUỒN CƠ SỞ DỮ LIỆU AUTORIDE

**Dự án:** Hệ thống quản lý thuê xe tự lái AutoRide  
**Vai trò:** Data Architect  
**Đường dẫn Repository GitHub:** <https://github.com/dtc245200209-lang/BTW>

---

## PHẦN 1: BÁO CÁO PHÂN TÍCH (er_activity_mapping.md)

### 1. Bảng chẩn đoán khoảng trống dữ liệu (Data Gaps)

| STT | Thành phần trong Activity Diagram | Tình trạng trong Legacy Database | Hậu quả đối với hệ thống |
| :--- | :--- | :--- | :--- |
| **1** | Trạng thái vòng đời hợp đồng (BOOKED, ACTIVE, COMPLETED, CANCELLED) | Dùng `VARCHAR(50)` không có ràng buộc kiểm soát | Cho phép nhập dữ liệu rác, không kiểm soát được luồng trạng thái từ đặt xe đến hoàn tất. |
| **2** | Nhánh rẽ tài chính khi trả xe (Tiền cọc, Phạt trễ, Phạt hư hỏng) | Hoàn toàn vắng mặt các cột `security_deposit`, `late_fee`, `damage_fee` | Kế toán không thể tính được **Tiền hoàn lại = Tiền cọc - Phạt trễ - Phạt hư hỏng**, gây thất thoát lợi nhuận nghiêm trọng. |
| **3** | Bước kiểm tra tình trạng xe khi nhận/trả xe | Thiếu hoàn toàn bảng `Inspections` | Nhân viên không thể ghi nhận chi tiết xước xát/vỡ đền bù, làm mất dấu vết bằng chứng khi có tranh chấp. |

### 2. Tầm quan trọng của cột `damage_fee` (< 200 từ)

Cột `damage_fee` là trường dữ liệu bắt buộc để đảm bảo tính toàn vẹn hệ thống và bảo vệ dòng tiền kinh doanh của AutoRide. Trong thực tế thuê xe, tổn thất do hư hỏng (xước sơn, vỡ đèn, hỏng động cơ) thường có giá trị rất lớn. Nếu thiếu `damage_fee`, hệ thống không có cơ chế hạch toán trừ tiền phạt trực tiếp vào khoản cọc (`security_deposit`). Nhân viên buộc phải xử lý thủ công hoặc hoàn lại toàn bộ tiền cọc cho khách, dẫn đến việc công ty phải tự gánh chịu toàn bộ chi phí sửa chữa. `damage_fee` kết hợp với `late_fee` giúp tự động hóa công thức tính tiền hoàn trả (`refund_amount`), minh bạch hóa tài chính giữa khách hàng - kế toán - ban quản lý.

---

## PHẦN 2: MÃ NGUỒN SQL HOÀN CHỈNH (autoride_db.sql)

```sql
-- =============================================================================
-- HỆ THỐNG AUTORIDE DATABASE (ĐÃ TỐI ƯU HÓA)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS autoride_db;
USE autoride_db;

-- Xóa bảng cũ nếu tồn tại (theo thứ tự khóa ngoại)
DROP TABLE IF EXISTS Inspections;
DROP TABLE IF EXISTS Rentals;
DROP TABLE IF EXISTS Cars;

-- 1. BẢNG CARS (Danh mục xe)
CREATE TABLE Cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. BẢNG RENTALS (Quản lý hợp đồng thuê xe)
CREATE TABLE Rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    rent_date DATETIME NOT NULL,
    return_date DATETIME NULL,
    
    -- Kiểm soát trạng thái hợp đồng bằng ENUM
    status ENUM('BOOKED', 'ACTIVE', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'BOOKED',
    
    -- Quản lý tài chính (Dùng DECIMAL tránh lỗi làm tròn)
    security_deposit DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    late_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    damage_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    
    FOREIGN KEY (car_id) REFERENCES Cars(car_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. BẢNG INSPECTIONS (Biên bản kiểm tra xe)
CREATE TABLE Inspections (
    inspection_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    inspection_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    damage_description TEXT NULL,
    inspector_name VARCHAR(100) NOT NULL,
    
    FOREIGN KEY (rental_id) REFERENCES Rentals(rental_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- RÀNG BUỘC NGHIỆP VỤ: TRIGGER CHẶN BẢO TRÌ/KIỂM TRA KHI XE CHƯA NHẬN (BOOKED)
-- =============================================================================
DELIMITER //
CREATE TRIGGER trg_check_inspection_status
BEFORE INSERT ON Inspections
FOR EACH ROW
BEGIN
    DECLARE current_status VARCHAR(20);
    
    SELECT status INTO current_status 
    FROM Rentals 
    WHERE rental_id = NEW.rental_id;
    
    IF current_status = 'BOOKED' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Không thể tạo biên bản kiểm tra khi hợp đồng đang ở trạng thái BOOKED (Khách chưa nhận xe)!';
    END IF;
END //
DELIMITER ;

-- =============================================================================
-- DML: MÔ PHỎNG KỊCH BẢN THỰC TẾ
-- =============================================================================

-- Bước 1: Thêm xe mẫu
INSERT INTO Cars (model_name, license_plate) 
VALUES ('Toyota Camry 2023', '30A-123.45');

-- Bước 2: Khách "Nguyen Van A" đặt xe và nhận xe, đóng cọc 10.000.000 VNĐ (Trạng thái ACTIVE)
INSERT INTO Rentals (car_id, customer_name, rent_date, status, security_deposit)
VALUES (1, 'Nguyen Van A', '2026-10-15 08:00:00', 'ACTIVE', 10000000.00);

-- Bước 3: Khách trả xe. Nhân viên kiểm tra phát hiện vỡ đèn pha trái -> Tạo biên bản Inspections
INSERT INTO Inspections (rental_id, damage_description, inspector_name)
VALUES (1, 'Vỡ đèn pha trái, xước nhẹ cản trước', 'Nhan Vien Tran Van B');

-- Bước 4: Cập nhật hợp đồng Rentals: Chuyển COMPLETED, ghi nhận damage_fee = 2.000.000 VNĐ, late_fee = 0
UPDATE Rentals 
SET status = 'COMPLETED',
    return_date = '2026-10-19 17:00:00',
    late_fee = 0.00,
    damage_fee = 2000000.00
WHERE rental_id = 1;

-- =============================================================================
-- TRUY VẤN TÍNH SỐ TIỀN THỰC TẾ HOÀN TRẢ CHO KHÁCH (REFUND CALCULATION)
-- =============================================================================
SELECT 
    r.rental_id,
    r.customer_name,
    c.model_name,
    c.license_plate,
    r.status,
    r.security_deposit AS tiền_cọc,
    r.late_fee AS phạt_trễ,
    r.damage_fee AS phạt_hư_hỏng,
    (r.security_deposit - r.late_fee - r.damage_fee) AS tiền_hoàn_trả_khách,
    i.damage_description AS chi_tiết_lỗi
FROM Rentals r
JOIN Cars c ON r.car_id = c.car_id
LEFT JOIN Inspections i ON r.rental_id = i.rental_id
WHERE r.rental_id = 1;
```

---

## PHẦN 3: BẢO VỆ THIẾT KẾ & VẤN ĐÁP GIẢNG VIÊN (Q&A)

1. **Câu hỏi:** *"Tại sao việc tách dữ liệu kiểm tra xe ra một bảng riêng (`Inspections`) lại tốt hơn việc nhồi nhét một cột `damage_description` trực tiếp vào bảng `Rentals`?"*
   * **Trả lời:**
     * **Chuẩn hóa dữ liệu (Normalization):** Một hợp đồng thuê xe có thể có nhiều lần kiểm tra (lúc nhận xe, lúc trả xe, hoặc kiểm tra sự cố giữa chừng) $\rightarrow$ Mối quan hệ 1 - N. Nhồi nhét vào `Rentals` sẽ vi phạm Chuẩn 1NF/2NF.
     * **Tránh dữ liệu rác (NULL values):** Hầu hết các chuyến đi an toàn không bị hư hỏng sẽ khiến cột `damage_description` trong `Rentals` bị trống (NULL). Tách bảng giúp tiết kiệm dung lượng lưu trữ và truy vấn sạch sẽ hơn.

2. **Câu hỏi:** *"Nếu muốn quy định: Khi hợp đồng đang ở trạng thái BOOKED thì không ai được phép insert dữ liệu vào bảng `Inspections`, em sẽ dùng cơ chế nào?"*
   * **Trả lời:** Em sử dụng **`BEFORE INSERT TRIGGER`** (`trg_check_inspection_status`) trên bảng `Inspections`. Khi có câu lệnh `INSERT`, Trigger sẽ truy vấn cột `status` của `rental_id` trong bảng `Rentals`. Nếu `status = 'BOOKED'`, Trigger sẽ hủy thao tác và phát ra thông báo lỗi nghiệp vụ bằng lệnh `SIGNAL SQLSTATE '45000'`.

3. **Câu hỏi:** *"Sự thiếu đồng bộ giữa Activity Diagram do BA vẽ và ERD do Dev thiết kế dẫn đến hậu quả gì về mặt trải nghiệm người dùng cuối (UX)?"*
   * **Trả lời:** 
     * **Nhiễu quy trình:** Giao diện ứng dụng không có chỗ cho nhân viên nhập phí phạt hay mô tả lỗi, dẫn đến việc nhân viên phải ghi sổ tay hoặc gọi điện báo kế toán can thiệp thủ công.
     * **Thiếu minh bạch:** Khách hàng nhận hóa đơn không thể hiện rõ lý do bị trừ tiền cọc, gây bức xúc, khiếu nại và làm giảm uy tín thương hiệu.

---

## PHẦN 4: NHẬT KÝ TƯƠNG TÁC AI (ai_prompt_log.md)

| STT | Câu hỏi / Prompt gửi AI | Mục đích & Trợ giúp nhận được từ AI |
| :--- | :--- | :--- |
| **1** | *"Khi lưu trữ dữ liệu tài chính như tiền cọc và tiền phạt trong MySQL, tại sao DECIMAL(10,2) lại tốt hơn FLOAT hoặc DOUBLE?"* | AI giải thích rủi ro sai số làm tròn của `FLOAT`/`DOUBLE` do cách biểu diễn số thực nhị phân. Giúp quyết định dùng `DECIMAL(10,2)` để tính toán số tiền hoàn cọc chính xác tuyệt đối. |
| **2** | *"Nên thiết kế bảng Inspections theo quan hệ 1-1 hay 1-N với bảng Rentals trong bài toán thuê xe tự lái?"* | AI phân tích thực tế: Một hợp đồng có thể kiểm tra lúc bàn giao và kiểm tra lúc nhận lại xe (1-N). Do đó thiết kế 1-N giúp mở rộng tính năng kiểm tra xe đa thời điểm sau này. |
| **3** | *"Cách viết MySQL Trigger để chặn câu lệnh INSERT vào bảng con dựa trên giá trị cột của bảng cha?"* | AI cung cấp cú pháp `BEFORE INSERT TRIGGER` kết hợp `SIGNAL SQLSTATE '45000'` để chủ động kiểm soát quy trình nghiệp vụ ngay từ tầng Database. |