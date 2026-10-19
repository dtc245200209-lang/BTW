-- Bước 1: Chọn cơ sở dữ liệu QuanLySinhVien
USE QuanLySinhVien;

-- Yêu cầu 1 (Bước 2): Hiển thị số lượng sinh viên ở từng nơi (theo Address)
SELECT Address, COUNT(StudentId) AS 'Số lượng học viên'
FROM Student
GROUP BY Address;

-- Yêu cầu 2 (Bước 3): Tính điểm trung bình các môn học của mỗi học viên
SELECT S.StudentId, S.StudentName, AVG(Mark) AS 'Điểm trung bình'
FROM Student S 
JOIN Mark M ON S.StudentId = M.StudentId
GROUP BY S.StudentId, S.StudentName;

-- Yêu cầu 3 (Bước 4): Hiển thị những bạn học viên có điểm trung bình các môn học lớn hơn 15
SELECT S.StudentId, S.StudentName, AVG(Mark) AS 'Điểm trung bình'
FROM Student S 
JOIN Mark M ON S.StudentId = M.StudentId
GROUP BY S.StudentId, S.StudentName
HAVING AVG(Mark) > 15;

-- Yêu cầu 4 (Bước 5): Hiển thị thông tin các học viên có điểm trung bình lớn nhất
SELECT S.StudentId, S.StudentName, AVG(Mark) AS 'Điểm trung bình lớn nhất'
FROM Student S 
JOIN Mark M ON S.StudentId = M.StudentId
GROUP BY S.StudentId, S.StudentName
HAVING AVG(Mark) >= ALL (SELECT AVG(Mark) FROM Mark GROUP BY Mark.StudentId);