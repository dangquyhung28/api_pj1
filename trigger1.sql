-- TRigger


Drop trigger trg_InsertKhachHangFromUser
CREATE TRIGGER trg_InsertFromUser
ON tbUser
AFTER INSERT
AS
BEGIN
    DECLARE @SĐT INT;
    DECLARE @Email NVARCHAR(50);
    DECLARE @Type INT;
    DECLARE @newMaKH NVARCHAR(50);
    DECLARE @newMaNV NVARCHAR(50);
    DECLARE @maxSoThuTuKH INT;
    DECLARE @maxSoThuTuNV INT;

    -- Lấy thông tin từ bản ghi mới được chèn vào bảng tbUser
    SELECT @SĐT = i.SĐT, @Email = i.PassWord, @Type = i.[Type]
    FROM inserted i;

    -- Nếu Type = 1, chèn vào bảng tbKhachHang
    IF @Type = 1
    BEGIN
        -- Lấy số thứ tự lớn nhất hiện tại từ tbKhachHang
        SELECT @maxSoThuTuKH = ISNULL(MAX(CAST(SUBSTRING(MaKH, 3, LEN(MaKH) - 2) AS INT)), 0)
        FROM tbKhachHang;

        -- Tạo MaKH mới: 'KH' + số thứ tự lớn nhất + 1
        SET @newMaKH = 'KH' + CAST(@maxSoThuTuKH + 1 AS NVARCHAR(50));

        -- Thêm khách hàng mới vào bảng tbKhachHang
        INSERT INTO tbKhachHang (MaKH, SĐT, Email)
        VALUES (@newMaKH, @SĐT, @Email);
    END
    -- Nếu Type = 0, chèn vào bảng tbNhanVien
    ELSE IF @Type = 0
    BEGIN
        -- Lấy số thứ tự lớn nhất hiện tại từ tbNhanVien
        SELECT @maxSoThuTuNV = ISNULL(MAX(CAST(SUBSTRING(MaNV, 3, LEN(MaNV) - 2) AS INT)), 0)
        FROM tbNhanVien;

        -- Tạo MaNV mới: 'NV' + số thứ tự lớn nhất + 1
        SET @newMaNV = 'NV' + CAST(@maxSoThuTuNV + 1 AS NVARCHAR(50));

        -- Thêm nhân viên mới vào bảng tbNhanVien
        INSERT INTO tbNhanVien (MaNV, SĐT, Email)
        VALUES (@newMaNV, @SĐT, @Email);
    END
END;

INSERT INTO tbUser (SĐT, PassWord, [Type])
VALUES (123, 'password123', 0);
Select * from tbKhachHang
Select * from tbNhanVien
Select * from tbUser

-- thêm danh mục
CREATE TRIGGER trg_InsertDanhMuc
ON tbSanPham
AFTER INSERT
AS
BEGIN
    DECLARE @MaDanhMuc NVARCHAR(50);
    DECLARE @TenDanhMuc NVARCHAR(100);

    -- Lặp qua tất cả các bản ghi mới được chèn vào bảng SanPham
    DECLARE cur CURSOR FOR
    SELECT i.MaDanhMuc, d.TenDanhMuc
    FROM inserted i
    LEFT JOIN tbDanhMuc d ON i.MaDanhMuc = d.MaDanhMuc
    WHERE d.MaDanhMuc IS NULL; -- Chỉ thêm nếu MaDanhMuc chưa tồn tại trong bảng DanhMuc

    OPEN cur;

    FETCH NEXT FROM cur INTO @MaDanhMuc, @TenDanhMuc;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Thêm dữ liệu vào bảng DanhMuc
        INSERT INTO tbDanhMuc (MaDanhMuc, TenDanhMuc)
        VALUES (@MaDanhMuc, 'Danh mục mới');

        FETCH NEXT FROM cur INTO @MaDanhMuc, @TenDanhMuc;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;

--						San Pham
--Hien thi san pham theo danh muc
CREATE PROCEDURE GetSanPhamByMaDanhMuc
    @MaDanhMuc NVARCHAR(50)  -- Tham số đầu vào
AS
BEGIN
    SET NOCOUNT ON;  -- Ngăn chặn thông báo số dòng bị ảnh hưởng

    SELECT 
        sp.MaSP,
        sp.TenSP,
        sp.MoTa,
        sp.GiaBan,
        sp.GiaNhap,
        sp.SL
    FROM 
        tbSanPham sp
    WHERE 
        sp.MaDanhMuc = @MaDanhMuc;  -- Lọc theo MaDanhMuc
END;
EXEC GetSanPhamByMaDanhMuc @MaDanhMuc = 'BB';
-- Truy vấn thông tin chi tiết của một sản phẩm cụ thể.
CREATE PROCEDURE GetChiTietSanPham
    @MaSP NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Truy vấn thông tin chi tiết của sản phẩm
    SELECT 
        sp.MaSP,
        sp.TenSP,
        sp.MoTa,
        sp.GiaBan,
        sp.MaDanhMuc,
        sp.SL,
        dm.TenDanhMuc
    FROM 
        tbSanPham sp
    INNER JOIN 
        tbDanhMuc dm ON sp.MaDanhMuc = dm.MaDanhMuc
    WHERE 
        sp.MaSP = @MaSP;
END;
-- Insert sản phẩm mới
drop procedure InsertNewSanPhamAndDetails
CREATE PROCEDURE InsertNewSanPhamAndDetails
    @TenSP NVARCHAR(100),
    @MoTa NVARCHAR(255),
    @GiaBan DECIMAL(18, 2),
    @GiaNhap DECIMAL(18, 2),
    --@MaDanhMuc NVARCHAR(50),
    @SoLuong INT
   /* @MaNCC NVARCHAR(50),   -- Nhà cung cấp
    @MaNV NVARCHAR(50),    -- Nhân viên nhập hóa đơn
    @NgayLap DATE,         -- Ngày lập hóa đơn nhập
    @SoLuongNhap INT       -- Số lượng nhập vào kho*/
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

       /* -- 1. Kiểm tra sự tồn tại của MaDanhMuc và MaNCC
        IF NOT EXISTS (SELECT 1 FROM tbDanhMuc WHERE MaDanhMuc = @MaDanhMuc)
        BEGIN
            RAISERROR('Mã danh mục không tồn tại.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM tbNhaCungCap WHERE MaNCC = @MaNCC)
        BEGIN
            RAISERROR('Mã nhà cung cấp không tồn tại.', 16, 1);
            RETURN;
        END*/

        -- 2. Thêm sản phẩm mới vào bảng tbSanPham
        DECLARE @NewMaSP NVARCHAR(50);
		DECLARE @NextID NVARCHAR(2);

		-- Tính toán giá trị stt cho MaSP mới
		SET @NextID = RIGHT('00' + CAST((SELECT ISNULL(MAX(CAST(SUBSTRING(MaSP, 3, LEN(MaSP) - 2) AS INT)), 0) + 1 from tbSanPham )AS NVARCHAR), 2) ;

		-- Kết hợp với tiền tố "SP" để tạo mã sản phẩm mới
		SET @NewMaSP = 'SP' + @NextID;



        INSERT INTO tbSanPham (MaSP, TenSP, MoTa, GiaBan, GiaNhap, MaDanhMuc, SL)
        VALUES (@NewMaSP, @TenSP, @MoTa, @GiaBan, @GiaNhap, @SoLuong);

        -- 3. Tạo hóa đơn nhập mới trong bảng tbHoaDonNhap
        DECLARE @NewMaHDN NVARCHAR(50);
		DECLARE @NextHDNID NVARCHAR(2);

		-- Calculate the next ID in two-digit format for MaHDN
		SET @NextHDNID = RIGHT('00' + CAST((SELECT ISNULL(MAX(CAST(SUBSTRING(MaHDN, 4, LEN(MaHDN) - 3) AS INT)), 0) + 1 FROM tbHoaDonNhap) AS NVARCHAR), 2);

		-- Combine with the "HDN" prefix to create the new MaHDN
		SET @NewMaHDN = 'HDN' + @NextHDNID;

        INSERT INTO tbHoaDonNhap (MaHDN, NgayLap, MaNV, MaNCC, TongTien)
        VALUES (@NewMaHDN, @GiaNhap * @SoLuong);

        -- 4. Thêm chi tiết hóa đơn nhập vào bảng tbChiTietHoaDonNhap
        INSERT INTO tbChiTietHoaDonNhap (MaHDN, MaSP, SL)
        VALUES (@NewMaHDN, @NewMaSP, @SoLuong);

        -- 5. Cập nhật số lượng tồn kho (SL) trong bảng tbSanPham
        UPDATE tbSanPham
        SET SL = SL + @SoLuong
        WHERE MaSP = @NewMaSP;

        -- Hoàn tất giao dịch
        COMMIT TRANSACTION;

        PRINT 'Sản phẩm và chi tiết hóa đơn đã được thêm thành công';

    END TRY
    BEGIN CATCH
        -- Nếu có lỗi, rollback giao dịch
        ROLLBACK TRANSACTION;
        RAISERROR('Có lỗi xảy ra trong quá trình thêm sản phẩm và chi tiết hóa đơn.', 16, 1);
    END CATCH
END;
drop procedure InsertNewSanPhamtoMenu
CREATE PROCEDURE InsertNewSanPhamtoMenu
    @TenSP NVARCHAR(100),
    @MoTa NVARCHAR(255),
    @GiaBan DECIMAL(18, 2),
    @GiaNhap DECIMAL(18, 2),
    @SLNhap INT       -- Số lượng nhập vào kho
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Generate new MaSP
        DECLARE @NewMaSP NVARCHAR(50);
        DECLARE @NextID NVARCHAR(2);

        -- Calculate the next ID for MaSP
        SET @NextID = RIGHT('00' + CAST((SELECT ISNULL(MAX(CAST(SUBSTRING(MaSP, 3, LEN(MaSP) - 2) AS INT)), 0) + 1 FROM tbSanPham) AS NVARCHAR), 2);

        -- Combine with the "SP" prefix to create a new MaSP
        SET @NewMaSP = 'SP' + @NextID;

        -- 2. Insert the new product with the specified fields
        INSERT INTO tbSanPham (MaSP, TenSP, MoTa, GiaBan, GiaNhap, SL)
        VALUES (@NewMaSP, @TenSP, @MoTa, @GiaBan, @GiaNhap, @SLNhap);

        -- Commit the transaction
        COMMIT TRANSACTION;

        PRINT 'Product has been added successfully with the specified fields';

    END TRY
    BEGIN CATCH
        -- Rollback the transaction if there's an error
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
EXEC InsertNewSanPhamtoMenu
    @TenSP = N'Bim Bim Hung',
    @MoTa = N'Snack gồm những miếng bánh phồng giòn rụm, thơm vị mực, mang lại cho bé cảm giác ngon miệng, thích thú khi ăn',
    @GiaBan = 5000,
    @GiaNhap = 4000,
    @SLNhap = 200
select *from tbSanPham
-- Update sản phẩm
drop procedure UpdateSanPham
CREATE PROCEDURE UpdateSanPham
    @MaSP NVARCHAR(50),        -- Mã sản phẩm cần cập nhật
    @TenSP NVARCHAR(100),       -- Tên sản phẩm mới
    @MoTa NVARCHAR(255),        -- Mô tả mới
    @GiaBan DECIMAL(18, 2),     -- Giá bán mới
    @GiaNhap DECIMAL(18, 2),    -- Giá nhập mới
    @MaDanhMuc NVARCHAR(50),    -- Mã danh mục mới
    @SoLuong INT                -- Số lượng mới
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Kiểm tra xem sản phẩm với MaSP có tồn tại hay không
        IF NOT EXISTS (SELECT 1 FROM tbSanPham WHERE MaSP = @MaSP)
        BEGIN
            RAISERROR('Sản phẩm không tồn tại.', 16, 1);
            RETURN;
        END

        -- 2. Cập nhật thông tin sản phẩm
        UPDATE tbSanPham
        SET TenSP = @TenSP,
            MoTa = @MoTa,
            GiaBan = @GiaBan,
            GiaNhap = @GiaNhap,
            MaDanhMuc = @MaDanhMuc,
            SL = @SoLuong
        WHERE MaSP = @MaSP;

        -- Hoàn tất giao dịch
        COMMIT TRANSACTION;

        PRINT 'Cập nhật sản phẩm thành công';

    END TRY
    BEGIN CATCH
        -- Nếu có lỗi, rollback giao dịch
        ROLLBACK TRANSACTION;
        RAISERROR('Có lỗi xảy ra trong quá trình cập nhật sản phẩm.', 16, 1);
    END CATCH
END;
EXEC UpdateSanPham
	@MaSP= 'SP05',
    @TenSP = N'Cafe Sữa',
    @MoTa = N'Thơm ngon',
    @GiaBan = 10000,
    @GiaNhap = 8000,
	@MaDanhMuc = 'DM02',
    @SoLuong = 200

-- delete San Pham
Drop PROCEDURE DeleteSanPham

CREATE PROCEDURE DeleteSanPham
    @MaSP NVARCHAR(50)   -- Mã sản phẩm cần xóa
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Kiểm tra nếu sản phẩm có tồn tại
        IF NOT EXISTS (SELECT 1 FROM tbSanPham WHERE MaSP = @MaSP)
        BEGIN
            RAISERROR('Sản phẩm không tồn tại.', 16, 1);
            RETURN;
        END

        -- Xóa dữ liệu ảnh liên quan đến sản phẩm
        DELETE FROM tbAnhSanPham WHERE MaSP = @MaSP;

        -- Xóa sản phẩm khỏi bảng chính (tbSanPham)
        DELETE FROM tbSanPham WHERE MaSP = @MaSP;

        -- Hoàn tất giao dịch
        COMMIT TRANSACTION;

        PRINT 'Xóa sản phẩm thành công';

    END TRY
    BEGIN CATCH
        -- Rollback nếu có lỗi xảy ra
        ROLLBACK TRANSACTION;
        RAISERROR('Có lỗi xảy ra trong quá trình xóa sản phẩm.', 16, 1);
    END CATCH
END;
exec DeleteSanPham
	@MaSP = 'SP05'

-- tim kiem san pham theo từ khoá tên sản phẩm
CREATE PROCEDURE SearchSanPhamByName
    @TenSP NVARCHAR(100)  -- Tham số đầu vào để tìm kiếm theo tên sản phẩm
AS
BEGIN
    SET NOCOUNT ON;  -- Ngăn không hiển thị thông báo ảnh hưởng số dòng

    -- Truy vấn tìm kiếm sản phẩm theo tên
    SELECT 
        sp.MaSP,
        sp.TenSP,
        sp.MoTa,
        sp.GiaBan,
        sp.GiaNhap,
        sp.SL,
        sp.MaDanhMuc
		
    FROM 
        tbSanPham sp
    WHERE 
        TenSP LIKE '%' + @TenSP + '%'  -- Tìm kiếm theo chuỗi con
END;
EXEC DeleteSanPham @MaSP = 'SP01';

EXEC SearchSanPhamByName @TenSP = 'Oishi';
drop PROCEDURE SearchSanPhamByName
-- procedure truyền vào mã sản phẩm thì trả về ảnh sản phẩm đó 
CREATE PROCEDURE GetAnhSanPhamByMaSP
    @MaSP NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Truy vấn lấy ảnh của sản phẩm theo MaSP
    SELECT 
        sp.MaSP,
        sp.TenSP,
        asp.TenFileAnh,
        asp.IdAnh
    FROM 
        tbSanPham sp
    INNER JOIN 
        tbAnhSanPham asp ON sp.MaSP = asp.MaSP
    WHERE 
        sp.MaSP = @MaSP;
END;
EXEC GetAnhSanPhamByMaSP @MaSP='SP01'
