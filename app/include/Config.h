/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - ESP32 GLOBAL CONFIGURATION
 * =========================================================================
 * File: Config.h
 * Deskripsi: Menyimpan kredensial WiFi, broker MQTT, topik, dan pemetaan
 *            pin hardware secara terpusat.
 * =========================================================================
 */

#ifndef CONFIG_H
#define CONFIG_H

#include <Arduino.h>

// 1. Kredensial WiFi
// -------------------------------------------------------------------------
#define WIFI_SSID       "Tenda_D8BDA0"      // Ganti dengan SSID WiFi Anda
#define WIFI_PASSWORD   "bodoamat12"  // Ganti dengan Password WiFi Anda

// 2. Konfigurasi Broker MQTT Mosquitto
// -------------------------------------------------------------------------
// CATATAN: Jangan gunakan "localhost" karena ESP32 tidak bisa mengakses localhost host.
// Gunakan alamat IP komputer Anda yang menjalankan Docker/Mosquitto (contoh: "192.168.1.50")
#define MQTT_BROKER     "192.168.0.195"       // Ganti dengan IP komputer Host Anda
#define MQTT_PORT       1883
#define MQTT_USER       ""                    // Kosongkan jika broker tanpa autentikasi
#define MQTT_PASS       ""                    // Kosongkan jika broker tanpa autentikasi

// 3. Identitas Perangkat (Harus terdaftar di database 'devices')
// -------------------------------------------------------------------------
#define DEVICE_CODE     "ESP32-SHOE-001"      // Kode unik perangkat
#define SHOE_ID         1                     // ID sepatu yang aktif (secara default, Nike Air Max = 1)

// 4. Konfigurasi Sensor (DHT22 & MQ-135)
// -------------------------------------------------------------------------
#define DHT_PIN         4                     // Pin data digital sensor DHT22
#define DHT_TYPE        DHT22                 // Tipe sensor DHT (DHT22 / DHT11)
#define MQ135_PIN       34                    // Pin input analog ADC1 untuk MQ-135 (GPIO 34 aman dari interferensi WiFi)

// 5. Konfigurasi Aktuator (Relay 4-Channel & PWM Fan)
// -------------------------------------------------------------------------
// Relay: Konfigurasi Active-Low (Relay aktif saat pin diberi nilai LOW)
#define RELAY_ACTIVE_STATE   LOW              

#define RELAY_HEATER_PIN     14               // Relay Ch 1: Plate Heater (PLT)
#define RELAY_UV_PIN         12               // Relay Ch 2: Lampu UV Sterilisator
#define RELAY_BLOWER_PIN     26               // Relay Ch 3: Blower Sirkulasi Utama
#define RELAY_FAN_POWER_PIN  27               // Relay Ch 4: Power Line VCC Kipas PWM

// // PWM Fan: Sinyal kontrol kecepatan
// #define PWM_FAN_SPEED_PIN    25               // Pin kontrol kecepatan PWM Fan (GPIO 25)
// #define PWM_FAN_CHANNEL      0                // Channel LEDC ESP32 (0-15)
// #define PWM_FAN_FREQ         25000            // Frekuensi PWM standar industri untuk Fan (25 kHz)
// #define PWM_FAN_RES          8                // Resolusi PWM 8-bit (0-255)

// 6. Pengaturan Interval & Sinkronisasi
// -------------------------------------------------------------------------
#define TELEMETRY_INTERVAL_MS   5000          // Interval pengiriman telemetri (5 detik)
#define METRICS_SYNC_INTERVAL_S  300           // Interval sinkronisasi metrik dari RAM ke Flash NVS (5 menit / 300 detik)

#endif // CONFIG_H
