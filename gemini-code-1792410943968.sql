-- ============================================================================
-- BÀI THỰC HÀNH: TRUY VẤN DỮ LIỆU CƠ BẢN VÀ JOIN BẢNG (SELECT QUERIES)
-- ============================================================================

-- BƯỚC 1: Chọn CSDL làm việc
USE `QuanLySinhVien`;

-- BƯỚC 2: Hiển thị danh sách tất cả các học viên
SELECT *
FROM `Student`;

-- BƯỚC 3: Hiển thị danh sách các học viên đang theo học (Status = true/1)
SELECT *
FROM `Student`
WHERE `Status` = true;

-- BƯỚC 4: Hiển thị danh sách các môn học có thời gian học (Credit) nhỏ hơn 10
SELECT *
FROM `Subject`
WHERE `Credit` < 10;

-- BƯỚC 5: Hiển thị danh sách học viên thuộc lớp 'A1' (Liên kết bảng Student và Class)
SELECT S.StudentId, S.StudentName, C.ClassName
FROM `Student` S 
JOIN `Class` C ON S.ClassId = C.ClassID
WHERE C.ClassName = 'A1';

-- BƯỚC 6: Hiển thị điểm môn 'CF' của các học viên (Liên kết 3 bảng: Student, Mark, Subject)
SELECT S.StudentId, S.StudentName, Sub.SubName, M.Mark
FROM `Student` S 
JOIN `Mark` M ON S.StudentId = M.StudentId 
JOIN `Subject` Sub ON M.SubId = Sub.SubId
WHERE Sub.SubName = 'CF';