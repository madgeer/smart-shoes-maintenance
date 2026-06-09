# Smart Shoes Maintenance - Sistem Pengering & Sterilisasi Sepatu Berbasis IoT & Machine Learning

Proyek **Smart Shoes Maintenance** adalah sistem pengering dan sterilisasi sepatu otomatis berbasis IoT (*Internet of Things*) yang terintegrasi dengan kecerdasan buatan (*Machine Learning*). Sistem ini dirancang untuk menjaga higienitas, kesegaran, dan memperpanjang umur sepatu secara pintar melalui kontrol otomatis berbasis kondisi fisik sepatu secara real-time.

Sistem ini memantau kondisi sepatu menggunakan sensor **DHT22** (Suhu & Kelembapan) dan **MQ-135** (Kadar Gas/Bau), lalu memproses data sensor tersebut menggunakan model Machine Learning untuk mengotomatisasi komponen fisik penunjang: **Heater (Pemanas)**, **Lampu UV Sterilisator (Pembunuh Bakteri)**, dan **Kipas Blower (Sirkulasi Udara)**.

---

## Fitur Utama Sistem

*   **Pengeringan & Sterilisasi Pintar**: Kontrol aktuasi pemanas, UV, dan blower secara otomatis (*Auto Mode*) berdasarkan hasil pembacaan sensor dan analisis model ML.
*   **Klasifikasi Kekeringan Tropis (Decision Tree Classifier)**: Mengklasifikasikan status kelembapan sepatu secara real-time berdasarkan data kelembapan dengan target tropis Indonesia (Kering $\le 50\%$, Lembap $50\% - 70\%$, Basah $> 70\%$).
*   **Estimasi Waktu Pengeringan (Matematika Heuristik)**: Memprediksi sisa waktu pengeringan sepatu dalam hitungan menit secara akurat berdasarkan tipe bahan sepatu (`Kanvas`, `Kulit`, `Mesh`) dan laju penguapan dinamis berbasis suhu heater.
*   **Otomatisasi & Proteksi Boks Kosong (Ultrasonic Interlock)**: Secara otomatis mendeteksi kehadiran sepatu menggunakan sensor ultrasonik (Boks Kosong jika jarak $\ge 15\text{ cm}$). Mematikan seluruh aktuator secara paksa untuk menghemat listrik dan menjaga keselamatan alat.
*   **Komunikasi Real-time (WebSockets & MQTT)**: Aliran data telemetri yang cepat tanpa jeda (*low-latency*) dari perangkat keras ke dashboard pengguna.
*   **Keamanan Terotentikasi (JWT)**: Dilengkapi otentikasi JSON Web Token untuk pendaftaran pengguna, pendaftaran alat, serta pencatatan pemeliharaan.

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
    FastAPI -->|4. Prediksi Status & Waktu Pengeringan / JSON| Gateway
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
    actor User as Sepatu / Pengguna
    participant ESP as ESP32 Hardware / Emulator
    participant Broker as Mosquitto Broker
    participant Gateway as Gateway Service (Node.js)
    participant ML as ML Service (FastAPI)
    participant DB as PostgreSQL Database

    Note over User, ESP: Sesi Pengeringan / Deteksi Sensor
    ESP->>Broker: Publish Status Koneksi (v1/devices/ESP32-SHOE-001/status = "online")
    
    loop Setiap 5 Detik (Atau Event-Driven Instan saat status shoe_present berubah)
        Note over ESP: Sensor Ultrasonik mendeteksi jarak sepatu (threshold < 15 cm)
        ESP->>Broker: Publish Telemetri (Suhu, Kelembapan, Gas, shoe_present)
        Broker->>Gateway: Forward Telemetri Payload
        
        Note over Gateway: Autentikasi Kode Perangkat & Cek Pemilik
        Gateway->>DB: Query Cek Registrasi & Ambil Pemilik Device
        DB-->>Gateway: Hasil Valid (User ID & Device ID Terdaftar)
        
        Gateway->>DB: INSERT INTO sensor_logs (shoe_id, temperature, humidity, gas_level, ...)
        DB-->>Gateway: Sukses (Log ID Terbuat)
        
        alt Sepatu Terdeteksi (shoe_present == true)
            Note over Gateway, ML: Proses Inferensi Machine Learning
            Gateway->>ML: POST /predict/dryness (gas_level, kelembapan_sekarang, suhu)
            ML-->>Gateway: Respon Kategori Kekeringan (Kering / Lembap / Basah)
            
            Gateway->>DB: Query Ambil Kelembapan Awal 12 Jam Terakhir
            DB-->>Gateway: Kelembapan Awal: 82%
            
            Gateway->>ML: POST /predict/maintenance (kelembapan_awal, kelembapan_sekarang, suhu, jenis_bahan)
            ML-->>Gateway: Respon Prediksi Waktu (Sisa Waktu: 35 Menit, Status: "Sedang dikeringkan")
        else Boks Kosong (shoe_present == false)
            Note over Gateway: Set Status Default "Boks Kosong" & Lewati API ML
        end
        
        Gateway->>DB: INSERT INTO predictions (prediction_label, estimated_drying_time, drying_status)
        
        Note over Gateway: Evaluasi Keputusan Otomatis (Auto Mode)
        alt Sepatu Terdeteksi (hasShoe == true)
            alt Kelembapan > 25.0%
                Note over Gateway: Heater: ON, Fan: ON (sirkulasi panas)
            else Kelembapan <= 25.0%
                Note over Gateway: Heater: OFF, Fan: OFF (sepatu sudah kering)
            end
            alt Kategori == "Basah" ATAU "Lembap"
                Note over Gateway: UV: ON, Fan: ON (sterilisasi & sirkulasi bau)
            else Kategori == "Kering"
                Note over Gateway: UV: OFF
            end
        else Boks Kosong (hasShoe == false)
            Note over Gateway: Proteksi Boks Kosong (heater: OFF, uv: OFF, fan: OFF)
        end
        
        Gateway->>Broker: Publish Perintah Aktuator (heater, uv_light, fan)
        Broker->>ESP: Forward Perintah Komando (heater, uv_light, fan)
        Note over ESP: Relay Fisik Beraksi & Update Output
        
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
    
    J --> K{Cek Kehadiran Sepatu?}
    K -->|Ya| L[POST /predict/dryness ke ML Service]
    L --> M[Query Ambil Kelembapan Awal Sepatu]
    M --> N[POST /predict/maintenance ke ML Service]
    N --> O[Simpan Hasil ke Tabel predictions]
    
    K -->|Tidak| P[Set Status Default Boks Kosong]
    P --> O
    
    O --> Q[Evaluasi Logika Aktuasi Otomatis]
    Q --> R[Publish Perintah Aktuator via MQTT]
    Q --> S[Broadcast Data Real-time via WebSocket]
    Q --> T[Simpan Alert ke DB jika Kelembapan Ekstrim]
    
    T --> F
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
    
    %% Dryness Classifier
    B -->|/predict/dryness| C[Standard Scaling Fitur Kelembapan]
    C --> D[Prediksi Label Kelas via Decision Tree Classifier]
    D --> E[Petakan Kelas ke Kategori: 0->Kering, 1->Lembap, 2->Basah]
    E --> F[Return JSON DrynessResponse]
    
    %% Heuristic Estimator
    B -->|/predict/maintenance| G{Kelembapan Sekarang <= 25%?}
    G -->|Ya| H[Set Sisa Waktu = 0.0 & Status Selesai]
    G -->|Tidak| I[Hitung Selisih Kelembapan = Kelembapan Sekarang - 25.0]
    I --> J["Hitung Laju Dasar = max(0.1, 0.5 + 0.02 * (Suhu - 25.0))"]
    J --> K{Tentukan Pengali Bahan}
    K -->|Mesh| L[Pengali = 1.5x]
    K -->|Kanvas| M[Pengali = 1.0x]
    K -->|Kulit| N[Pengali = 0.7x]
    L --> O[Laju Aktual = Laju Dasar * Pengali]
    M --> O
    N --> O
    O --> P[Sisa Waktu = Selisih Kelembapan / Laju Aktual]
    P --> Q{Kelembapan Sekarang > 60%?}
    Q -->|Ya| R[Status: Masih sangat basah]
    Q -->|Tidak| S[Status: Hampir kering]
    R --> T[Return JSON MaintenanceResponse]
    S --> T
    H --> T
```

*   **Port Default**: `8000`
*   **Model Klasifikasi Kekeringan**: Menggunakan *Decision Tree Classifier (3-Node)* berbasis fitur tunggal kelembapan untuk menentukan status kekeringan tropis (Kering $\le 50\%$, Lembap $50\% - 70\%$, Basah $> 70\%$).
*   **Model Estimasi Waktu**: Menggunakan *Matematika Heuristik* untuk menghitung estimasi menit tersisa hingga kelembapan menyentuh batas optimal ($25\%$) berdasarkan tipe bahan sepatu (Mesh $1.5\times$, Kanvas $1.0\times$, Kulit $0.7\times$) dan laju pengeringan dinamis berbasis suhu box.

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
    U -->|4| Y[Ganti Kode Alat & ID Sepatu]
    U -->|5| Z[Set Nilai Sensor Kustom secara Dinamis]
    U -->|Q| AA[Kirim Offline & Matikan Emulator]
```

> [!NOTE]
> Pada **perangkat fisik ESP32**, kehadiran sepatu dideteksi secara dinamis via sensor **Ultrasonik HC-SR04 / AJ-SR04M** (jarak $\ge 15\text{ cm}$ berarti boks kosong). Pada **Emulator**, status kehadiran sepatu dikontrol secara logis via parameter ID Sepatu (`active_shoe_id` terdaftar di database). Jika `active_shoe_id` bernilai `0` (atau `null`), sistem secara otomatis mengaktifkan fitur proteksi boks kosong.

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
