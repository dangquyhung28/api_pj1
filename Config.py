import pyodbc

# Tạo chuỗi kết nối cho SQL Server trên Google Cloud
con_str = (
    "Driver={ODBC Driver 17 for SQL Server};"  # Driver bạn đã cài đặt
    "Server=qlbanhangeateasy.c7ioueoo2lo7.ap-southeast-2.rds.amazonaws.com;"  # Public IP address của SQL Server trên Google Cloud
    "Database=QLBanHangEatEasy;"  # Tên database của bạn
    "UID=admin;"  # Tên user
    "PWD=Admin6969;"  # Mật khẩu
    "Encrypt=yes;"  # Mã hóa kết nối
    "TrustServerCertificate=yes;"  # Chấp nhận chứng chỉ máy chủ
)

# # Kết nối tới SQL Server
# conn = pyodbc.connect(con_str)

# # Tạo cursor để truy vấn cơ sở dữ liệu
# cursor = conn.cursor()
