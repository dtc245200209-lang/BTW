# BÁO CÁO CHUYỂN ĐỔI SƠ ĐỒ ERD SANG MÔ HÌNH DỮ LIỆU QUAN HỆ

**Bài tập:** Quản lý đơn đặt hàng  
**Đường dẫn Repository GitHub:** [https://github.com/dtc245200209-lang/BTW](https://github.com/dtc245200209-lang/BTW)  

---

## 1. Xác định các thực thể trong mô hình ERD

Dựa trên sơ đồ ERD quản lý đơn đặt hàng đã chuẩn hóa, hệ thống bao gồm 8 thực thể chính:

1. **ĐƠN_VI_KHÁCH**: Đơn vị / tổ chức bên ngoài giao dịch với phòng khám / cửa hàng.
2. **NGƯỜI_ĐẶT**: Cá nhân đại diện thực hiện đặt hàng.
3. **NGƯỜI_NHẬN**: Cá nhân đại diện nhận hàng.
4. **NGƯỜI_GIAO**: Nhân viên thực hiện giao hàng.
5. **NƠI_GIAO**: Địa điểm giao hàng.
6. **HÀNG**: Danh mục mặt hàng / sản phẩm.
7. **ĐƠN_ĐẶT_HÀNG**: Thông tin tổng quan của đơn đặt hàng.
8. **PHIẾU_GIAO_HÀNG**: Thông tin tổng quan của phiếu giao hàng.

---

## 2. Xác định mối quan hệ và nguyên tắc chuyển đổi

### a. Mối quan hệ 1 - N (Một - Nhiều)
*Thêm khóa chính của thực thể bên nhánh (1) vào làm khóa ngoại (FK) ở thực thể bên nhánh (N):*

* **ĐƠN_VI_KHÁCH (1) - (N) NGƯỜI_ĐẶT**: Bổ sung khóa ngoại `MaDV` vào bảng `NGUOI_DAT`.
* **ĐƠN_VI_KHÁCH (1) - (N) NGƯỜI_NHẬN**: Bổ sung khóa ngoại `MaDV` vào bảng `NGUOI_NHAN`.
* **NGƯỜI_ĐẶT (1) - (N) ĐƠN_ĐẶT_HÀNG**: Bổ sung khóa ngoại `MaSoND` vào bảng `DON_DAT_HANG`.
* **NGƯỜI_GIAO (1) - (N) PHIẾU_GIAO_HÀNG**: Bổ sung khóa ngoại `MaSoNG` vào bảng `PHIEU_GIAO_HANG`.
* **NGƯỜI_NHẬN (1) - (N) PHIẾU_GIAO_HÀNG**: Bổ sung khóa ngoại `MaSoNN` vào bảng `PHIEU_GIAO_HANG`.
* **NƠI_GIAO (1) - (N) PHIẾU_GIAO_HÀNG**: Bổ sung khóa ngoại `MaSoDDG` vào bảng `PHIEU_GIAO_HANG`.

### b. Mối quan hệ N - M (Nhiều - Nhiều)
*Tạo bảng quan hệ trung gian chứa khóa chính của cả 2 thực thể hợp thành Khóa chính phức hợp (Composite Primary Key):*

* **ĐƠN_ĐẶT_HÀNG (N) - (M) HÀNG**: Tạo bảng `CHITIET_DON_DAT` chứa (`SoDH`, `MaHang`, `SoLuong`).
* **PHIẾU_GIAO_HÀNG (N) - (M) HÀNG**: Tạo bảng `CHITIET_PHIEU_GIAO` chứa (`SoPG`, `MaHang`, `SoLuong`, `DonGia`, `ThanhTien`).

---

## 3. Danh sách các bảng sau khi chuyển đổi (Mô hình quan hệ)

*(Ghi chú: **In đậm** = Khóa chính - PK, *In nghiêng* = Khóa ngoại - FK)*

1. **DON_VI_KHACH** (**MaDV**, TenDV, DiaChi, DienThoai)
2. **NGUOI_DAT** (**MaSoND**, HoTenND, *MaDV*)
3. **NGUOI_NHAN** (**MaSoNN**, HoTenNN, *MaDV*)
4. **NGUOI_GIAO** (**MaSoNG**, HoTenNG)
5. **NOI_GIAO** (**MaSoDDG**, TenNoiGiao)
6. **HANG** (**MaHang**, TenHang, DvTinh, MoTaHang)
7. **DON_DAT_HANG** (**SoDH**, NgayDat, *MaSoND*)
8. **CHITIET_DON_DAT** (**SoDH**, **MaHang**, SoLuong)
9. **PHIEU_GIAO_HANG** (**SoPG**, NgayGiao, *MaSoNG*, *MaSoNN*, *MaSoDDG*)
10. **CHITIET_PHIEU_GIAO** (**SoPG**, **MaHang**, SoLuong, DonGia, ThanhTien)

---

## 4. Mã SQL Khởi tạo cấu trúc bảng (DDL)

```sql
CREATE TABLE DON_VI_KHACH (
    MaDV VARCHAR(50) PRIMARY KEY,
    TenDV NVARCHAR(255) NOT NULL,
    DiaChi NVARCHAR(255),
    DienThoai VARCHAR(20)
);

CREATE TABLE NGUOI_DAT (
    MaSoND VARCHAR(50) PRIMARY KEY,
    HoTenND NVARCHAR(100) NOT NULL,
    MaDV VARCHAR(50),
    FOREIGN KEY (MaDV) REFERENCES DON_VI_KHACH(MaDV)
);

CREATE TABLE NGUOI_NHAN (
    MaSoNN VARCHAR(50) PRIMARY KEY,
    HoTenNN NVARCHAR(100) NOT NULL,
    MaDV VARCHAR(50),
    FOREIGN KEY (MaDV) REFERENCES DON_VI_KHACH(MaDV)
);

CREATE TABLE NGUOI_GIAO (
    MaSoNG VARCHAR(50) PRIMARY KEY,
    HoTenNG NVARCHAR(100) NOT NULL
);

CREATE TABLE NOI_GIAO (
    MaSoDDG VARCHAR(50) PRIMARY KEY,
    TenNoiGiao NVARCHAR(255) NOT NULL
);

CREATE TABLE HANG (
    MaHang VARCHAR(50) PRIMARY KEY,
    TenHang NVARCHAR(255) NOT NULL,
    DvTinh NVARCHAR(50),
    MoTaHang NVARCHAR(500)
);

CREATE TABLE DON_DAT_HANG (
    SoDH VARCHAR(50) PRIMARY KEY,
    NgayDat DATE,
    MaSoND VARCHAR(50),
    FOREIGN KEY (MaSoND) REFERENCES NGUOI_DAT(MaSoND)
);

CREATE TABLE CHITIET_DON_DAT (
    SoDH VARCHAR(50),
    MaHang VARCHAR(50),
    SoLuong INT NOT NULL,
    PRIMARY KEY (SoDH, MaHang),
    FOREIGN KEY (SoDH) REFERENCES DON_DAT_HANG(SoDH),
    FOREIGN KEY (MaHang) REFERENCES HANG(MaHang)
);

CREATE TABLE PHIEU_GIAO_HANG (
    SoPG VARCHAR(50) PRIMARY KEY,
    NgayGiao DATE,
    MaSoNG VARCHAR(50),
    MaSoNN VARCHAR(50),
    MaSoDDG VARCHAR(50),
    FOREIGN KEY (MaSoNG) REFERENCES NGUOI_GIAO(MaSoNG),
    FOREIGN KEY (MaSoNN) REFERENCES NGUOI_NHAN(MaSoNN),
    FOREIGN KEY (MaSoDDG) REFERENCES NOI_GIAO(MaSoDDG)
);

CREATE TABLE CHITIET_PHIEU_GIAO (
    SoPG VARCHAR(50),
    MaHang VARCHAR(50),
    SoLuong INT NOT NULL,
    DonGia DECIMAL(18,2),
    ThanhTien DECIMAL(18,2),
    PRIMARY KEY (SoPG, MaHang),
    FOREIGN KEY (SoPG) REFERENCES PHIEU_GIAO_HANG(SoPG),
    FOREIGN KEY (MaHang) REFERENCES HANG(MaHang)
);
```