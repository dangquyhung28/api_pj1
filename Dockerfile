FROM python:3.11-slim

# Cài đặt các thư viện hệ thống cơ bản và Microsoft ODBC Driver
RUN apt-get update && apt-get install -y \
    unixodbc \
    libodbc1 \
    curl \
    gnupg \
    apt-transport-https \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && echo "deb [arch=amd64] https://packages.microsoft.com/debian/10/prod buster main" > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy file requirements.txt vào container và cài đặt thư viện Python
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

# Copy mã nguồn vào container
COPY . /app

# Thiết lập biến môi trường cho Flask
ENV FLASK_APP=app.py

# Cấu hình gunicorn để chạy ứng dụng Flask
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:5000"]
