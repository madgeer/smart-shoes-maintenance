# Gunakan image Python yang ringan sebagai base image
FROM python:3.11-slim

# Atur working directory di dalam container
WORKDIR /workspace

# Pasang dependensi sistem yang mungkin dibutuhkan untuk kompilasi C (jika ada)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Salin file requirements.txt ke dalam container
COPY requirements.txt .

# Instal dependensi Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Salin folder aplikasi utama (app) dan model yang sudah dilatih (trained_model)
COPY app/ ./app/
COPY trained_model/ ./trained_model/

# Set environment variable untuk Python agar tidak menulis file pyc ke disk dan buffer output langsung dikirim
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Buka port 8000 untuk akses API
EXPOSE 8000

# Jalankan server FastAPI menggunakan Uvicorn di semua antarmuka jaringan (0.0.0.0)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
