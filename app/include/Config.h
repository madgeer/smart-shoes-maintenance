/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - ESP32 GLOBAL CONFIGURATION
 * =========================================================================
 * File: Config.h
 * Deskripsi: Menyimpan kredensial WiFi, broker MQTT, topik, dan pemetaan
 *            pin hardware secara terpusat berdasarkan docs/wiring.md.
 * =========================================================================
 */

#ifndef CONFIG_H
#define CONFIG_H

#include <Arduino.h>

// 1. Kredensial WiFi
// -------------------------------------------------------------------------
#define WIFI_SSID "Tenda_D8BDA0"   // SSID WiFi Anda
#define WIFI_PASSWORD "bodoamat12" // Password WiFi Anda

// 2. Konfigurasi Broker MQTT Mosquitto
// -------------------------------------------------------------------------
<<<<<<< HEAD
// CATATAN: Jangan gunakan "localhost" karena ESP32 tidak bisa mengakses localhost host.
// Gunakan alamat IP komputer Anda yang menjalankan Docker/Mosquitto (contoh: "192.168.1.50")
#define MQTT_BROKER     "192.168.0.188"       // Ganti dengan IP komputer Host Anda
#define MQTT_PORT       1883
#define MQTT_USER       ""                    // Kosongkan jika broker tanpa autentikasi
#define MQTT_PASS       ""                    // Kosongkan jika broker tanpa autentikasi
=======
#define MQTT_BROKER "192.168.0.188" // IP komputer Host Anda
#define MQTT_PORT 1883
#define MQTT_USER "" // Kosongkan jika tanpa auth
#define MQTT_PASS "" // Kosongkan jika tanpa auth
>>>>>>> b651717 (Refactor and enhance Smart Shoes Maintenance firmware)

// 3. Identitas Perangkat (Harus terdaftar di database 'devices')
// -------------------------------------------------------------------------
#define DEVICE_CODE "ESP32-SHOE-001" // Kode unik perangkat
#define SHOE_ID 1                    // ID sepatu yang aktif (default: 1)

// 4. Konfigurasi Sensor (DHT22 & MQ-135)
// -------------------------------------------------------------------------
<<<<<<< HEAD
#define DHT_PIN         23                    // Pin data digital sensor DHT22
#define DHT_TYPE        DHT22                 // Tipe sensor DHT (DHT22 / DHT11)
#define MQ135_PIN       34                    // Pin input analog ADC1 untuk MQ-135 (GPIO 34 aman dari interferensi WiFi)
=======
#define DHT_PIN 18     // Pin data digital sensor DHT22 (Sesuai wiring.md)
#define DHT_TYPE DHT22 // Tipe sensor DHT
#define MQ135_PIN 34   // Pin input analog untuk MQ-135
>>>>>>> b651717 (Refactor and enhance Smart Shoes Maintenance firmware)

// 5. Konfigurasi Aktuator (Relay 4-Channel & PWM Fan)
// -------------------------------------------------------------------------
// Relay: Konfigurasi Active-Low (Relay aktif saat pin diberi nilai LOW)
#define RELAY_ACTIVE_STATE LOW

<<<<<<< HEAD
#define RELAY_HEATER_PIN     18               // Relay Ch 1: Plate Heater (PLT)
#define RELAY_UV_PIN         19               // Relay Ch 2: Lampu UV Sterilisator
#define RELAY_BLOWER_PIN     21               // Relay Ch 3: Blower Sirkulasi Utama
#define RELAY_FAN_POWER_PIN  22               // Relay Ch 4: Power Line VCC Kipas PWM

// PWM Fan: Sinyal kontrol kecepatan
#define PWM_FAN_SPEED_PIN    25               // Pin kontrol kecepatan PWM Fan (GPIO 25)
#define PWM_FAN_CHANNEL      0                // Channel LEDC ESP32 (0-15)
#define PWM_FAN_FREQ         25000            // Frekuensi PWM standar industri untuk Fan (25 kHz)
#define PWM_FAN_RES          8                // Resolusi PWM 8-bit (0-255)
=======
#define RELAY_HEATER_PIN 14    // Relay Ch 1: Plate Heater (Sesuai wiring.md)
#define RELAY_UV_PIN 26        // Relay Ch 2: Lampu UV Sterilisator (Sesuai wiring.md)
#define RELAY_FAN_POWER_PIN 27 // Relay Ch 4: Power Line VCC Kipas PWM (Sesuai wiring.md)

// Pengaman Kecepatan Blower simulasi (untuk interlock saja)
#define MIN_FAN_SPEED 120
#define NORMAL_FAN_SPEED 180
>>>>>>> b651717 (Refactor and enhance Smart Shoes Maintenance firmware)

// 6. Pengaturan Interval & Sinkronisasi
// -------------------------------------------------------------------------
#define TELEMETRY_INTERVAL_MS 5000  // Interval kirim telemetri (5 detik)
#define METRICS_SYNC_INTERVAL_S 300 // Interval simpan metrik ke NVS Flash (5 menit)

#endif // CONFIG_H
