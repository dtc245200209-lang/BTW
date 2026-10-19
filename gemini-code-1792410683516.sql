-- ============================================================================
-- BÀI THỰC HÀNH: THÊM DỮ LIỆU VÀO CSDL QUẢN LÝ SINH VIÊN (INSERT INTO)
-- ============================================================================

-- BƯỚC 1: ĐẢM BẢO CSDL ĐÃ ĐƯỢC CHỌN ĐỂ THAO TÁC
USE `QuanLySinhVien`;

-- BƯỚC 2: THÊM DỮ LIỆU VÀO BẢNG Class (Lớp học)
-- Lưu ý: Sử dụng CURRENT_DATE cho ngày khởi tạo của lớp B3
INSERT INTO `Class` (`ClassID`, `ClassName`, `StartDate`, `Status`)
VALUES 
    (1, 'A1', '2008-12-20', 1),
    (2, 'A2', '2008-12-22', 1),
    (3, 'B3', CURRENT_DATE, 0);

-- BƯỚC 3: THÊM DỮ LIỆU VÀO BẢNG Student (Sinh viên)
-- Lưu ý: Sinh viên 'Hoa' không có số điện thoại nên bỏ qua cột Phone (giá trị mặc định sẽ là NULL)
INSERT INTO `Student` (`StudentName`, `Address`, `Phone`, `Status`, `ClassId`)
VALUES ('Hung', 'Ha Noi', '0912113113', 1, 1);

INSERT INTO `Student` (`StudentName`, `Address`, `Status`, `ClassId`)
VALUES ('Hoa', 'Hai phong', 1, 1);

INSERT INTO `Student` (`StudentName`, `Address`, `Phone`, `Status`, `ClassId`)
VALUES ('Manh', 'HCM', '0123123123', 0, 2);

-- BƯỚC 4: THÊM DỮ LIỆU NHANH VÀO BẢNG Subject (Môn học)
-- Thêm nhiều bản ghi trong cùng một câu lệnh INSERT INTO
INSERT INTO `Subject` (`SubID`, `SubName`, `Credit`, `Status`)
VALUES 
    (1, 'CF', 5, 1),
    (2, 'C', 6, 1),
    (3, 'HDJ', 5, 1),
    (4, 'RDBMS', 10, 1);

-- BƯỚC 5: THÊM DỮ LIỆU VÀO BẢNG Mark (Điểm thi)
INSERT INTO `Mark` (`SubId`, `StudentId`, `Mark`, `ExamTimes`)
VALUES 
    (1, 1, 8, 1),
    (1, 2, 10, 2),
    (2, 1, 12, 1);

-- ============================================================================
-- TRUY VẤN KIỂM TRA DỮ LIỆU SAU KHI THÊM
-- ============================================================================
SELECT * FROM `Class`;
SELECT * FROM `Student`;
SELECT * FROM `Subject`;
SELECT * FROM `Mark`;