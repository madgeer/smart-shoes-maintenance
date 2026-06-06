# Smart Shoes Maintenance - API Documentation

Dokumen ini menjelaskan spesifikasi API (Application Programming Interface) untuk sistem Smart Shoes Maintenance. Sistem ini terbagi menjadi dua bagian utama: Gateway Service (Node.js/Express) untuk manajemen data dan user, serta ML Service (FastAPI) untuk inferensi model machine learning.

Semua request dan response menggunakan format JSON.

---

## 1. Gateway Service API (Node.js)

Gateway Service melayani permintaan dari Dashboard React serta bertindak sebagai perantara data sensor. Base URL untuk Gateway Service ditentukan pada konfigurasi env Anda (default: `http://localhost:3000/api/v1`).

### A. Autentikasi Pengguna

#### Register User
Mendaftarkan akun pengguna baru ke dalam sistem.
* **HTTP Method**: POST
* **Endpoint**: `/auth/register`
* **Request Body**:
```json
{
  "name": "John Doe",
  "email": "johndoe@example.com",
  "password": "securepassword123"
}
```
* **Success Response (201 Created)**:
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "johndoe@example.com",
    "created_at": "2026-05-22T11:00:00.000Z"
  }
}
```

#### Login User
Melakukan autentikasi pengguna dan mengembalikan token akses JWT.
* **HTTP Method**: POST
* **Endpoint**: `/auth/login`
* **Request Body**:
```json
{
  "email": "johndoe@example.com",
  "password": "securepassword123"
}
```
* **Success Response (200 OK)**:
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "johndoe@example.com"
  }
}
```

---

### B. Manajemen Perangkat (Devices)

Semua endpoint berikut memerlukan Header Autentikasi: `Authorization: Bearer <token>`.

#### Register Device
Menghubungkan perangkat keras ESP32 baru ke akun pengguna.
* **HTTP Method**: POST
* **Endpoint**: `/devices`
* **Request Body**:
```json
{
  "device_name": "Pengering Sepatu Kamar Utama",
  "device_code": "ESP32-SHOE-001"
}
```
* **Success Response (201 Created)**:
```json
{
  "success": true,
  "message": "Device registered successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "device_name": "Pengering Sepatu Kamar Utama",
    "device_code": "ESP32-SHOE-001",
    "status": "active",
    "created_at": "2026-05-22T11:05:00.000Z"
  }
}
```

#### Get Devices
Mengambil daftar perangkat yang dimiliki oleh pengguna yang sedang login.
* **HTTP Method**: GET
* **Endpoint**: `/devices`
* **Success Response (200 OK)**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "device_name": "Pengering Sepatu Kamar Utama",
      "device_code": "ESP32-SHOE-001",
      "status": "active",
      "created_at": "2026-05-22T11:05:00.000Z"
    }
  ]
}
```

---

### C. Manajemen Sepatu (Shoes)

Memerlukan Header Autentikasi: `Authorization: Bearer <token>`.

#### Add Shoe
Menambahkan pasang sepatu baru untuk dipantau.
* **HTTP Method**: POST
* **Endpoint**: `/shoes`
* **Request Body**:
```json
{
  "shoe_name": "Sepatu Mesh",
  "shoe_type": "Umum"
}
```
* **Success Response (201 Created)**:
```json
{
  "success": true,
  "message": "Shoe added successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "shoe_name": "Sepatu Mesh",
    "shoe_type": "Umum",
    "created_at": "2026-05-22T11:10:00.000Z"
  }
}
```

#### Get Shoes
Mengambil daftar sepatu yang dimiliki oleh pengguna.
* **HTTP Method**: GET
* **Endpoint**: `/shoes`
* **Success Response (200 OK)**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "shoe_name": "Sepatu Mesh",
      "shoe_type": "Umum",
      "created_at": "2026-05-22T11:10:00.000Z"
    }
  ]
}
```

---

### D. Sensor Logs & Realtime Data

#### Send Sensor Log
Mengirimkan data sensor mentah (dari ESP32 via HTTP POST atau MQTT Broker). Jika menggunakan HTTP POST:
* **HTTP Method**: POST
* **Endpoint**: `/sensor-logs`
* **Request Body**:
```json
{
  "device_code": "ESP32-SHOE-001",
  "shoe_id": 1,
  "temperature": 32.5,
  "humidity": 82.0,
  "gas_level": 512.0
}
```
* **Success Response (201 Created)**:
```json
{
  "success": true,
  "message": "Sensor log saved and analyzed",
  "data": {
    "log_id": 105,
    "temperature": 32.5,
    "humidity": 82.0,
    "gas_level": 512.0,
    "created_at": "2026-05-22T11:12:00.000Z"
  },
  "prediction": {
    "label": "BAU_PARAH",
    "confidence_score": 0.85
  }
}
```
*(Catatan: Endpoint ini secara internal akan menembak ML Service untuk mendapatkan hasil prediksi secara realtime sebelum mengembalikan response ke klien).*

#### Get Sensor Logs
Mengambil riwayat log sensor untuk sepatu tertentu.
* **HTTP Method**: GET
* **Endpoint**: `/sensor-logs?shoe_id=1&limit=50`
* **Success Response (200 OK)**:
```json
{
  "success": true,
  "data": [
    {
      "id": 105,
      "shoe_id": 1,
      "device_id": 1,
      "temperature": 32.5,
      "humidity": 82.0,
      "gas_level": 512.0,
      "created_at": "2026-05-22T11:12:00.000Z"
    }
  ]
}
```

---

### E. Pemeliharaan (Maintenance)

#### Add Maintenance Log
Mencatat tindakan pemeliharaan yang dilakukan pada perangkat pengering sepatu.
* **HTTP Method**: POST
* **Endpoint**: `/maintenance-logs`
* **Request Body**:
```json
{
  "device_id": 1,
  "component_name": "Heater Element",
  "issue": "Pemanasan tidak maksimal karena kelembapan berlebih",
  "action_taken": "Pembersihan elemen pemanas dan sterilisasi UV manual"
}
```
* **Success Response (201 Created)**:
```json
{
  "success": true,
  "message": "Maintenance log recorded successfully",
  "data": {
    "id": 12,
    "device_id": 1,
    "component_name": "Heater Element",
    "issue": "Pemanasan tidak maksimal karena kelembapan berlebih",
    "action_taken": "Pembersihan elemen pemanas dan sterilisasi UV manual",
    "maintenance_date": "2026-05-22T11:13:00.000Z"
  }
}
```

#### Get Maintenance Logs
Mengambil riwayat log pemeliharaan untuk perangkat tertentu.
* **HTTP Method**: GET
* **Endpoint**: `/maintenance-logs?device_id=1`
* **Success Response (200 OK)**:
```json
{
  "success": true,
  "data": [
    {
      "id": 12,
      "device_id": 1,
      "component_name": "Heater Element",
      "issue": "Pemanasan tidak maksimal karena kelembapan berlebih",
      "action_taken": "Pembersihan elemen pemanas dan sterilisasi UV manual",
      "maintenance_date": "2026-05-22T11:13:00.000Z"
    }
  ]
}
```

---

## 2. ML Service API (FastAPI)

ML Service dipanggil secara internal oleh Gateway Service atau secara mandiri untuk analisis model machine learning. Base URL default: `http://localhost:8000`.

### A. Deteksi & Klasifikasi Tingkat Bau Sepatu (K-Means Clustering)

Mengelompokkan aroma sepatu secara objektif ke dalam 3 level (**Wangi**, **Normal**, **Bau**) berdasarkan data sensor gas MQ-135 dan kelembapan saat ini.
* **HTTP Method**: POST
* **Endpoint**: `/predict/smell`
* **Request Body**:
```json
{
  "gas_mq135": 150.0,
  "kelembapan_sekarang": 25.0
}
```
* **Success Response (200 OK)**:
```json
{
  "klaster_asli": 0,
  "label": 0,
  "kategori": "Wangi",
  "gas_mq135_normalisasi": 0.0542,
  "kelembapan_normalisasi": 0.1623
}
```

---

### B. Estimasi Sisa Waktu Pengeringan Sepatu (Multiple Linear Regression)

Menghitung estimasi sisa waktu pengeringan sepatu dalam satuan menit berdasarkan kelembapan awal, kelembapan sekarang, suhu udara, jenis bahan sepatu, dan sensor bau.
* **HTTP Method**: POST
* **Endpoint**: `/predict/maintenance`
* **Request Body**:
```json
{
  "kelembapan_awal": 80.0,
  "kelembapan_sekarang": 30.0,
  "suhu": 45.0,
  "jenis_bahan": 1,
  "sensor_bau": 300.0
}
```
*(Catatan `jenis_bahan`: 1 untuk Kanvas, 2 untuk Kulit, 3 untuk Mesh)*

* **Success Response (200 OK)**:
```json
{
  "sisa_waktu_menit": 25.42,
  "status": "Sedang dikeringkan (Kondisi sepatu hampir kering)"
}
```

