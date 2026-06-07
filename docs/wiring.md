# Panduan Skema Wiring Perangkat Keras ESP32

Dokumen ini menjelaskan konfigurasi pemasangan kabel (*wiring diagram*) dan pemetaan pin GPIO dari papan mikrokontroler **ESP32 NodeMCU** ke berbagai komponen sensor serta modul aktuator.

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
| 5 | | DATA / OUT | **GPIO 18** | Data Digital | Komunikasi digital protocol DHT |
| 6 | **Sensor MQ-135** | VCC | Vin / 5V | Catu Daya | **WAJIB 5V** untuk heater internal sensor |
| 7 | | GND | GND | Ground | Grounding sensor |
| 8 | | A0 (Analog Out) | **GPIO 34 (ADC1_CH6)**| Input Analog | Input analog pembacaan kadar gas bau |
| **C** | **Blok Aktuator (Relay 4-Channel)** | | | | |
| 9 | **Modul Relay** | VCC | Vin / 5V | Catu Daya Coil | **WAJIB 5V** agar coil relay menjepret kuat |
| 10 | | GND | GND | Ground | Grounding modul relay |
| 11 | | IN1 (Relay 2 - 1 Ch / 30A) | **GPIO 14** | Output Kontrol | Kontrol **Heater** (Active-Low dengan Hi-Z Bypass)  |
| 12 | | IN2 (Relay 1 - 4 Ch) | **GPIO 27** | Output Kontrol | Kontrol **Lampu UV Sterilizer** (Active-Low dengan Hi-Z Bypass) |
| 13 | | IN4 (Relay 1 - 4 Ch) | **GPIO 26** | Output Kontrol | Kontrol **Power VCC Kipas PWM** (Active-Low dengan Hi-Z Bypass) |

---

## 2. Catatan Penting Pemasangan & Keamanan Elektrik

> [!IMPORTANT]
> **Kebutuhan Catu Daya 5V Eksternal/Vin**:
> - **Sensor Gas MQ-135**: Sensor ini memerlukan pemanas internal (*heating element*) agar peka mendeteksi gas bau. Hubungkan pin VCC sensor ke **Vin (5V)** ESP32, bukan pin 3.3V. Menghubungkannya ke 3.3V akan membuat pembacaan sensor tidak akurat.
> - **Modul Relay**: Coil elektromagnetik pada relay memerlukan tegangan 5V stabil agar dapat beralih saklar (*switching*) secara sempurna. Hubungkan VCC relay ke **Vin (5V)** ESP32.

> [!TIP]
> **Logika Aktif Relay & Hi-Z State Bypass**:
> Seluruh modul relay menggunakan logika **Active-Low** (`LOW` untuk menyalakan). Namun, karena modul relay menggunakan catu daya 5V sedangkan logika GPIO ESP32 adalah 3.3V, terjadi perbedaan tegangan $5\text{V} - 3.3\text{V} = 1.7\text{V}$ saat ESP32 mengirim sinyal `HIGH`. Sisa tegangan 1.7V ini cukup untuk membuat optocoupler pada relay tetap menyala (sehingga relay tidak bisa mati).
>
> Untuk mengatasi ini, firmware menggunakan metode **Hi-Z State Bypass**:
> - **Menyalakan Relay (`active = true`)**: GPIO dikonfigurasi sebagai `OUTPUT` dan diberi nilai `LOW` (0V). Arus mengalir lancar, relay menyala.
> - **Mematikan Relay (`active = false`)**: GPIO dikonfigurasi sebagai `INPUT` (High-Impedance / Hi-Z). Hambatan pin naik hingga skala Gigaohm sehingga memutus total aliran arus bocor dari VCC 5V (0 mA). Optocoupler padam sepenuhnya dan relay mati seketika.
