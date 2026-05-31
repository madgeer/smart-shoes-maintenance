# Panduan Skema Wiring Perangkat Keras ESP32

Dokumen ini menjelaskan konfigurasi pemasangan kabel (*wiring diagram*) dan pemetaan pin GPIO dari papan mikrokontroler **ESP32 NodeMCU** ke berbagai komponen sensor serta modul aktuator. Skema ini disusun secara akurat berdasarkan berkas konfigurasi firmware utama di [app/include/Config.h](file:///D:/Kuliah/semester%204/IoT/tugas-besar/smart-shoes-maintenance/app/include/Config.h).

---

## 1. Pemetaan Pin Utama (ESP32 Pin Map Table)

Berikut adalah tabel koneksi pin hardware lengkap pada sistem **Smart Shoes Maintenance**:

| No | Komponen | Pin Komponen | Pin ESP32 | Fungsi Pin | Deskripsi Daya & Sinyal |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **A** | **Catu Daya Utama** | | | | |
| 1 | ESP32 Board | Micro-USB / Vin | USB 5V / Charger | VCC Input | Sumber daya utama mikrokontroler |
| 2 | ESP32 Board | GND | Ground Bersama | GND | Titik acuan potensial nol volt |
| **B** | **Blok Sensor** | | | | |
| 3 | **Sensor DHT22** | VCC | 3.3V | Catu Daya | Daya sensor suhu & kelembapan |
| 4 | | GND | GND | Ground | Grounding sensor |
| 5 | | DATA / OUT | **GPIO 4** | Data Digital | Komunikasi digital protocol DHT |
| 6 | **Sensor MQ-135** | VCC | Vin / 5V | Catu Daya | **WAJIB 5V** untuk heater internal sensor |
| 7 | | GND | GND | Ground | Grounding sensor |
| 8 | | A0 (Analog Out) | **GPIO 34 (ADC1_CH6)**| Input Analog | Input analog pembacaan kadar gas bau |
| **C** | **Blok Aktuator (Relay 4-Channel)** | | | | |
| 9 | **Modul Relay** | VCC | Vin / 5V | Catu Daya Coil | **WAJIB 5V** agar coil relay menjepret kuat |
| 10 | | GND | GND | Ground | Grounding modul relay |
| 11 | | IN1 (Relay 1) | **GPIO 14** | Output Kontrol | Kontrol **Plate Heater** (Active-Low) |
| 12 | | IN2 (Relay 2) | **GPIO 12** | Output Kontrol | Kontrol **Lampu UV Sterilizer** (Active-Low) |
| 13 | | IN3 (Relay 3) | **GPIO 26** | Output Kontrol | Kontrol **Motor Blower Sirkulasi** (Active-Low) |
| 14 | | IN4 (Relay 4) | **GPIO 27** | Output Kontrol | Kontrol **Power VCC Kipas PWM** (Active-Low) |

---

## 2. Catatan Penting Pemasangan & Keamanan Elektrik

> [!IMPORTANT]
> **Kebutuhan Catu Daya 5V Eksternal/Vin**:
> - **Sensor Gas MQ-135**: Sensor ini memerlukan pemanas internal (*heating element*) agar peka mendeteksi gas bau. Hubungkan pin VCC sensor ke **Vin (5V)** ESP32, bukan pin 3.3V. Menghubungkannya ke 3.3V akan membuat pembacaan sensor tidak akurat.
> - **Modul Relay 4-Channel**: Coil elektromagnetik pada relay memerlukan tegangan 5V stabil agar dapat beralih saklar (*switching*) secara sempurna. Hubungkan VCC relay ke **Vin (5V)** ESP32.

> [!TIP]
> **Logika Aktif Relay (Active-Low)**:
> Firmware ini dikonfigurasi menggunakan logika **Active-Low** (`RELAY_ACTIVE_STATE LOW` di `Config.h`). Artinya:
> - Mengirim sinyal `LOW` (GND) dari ESP32 $\rightarrow$ Relay akan **MENYALAKAN** beban listrik (Heater, UV, Kipas).
> - Mengirim sinyal `HIGH` (3.3V) dari ESP32 $\rightarrow$ Relay akan **MEMATIKAN** beban listrik.

> [!WARNING]
> **Proteksi Keamanan Hardware (Safety Interlock)**:
> Firmware dilengkapi logika pengunci otomatis (*interlock*) di dalam file `ActuatorManager.cpp`.
> Jika pemanas **Plate Heater** dinyalakan (`ON`), maka **Motor Blower** (GPIO 26) dan **Power Kipas PWM** (GPIO 27) akan **otomatis dipaksa menyala** oleh sistem untuk mencegah lempeng pemanas mengalami kelebihan suhu (*overheating*) yang dapat merusak struktur fisik pengering sepatu.

---

## 3. Skema Diagram Koneksi Fisik (Sederhana)

```text
       +---------------------------------------------+
       |                  ESP32                      |
       |                                             |
       |  [3.3V] [GND]  [GPIO 4]  [GPIO 34]  [Vin/5V]|
       +----+-----+--------+----------+---------+----+
            |     |        |          |         |
            |     +---+    |          |         +---------+
            |         |    |          |                   |
       +----+----+  +-+----+---+   +--+-------+           |
       |  DHT22  |  |  MQ-135  |   |  MQ-135  |           |
       |  (VCC)  |  |  (GND)   |   |  (VCC)   |           |
       +---------+  +----------+   +----------+           |
                                                          |
            +---------------------------------------------+
            |
       +----+-----+--------+----------+---------+----+
       |  [Vin/5V]| [GND]  | [GPIO 14]| [GPIO 12]|    |
       |          |        |          |         |    |
       |    +-----+---+    |    +-----+---+     |    |
       |    |  Relay  |    |    |  Relay  |     |    |
       |    |  (VCC)  |    |    |  (IN1)  |     |    |
       |    +---------+    |    +---------+     |    |
       |                   |                    |    |
       |                   +--------------------+    |
       |                                             |
       |             RELAY 4-CHANNEL BOARD           |
       +---------------------------------------------+
```
