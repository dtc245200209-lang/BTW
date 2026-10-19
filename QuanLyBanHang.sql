-- BAI TAP: THAO TAC VOI CSDL QUAN LY BAN HANG
-- MySQL
-- Neu da them du lieu truoc do, bo qua phan 1 de tranh trung khoa chinh.

USE QuanLyBanHang;

-- 1. THEM DU LIEU VAO 4 BANG

INSERT INTO Customer (cID, Name, cAge) VALUES
(1, 'Minh Quan', 10),
(2, 'Ngoc Oanh', 20),
(3, 'Hong Ha', 50);

INSERT INTO `Order` (oID, cID, oDate, oTotalPrice) VALUES
(1, 1, '2006-03-21', NULL),
(2, 2, '2006-03-23', NULL),
(3, 1, '2006-03-16', NULL);

INSERT INTO Product (pID, pName, pPrice) VALUES
(1, 'May Giat', 3),
(2, 'Tu Lanh', 5),
(3, 'Dieu Hoa', 7),
(4, 'Quat', 1),
(5, 'Bep Dien', 2);

INSERT INTO OrderDetail (oID, pID, odQTY) VALUES
(1, 1, 3),
(1, 3, 7),
(1, 4, 2),
(2, 1, 3),
(2, 5, 4),
(2, 3, 3);

-- 2. HIEN THI MA HOA DON, NGAY MUA VA TONG TIEN

SELECT oID, oDate, oTotalPrice
FROM `Order`;

-- 3. HIEN THI KHACH HANG DA MUA HANG VA SAN PHAM DUOC MUA

SELECT DISTINCT Customer.Name, Product.pName
FROM Customer
JOIN `Order` ON Customer.cID = `Order`.cID
JOIN OrderDetail ON `Order`.oID = OrderDetail.oID
JOIN Product ON OrderDetail.pID = Product.pID;

-- 4. HIEN THI TEN KHACH HANG CHUA MUA BAT KY SAN PHAM NAO

SELECT Customer.Name
FROM Customer
WHERE NOT EXISTS (
    SELECT 1
    FROM `Order`
    JOIN OrderDetail ON `Order`.oID = OrderDetail.oID
    WHERE `Order`.cID = Customer.cID
);

-- 5. HIEN THI MA HOA DON, NGAY BAN VA TONG GIA TRI TUNG HOA DON
-- Gia tri = SUM(so luong * don gia)

SELECT `Order`.oID,
       `Order`.oDate,
       SUM(OrderDetail.odQTY * Product.pPrice) AS oPrice
FROM `Order`
JOIN OrderDetail ON `Order`.oID = OrderDetail.oID
JOIN Product ON OrderDetail.pID = Product.pID
GROUP BY `Order`.oID, `Order`.oDate
ORDER BY `Order`.oID;

-- 6. TUY CHON: CAP NHAT TONG TIEN VAO COT oTotalPrice
-- Chi chay neu muon luu tong tien vao bang Order.

UPDATE `Order`
SET oTotalPrice = (
    SELECT SUM(OrderDetail.odQTY * Product.pPrice)
    FROM OrderDetail
    JOIN Product ON OrderDetail.pID = Product.pID
    WHERE OrderDetail.oID = `Order`.oID
)
WHERE EXISTS (
    SELECT 1
    FROM OrderDetail
    WHERE OrderDetail.oID = `Order`.oID
);

-- KIEM TRA LAI DU LIEU
SELECT oID, oDate, oTotalPrice
FROM `Order`;
