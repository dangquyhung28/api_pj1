FROM python:3.11-slim

# Cài đặt thư viện ODBC cần thiết
RUN apt-get update && apt-get install -y \
    unixodbc \
    libodbc1 \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt các thư viện Python từ requirements.txt
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

# Copy mã nguồn vào Docker container
COPY . /app

# Thiết lập biến môi trường cho Flask
ENV FLASK_APP=app.py

# Cấu hình gunicorn để chạy ứng dụng Flask
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:5000"]
