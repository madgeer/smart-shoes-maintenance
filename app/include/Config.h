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
#define WIFI_SSID       "Tenda_D8BDA0"        // SSID WiFi Anda
#define WIFI_PASSWORD   "bodoamat12"          // Password WiFi Anda

// 2. Konfigurasi Broker MQTT Mosquitto
// -------------------------------------------------------------------------
#define MQTT_BROKER     "192.168.0.195"       // IP komputer Host Anda
#define MQTT_PORT       1883
#define MQTT_USER       ""                    // Kosongkan jika tanpa auth
#define MQTT_PASS       ""                    // Kosongkan jika tanpa auth

// 3. Identitas Perangkat (Harus terdaftar di database 'devices')
// -------------------------------------------------------------------------
#define DEVICE_CODE     "ESP32-SHOE-001"      // Kode unik perangkat
#define SHOE_ID         1                     // ID sepatu yang aktif (default: 1)

// 4. Konfigurasi Sensor (DHT22 & MQ-135)
// -------------------------------------------------------------------------
#define DHT_PIN         25                   // Pin data digital sensor DHT11/DHT22 (Sesuai wiring.md)
#define DHT_TYPE        DHT22              // Tipe sensor DHT (Diubah ke DHT11)
#define MQ135_PIN       36                 // Pin input analog untuk MQ-135 (Pin SP / GPIO 36)

// 5. Konfigurasi Aktuator (Relay 4-Channel & PWM Fan)
// -------------------------------------------------------------------------
// Relay: Konfigurasi Active State masing-masing pin
#define RELAY_HEATER_ACTIVE_STATE  LOW              // Relay 2: 30A/1-Channel Heater: Active-Low (Menggunakan Hi-Z Bypass)
#define RELAY_UV_ACTIVE_STATE      LOW              // Relay 1: 4-Channel Ch 2 UV: Active-Low (Standard Digital Output)
#define RELAY_FAN_ACTIVE_STATE     LOW              // Relay 1: 4-Channel Ch 4 Fan: Active-Low (Standard Digital Output)

// Konfigurasi Penggunaan Hi-Z Bypass (hanya untuk modul relay tertentu yang bocor arus)
#define RELAY_HEATER_USE_HIZ       true
#define RELAY_UV_USE_HIZ           false
#define RELAY_FAN_USE_HIZ          false

#define RELAY_HEATER_PIN     14               // Relay Ch 1: Plate Heater (Sesuai wiring.md)
#define RELAY_UV_PIN         27               // Relay Ch 2: Lampu UV Sterilisator (Sesuai wiring.md) - Disesuaikan dengan fisik
#define RELAY_FAN_POWER_PIN  26               // Relay Ch 4: Power Line VCC Kipas PWM (Sesuai wiring.md) - Disesuaikan dengan fisik

// Pengaman Kecepatan Blower simulasi (untuk interlock saja)
#define MIN_FAN_SPEED        120
#define NORMAL_FAN_SPEED     180

// 6. Pengaturan Interval & Sinkronisasi
// -------------------------------------------------------------------------
#define TELEMETRY_INTERVAL_MS   5000          // Interval kirim telemetri (5 detik)
#define METRICS_SYNC_INTERVAL_S  300          // Interval simpan metrik ke NVS Flash (5 menit)

#endif // CONFIG_H