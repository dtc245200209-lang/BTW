-- ============================================================================
-- DỰ ÁN FLASHMART - TỔNG HỢP TOÀN BỘ BÀI NỘP TRONG 1 FILE SQL DUY NHẤT
-- Data Engineer: Học viên FlashMart
-- File: flashmart_reports.sql
-- ============================================================================

-- ============================================================================
-- PHẦN 1: THIẾT LẬP CƠ SỞ DỮ LIỆU VÀ CHÈN DỮ LIỆU MẪU
-- ============================================================================

CREATE DATABASE IF NOT EXISTS flashmart_db;
USE flashmart_db;

-- Xóa bảng cũ nếu tồn tại để đảm bảo tính độc lập và môi trường sạch
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Products;

-- Tạo cấu trúc các bảng
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

-- Chèn dữ liệu mẫu
INSERT INTO Customers VALUES (1, 'Alice'), (2, 'Bob'), (3, 'Charlie'); 
-- Chú ý: Charlie (customer_id = 3) chưa từng mua hàng.

INSERT INTO Products VALUES (101, 'Laptop'), (102, 'Mouse'), (103, 'Keyboard'); 
-- Chú ý: Keyboard (product_id = 103) chưa từng được mua.

INSERT INTO Orders VALUES (1001, 1, 101), (1002, 1, 102), (1003, 2, 101);


-- ============================================================================
-- PHẦN 2: BÁO CÁO 1 - DÀNH CHO GIÁM ĐỐC MARKETING
-- Yêu cầu: Danh sách tất cả khách hàng kèm số đơn hàng (giữ lại Charlie có 0 đơn)
-- Giải pháp: LEFT JOIN + COUNT(o.order_id)
-- ============================================================================

SELECT 
    c.customer_id, 
    c.name, 
    COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;


-- ============================================================================
-- PHẦN 3: BÁO CÁO 2 - DÀNH CHO GIÁM ĐỐC KHO VẬN (KỸ THUẬT ANTI-JOIN)
-- Yêu cầu: Danh sách sản phẩm chưa từng được bán ra (Sản phẩm ế - Keyboard)
-- Giải pháp: LEFT JOIN + WHERE o.order_id IS NULL
-- ============================================================================

SELECT 
    p.product_id, 
    p.product_name
FROM Products p
LEFT JOIN Orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;


/*
==============================================================================
PHẦN 4: BÁO CÁO GIẢI TRÌNH KỸ THUẬT & PHẦN VẤN ĐÁP BẢO VỆ (JOIN ANALYSIS)
==============================================================================

1. GIẢI TRÌNH VỀ VIỆC SỬ DỤNG COUNT(o.order_id) THAY VÌ COUNT(*):
- Khi dùng LEFT JOIN, các khách hàng chưa mua hàng (như Charlie) vẫn xuất hiện trong
  tập kết quả nhưng các cột bên bảng Orders (như o.order_id) sẽ mang giá trị NULL.
- Nếu dùng COUNT(*): Hàm sẽ đếm TỔNG SỐ DÒNG xuất hiện. Do dòng của Charlie tồn tại 
  (với các giá trị cột Orders là NULL), COUNT(*) sẽ trả về 1 (SAI NGHIỆP VỤ).
- Nếu dùng COUNT(o.order_id): Hàm sẽ đếm các giá trị KHÁC NULL trên cột order_id. 
  Vì order_id của Charlie là NULL nên hàm trả về 0 (ĐÚNG THỰC TẾ).

2. BẢO VỆ LỰA CHỌN - TRẢ LỜI CÁC CÂU HỎI VẤN ĐÁP CỦA CDO:

- Câu hỏi 1: Sự khác biệt giữa INNER JOIN và LEFT JOIN? Nếu đổi thành RIGHT JOIN nhưng giữ nguyên thứ tự các bảng trong truy vấn Marketing thì sao?
  + INNER JOIN: Chỉ lấy phần giao giữa 2 bảng (bản ghi phải khớp ở cả 2 bên). Khách hàng chưa mua hàng sẽ bị loại bỏ hoàn toàn.
  + LEFT JOIN: Lấy toàn bộ bản ghi ở bảng bên trái (Customers). Bản ghi nào bên phải không có sẽ điền NULL.
  + Nếu dùng RIGHT JOIN với thứ tự (Customers c RIGHT JOIN Orders o): Bảng Orders đóng vai trò bảng chính. Truy vấn chỉ trả về những khách hàng ĐÃ CÓ đơn hàng trong bảng Orders. Khách hàng Charlie vẫn tiếp tục bị mất tích.

- Câu hỏi 2: Tại sao điều kiện WHERE o.order_id IS NULL phải đi kèm với LEFT JOIN? Đổi thành INNER JOIN được không?
  + Bản chất của Anti-Join: LEFT JOIN sẽ giữ lại sản phẩm ế và ghép cột order_id bằng NULL. Điều kiện WHERE o.order_id IS NULL lọc ra đúng những sản phẩm ế đó.
  + Nếu đổi thành INNER JOIN: INNER JOIN chỉ lấy các bản ghi khớp (order_id luôn có giá trị khác NULL). Do đó, điều kiện WHERE o.order_id IS NULL sẽ làm kết quả trả về RỖNG HOÀN TOÀN (0 dòng).

- Câu hỏi 3: Cross Join (Cartesian Product) là gì và khi nào vô tình xảy ra?
  + Cross Join (Tích Đề-các): Là phép nhân mọi dòng của bảng A với mọi dòng của bảng B (Tạo ra N x M dòng).
  + Nguyên nhân vô tình: Xảy ra khi viết JOIN nhưng QUÊN KHÔNG KHAI BÁO MỆNH ĐỀ ON (hoặc dùng cú pháp FROM TableA, TableB mà thiếu WHERE). Khi bảng dữ liệu lớn, việc tạo ra hàng triệu dòng sẽ làm cạn kiệt bộ nhớ và gây treo hệ thống.

==============================================================================
PHẦN 5: NHẬT KÝ TƯƠNG TÁC AI (AI PROMPT LOG)
==============================================================================

[PROMPT LOG 1 - HỌC TẬP LÝ THUYẾT SET THEORY VÀ ĐẾM DỮ LIỆU]
- Prompt: "Trong MySQL, khi dùng LEFT JOIN kết hợp GROUP BY, sự khác biệt giữa COUNT(*) và COUNT(bảng_phụ.id) là gì nếu có bản ghi không trùng khớp?"
- AI Response Summary: COUNT(*) đếm tổng số dòng (rows) kể cả dòng chứa NULL. COUNT(column_name) chỉ đếm các dòng chứa giá trị non-NULL. Với LEFT JOIN, muốn đếm số lượng bản ghi ghép nối chuẩn xác cần dùng COUNT(bảng_phụ.primary_key).

[PROMPT LOG 2 - PHÂN TÍCH HIỆU NĂNG ANTI-JOIN]
- Prompt: "So sánh hiệu năng giữa LEFT JOIN ... WHERE IS NULL và Subquery NOT IN / NOT EXISTS trong MySQL 8.0."
- AI Response Summary: MySQL 8.0 Optimizer sẽ tối ưu hóa `LEFT JOIN ... WHERE IS NULL` và `NOT EXISTS` tương đương nhau thông qua thuật toán Anti-Join. `NOT IN` có thể gặp vấn đề hiệu năng và lỗi logic nếu danh sách con chứa giá trị NULL.

[PROMPT LOG 3 - TỐI ƯU HÓA HỆ THỐNG CSDL]
- Prompt: "MySQL sử dụng thuật toán gì để thực thi các câu lệnh JOIN?"
- AI Response Summary: MySQL sử dụng các thuật toán Nested-Loop Join (NLJ), Block Nested-Loop (BNL) và Hash Join (từ bản 8.0.18+) tùy thuộc vào việc có sử dụng Index trên các cột ghép nối hay không.
==============================================================================
*/