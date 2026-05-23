# Smart Shoes Maintenance - Sistem Pengering & Sterilisasi Sepatu Berbasis IoT & Machine Learning

Proyek **Smart Shoes Maintenance** adalah sistem pengering dan sterilisasi sepatu otomatis berbasis IoT (*Internet of Things*) yang terintegrasi dengan kecerdasan buatan (*Machine Learning*). Sistem ini dirancang untuk menjaga higienitas, kesegaran, dan memperpanjang umur sepatu secara pintar melalui kontrol otomatis berbasis kondisi fisik sepatu secara real-time.

Sistem ini memantau kondisi sepatu menggunakan sensor **DHT22** (Suhu & Kelembapan) dan **MQ-135** (Kadar Gas/Bau), lalu memproses data sensor tersebut menggunakan model Machine Learning untuk mengotomatisasi komponen fisik penunjang: **Heater (Pemanas)**, **Lampu UV Sterilisator (Pembunuh Bakteri)**, dan **Kipas Blower (Sirkulasi Udara)**.

---

## Fitur Utama Sistem

*   **Pengeringan & Sterilisasi Pintar**: Kontrol aktuasi pemanas, UV, dan blower secara otomatis (*Auto Mode*) berdasarkan hasil pembacaan sensor dan analisis model ML.
*   **Deteksi Tingkat Bau Sepatu (K-Means Clustering)**: Mengklasifikasikan kebersihan sepatu secara real-time ke dalam 3 tingkat kondisi: `Wangi`, `Normal`, dan `Bau`.
*   **Estimasi Waktu Pengeringan (Linear Regression)**: Memprediksi sisa waktu pengeringan sepatu dalam hitungan menit secara akurat berdasarkan tipe bahan sepatu (`Kanvas`, `Kulit`, `Mesh`) dan laju penurunan kelembapan.
*   **Komunikasi Real-time (WebSockets & MQTT)**: Aliran data telemetri yang cepat tanpa jeda (*low-latency*) dari perangkat keras ke dashboard pengguna.
*   **Keamanan Terotentikasi (JWT)**: Dilengkapi otentikasi JSON Web Token untuk pendaftaran pengguna, manajemen profil sepatu, registrasi alat, serta pencatatan pemeliharaan.
*   **Emulator Hardware Interaktif**: Script simulasi perangkat keras yang responsif secara fisika untuk kemudahan pengujian sistem secara utuh tanpa memerlukan alat fisik.

---

## Arsitektur Sistem Terintegrasi

Sistem ini dibangun menggunakan arsitektur microservices modern yang diwadahi oleh Docker Compose untuk kemudahan orkestrasi.

```mermaid
graph TD
    %% Styling
    classDef iot fill:#f9f,stroke:#333,stroke-width:2px;
    classDef broker fill:#bbf,stroke:#333,stroke-width:2px;
    classDef backend fill:#f96,stroke:#333,stroke-width:2px;
    classDef ml fill:#bfb,stroke:#333,stroke-width:2px;
    classDef db fill:#ffb,stroke:#333,stroke-width:2px;
    classDef client fill:#bbf,stroke:#333,stroke-width:2px;

    %% Nodes
    ESP[ESP32 / Emulator Hardware]:::iot
    Mosquitto[Mosquitto MQTT Broker]:::broker
    Gateway[Gateway Service Node.js]:::backend
    FastAPI[FastAPI ML Service]:::ml
    Postgres[(PostgreSQL Database)]:::db
    Dashboard[React Dashboard Client]:::client

    %% Connections
    ESP -->|1. Publish Telemetri / MQTT| Mosquitto
    Mosquitto -->|2. Forward Telemetri| Gateway
    Gateway -->|3. Kirim Fitur Sensor / HTTP POST| FastAPI
    FastAPI -->|4. Prediksi Bau & Waktu Pengeringan / JSON| Gateway
    Gateway -->|5. Simpan Logs & Hasil Prediksi| Postgres
    Gateway -->|6. Broadcast Telemetri & Prediksi / WebSockets| Dashboard
    Gateway -->|7. Publish Komando Otomatis / MQTT| Mosquitto
    Mosquitto -->|8. Forward Komando Aksi| ESP

    subgraph Hardware Layer
        ESP
    end

    subgraph Messaging Layer
        Mosquitto
    end

    subgraph Processing Layer
        Gateway
        FastAPI
        Postgres
    end

    subgraph User Interface Layer
        Dashboard
    end
```

---

## Alur Program Umum (End-to-End Flow)

Diagram urutan berikut menggambarkan siklus hidup pengiriman data sensor dari perangkat ESP32 ke sistem backend hingga terjadinya respon aktuasi otomatis di perangkat keras:

```mermaid
sequenceDiagram
    autonumber
    actor User as Pengguna / Sepatu
    participant ESP as ESP32 Hardware / Emulator
    participant Broker as Mosquitto Broker
    participant Gateway as Gateway Service (Node.js)
    participant ML as ML Service (FastAPI)
    participant DB as PostgreSQL Database

    Note over User, ESP: Sesi Pengeringan Dimulai
    ESP->>Broker: Publish Status Koneksi (v1/devices/ESP32-SHOE-001/status = "online")
    
    loop Setiap 5 Detik
        ESP->>Broker: Publish Telemetri (v1/devices/ESP32-SHOE-001/telemetry)
        Broker->>Gateway: Forward Telemetri Payload
        
        Note over Gateway: Autentikasi Kode Perangkat di Database
        Gateway->>DB: Query Cek Registrasi & Ambil Pemilik Device
        DB-->>Gateway: Hasil Valid (User ID & Device ID Terdaftar)
        
        Gateway->>DB: INSERT INTO sensor_logs (Suhu, Kelembapan, Gas, Durasi)
        DB-->>Gateway: Sukses (Log ID Terbuat)
        
        Note over Gateway, ML: Proses Inferensi Machine Learning
        Gateway->>ML: POST /predict/smell (Gas & Kelembapan)
        ML-->>Gateway: Respon Prediksi Bau (Kategori: "Bau", Cluster: 2)
        
        Gateway->>DB: Query Ambil Kelembapan Awal 12 Jam Terakhir
        DB-->>Gateway: Kelembapan Awal: 85%
        
        Gateway->>ML: POST /predict/maintenance (Kelembapan Awal, Kelembapan Sekarang, Suhu, Bahan)
        ML-->>Gateway: Respon Prediksi Waktu (Sisa Waktu: 45 Menit, Status: "Sedang dikeringkan")
        
        Gateway->>DB: INSERT INTO predictions (Hasil K-Means & Hasil Regresi)
        
        Note over Gateway: Evaluasi Keputusan Otomatis (Auto Mode)
        alt Kelembapan > 15% ATAU Kategori Bau == "Bau"
            Gateway->>Broker: Publish Perintah Aktuator (heater: ON, fan: ON, uv: ON)
            Broker->>ESP: Forward Perintah Komando (heater: ON, fan: ON, uv: ON)
            Note over ESP: Relay Fisik Aktif & Simulasi Fisika Berjalan
        else Kelembapan <= 15% DAN Kategori Bau != "Bau"
            Gateway->>Broker: Publish Perintah Aktuator (heater: OFF, fan: OFF, uv: OFF)
            Broker->>ESP: Forward Perintah Komando (heater: OFF, fan: OFF, uv: OFF)
            Note over ESP: Proses Selesai, Alat Istirahat
        end
        
        Gateway->>Gateway: Broadcast data sensor & prediksi ke Websocket Room ("ESP32-SHOE-001")
    end
```

---

## Arsitektur & Alur Per-Service

Setiap service dirancang secara modular dan efisien dengan tanggung jawab yang spesifik.

### 1. Gateway Service (Node.js & Express)
Merupakan pusat orkestrasi sistem. Bertindak sebagai *subscriber* MQTT untuk menerima telemetri, berinteraksi dengan basis data PostgreSQL, memanggil API ML Service, serta menyebarkan pembaruan data secara real-time kepada pengguna melalui WebSocket.

```mermaid
graph TD
    A[Mulai Server] --> B[Konek Postgres DB]
    B --> C[Konek Mosquitto Broker]
    C --> D[Subscribe Topic Telemetry]
    D --> E[Init HTTP & Socket.io Server]
    
    E --> F{Pesan MQTT Masuk?}
    F -->|Ya| G[Parse Payload JSON]
    G --> H{Cek Device Code di DB?}
    H -->|Tidak Terdaftar| I[Abaikan & Log Warning]
    H -->|Terdaftar| J[Simpan ke Tabel sensor_logs]
    
    J --> K[POST /predict/smell ke ML Service]
    K --> L[Query Ambil Kelembapan Awal Sepatu]
    L --> M[POST /predict/maintenance ke ML Service]
    M --> N[Simpan Hasil ke Tabel predictions]
    
    N --> O[Evaluasi Logika Aktuasi Otomatis]
    O --> P[Publish Perintah Aktuator via MQTT]
    O --> Q[Broadcast Data Real-time via WebSocket]
    O --> R[Simpan Alert ke DB jika Kelembapan/Bau Ekstrim]
    
    R --> F
```

*   **Port Default**: `3000`
*   **Path WebSocket**: `ws://localhost:3000/realtime`
*   **Rute Utama REST API**: `/api/v1` (Registrasi, Login, Manajemen Sepatu, Logs, Notifikasi)

---

### 2. ML Service (FastAPI)
Layanan berbasis Python yang menyediakan endpoint REST API berkinerja tinggi untuk melakukan komputasi prediksi secara realtime menggunakan model matematika yang telah dilatih sebelumnya.

```mermaid
graph TD
    A[Request HTTP POST Masuk] --> B{Pilih Endpoint}
    
    %% K-Means
    B -->|/predict/smell| C[MinMax Scaling Fitur Gas & Kelembapan]
    C --> D[Prediksi Klaster Asli via Model K-Means]
    D --> E[Petakan Klaster ke Label Urutan: 0, 1, 2]
    E --> F[Tentukan Kategori Deskriptif: Wangi, Normal, Bau]
    F --> G[Return JSON SmellResponse]
    
    %% Regression
    B -->|/predict/maintenance| H[Konversi Bahan Sepatu ke Fitur One-Hot]
    H --> I[Susun Vektor Input 7 Dimensi]
    I --> J[MinMax Scaling Fitur Input]
    J --> K[Prediksi Sisa Waktu via Model Linear Regression]
    K --> L[Pengaman Nilai Negatif: max 0.0, sisa_waktu]
    L --> M[Tentukan Deskripsi Status Pengeringan]
    M --> N[Return JSON MaintenanceResponse]
```

*   **Port Default**: `8000`
*   **Model Klasifikasi Bau**: Menggunakan *K-Nearest Neighbors (KNN)* atau *K-Means* untuk klasterisasi tingkat bau dan sisa kelembapan.
*   **Model Estimasi Waktu**: Menggunakan *Linear Regression* untuk menghitung estimasi menit tersisa hingga kelembapan menyentuh titik optimal.

---

### 3. Database Schema (PostgreSQL)

Skema database dirancang untuk memastikan integritas data telemetri, riwayat pemeliharaan alat, hasil prediksi ML, dan notifikasi pengguna terjaga dengan baik.

```mermaid
erDiagram
    USERS ||--o{ DEVICES : "memiliki"
    USERS ||--o{ SHOES : "memiliki"
    USERS ||--o{ NOTIFICATIONS : "menerima"
    SHOES ||--o{ SENSOR_LOGS : "memiliki"
    DEVICES ||--o{ SENSOR_LOGS : "mengirim"
    DEVICES ||--o{ MAINTENANCE_LOGS : "menjalani"
    SENSOR_LOGS ||--|| PREDICTIONS : "dianalisis_oleh"

    USERS {
        int id PK
        varchar name
        varchar email UK
        varchar password
        timestamp created_at
    }

    DEVICES {
        int id PK
        int user_id FK
        varchar device_name
        varchar device_code UK
        varchar status
        timestamp created_at
    }

    SHOES {
        int id PK
        int user_id FK
        varchar shoe_name
        varchar shoe_type
        varchar shoe_material
        timestamp created_at
    }

    SENSOR_LOGS {
        int id PK
        int shoe_id FK
        int device_id FK
        float temperature
        float humidity
        float gas_level
        float duration_usage
        float fan_usage_duration
        float uv_usage_duration
        timestamp created_at
    }

    PREDICTIONS {
        int id PK
        int sensor_log_id FK
        varchar prediction_label
        float confidence_score
        float estimated_drying_time
        varchar drying_status
        timestamp created_at
    }

    NOTIFICATIONS {
        int id PK
        int user_id FK
        varchar title
        varchar message
        varchar notification_type
        boolean is_read
        timestamp created_at
    }

    MAINTENANCE_LOGS {
        int id PK
        int device_id FK
        varchar component_name
        varchar issue
        varchar action_taken
        timestamp maintenance_date
    }
```

---

### 4. Interactive ESP32 Emulator (Node.js)
Menyimulasikan kondisi fisik perangkat keras pengering sepatu di dalam terminal. Emulator memproses rumus perubahan fisika secara dinamis bergantung pada status saklar aktuator yang ia terima dari Gateway Service.

```mermaid
graph TD
    A[Jalankan Emulator] --> B[Konek MQTT Broker]
    B --> C[Kirim Status 'online' & Daftarkan LWT]
    C --> D[Subscribe Topic Commands]
    D --> E[Mulai Tampilan CLI Dashboard]
    
    E --> F[Loop Fisika & Telemetri - Tiap 5 Detik]
    
    subgraph Update Nilai Sensor Dinamis
        F --> G{Status Heater?}
        G -->|ON| H[Suhu Naik maks 48 derajat]
        G -->|OFF| I[Suhu Turun ke suhu ruang 25 derajat]
        
        F --> J{Status Heater & Fan?}
        J -->|Heater ON & Fan ON| K[Kelembapan Turun Drastis -2.2%]
        J -->|Heater ON & Fan OFF| L[Kelembapan Turun Perlahan -0.8%]
        J -->|Keduanya OFF| M[Kelembapan Stabil]
        
        F --> N{Status UV & Fan?}
        N -->|UV ON & Fan ON| O[Kadar Bau MQ-135 Turun Drastis -18.0 ppm]
        N -->|UV ON & Fan OFF| P[Kadar Bau MQ-135 Turun Sedang -10.0 ppm]
        N -->|Keduanya OFF| Q[Kadar Bau Stabil]
    end
    
    Q --> R[Akumulasi Metrik Durasi Aktif Komponen]
    R --> S[Kirim Payload Telemetri via MQTT]
    S --> T[Gambar Ulang Dashboard CLI Terminal]
    T --> F
    
    E --> U{Input Menu Keyboard?}
    U -->|1| V[Atur Sepatu Basah: Kelembapan 82%]
    U -->|2| W[Atur Sepatu Bau: Gas 680 ppm]
    U -->|3| X[Bersihkan Manual: Kelembapan 14%, Gas 120 ppm]
    U -->|Q| Y[Kirim Offline & Matikan Emulator]
```

---

## Panduan Menjalankan Sistem (Quick Start)

### Prasyarat System
*   Docker & Docker Desktop terinstal.
*   Node.js (versi >= 16) terinstal secara lokal di komputer Anda.

### Langkah 1: Jalankan Ekosistem Menggunakan Docker
Jalankan perintah berikut di root folder proyek untuk membangun dan menyalakan PostgreSQL database, Mosquitto MQTT broker, ML Service, dan Gateway Service secara terpadu:
```bash
docker compose up --build
```

### Langkah 2: Jalankan ESP32 Emulator
Buka terminal baru di komputer Anda, masuk ke dalam folder `scripts`, lalu aktifkan emulator:
```bash
cd scripts
node emulator.js --device ESP32-SHOE-001 --shoe 1
```

### Langkah 3: Gunakan Menu Interaktif Emulator
Gunakan tombol angka `1` s.d `4` pada keyboard terminal emulator untuk menyimulasikan berbagai skenario pengeringan sepatu Anda dan saksikan bagaimana sistem cerdas Machine Learning mengotomatisasi saklar perangkat keras secara instan!
