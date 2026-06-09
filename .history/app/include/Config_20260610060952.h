
#ifndef CONFIG_H
#define CONFIG_H

#include <Arduino.h>

//kredensial WiFi
#define WIFI_SSID "Tenda_D8BDA0"   // ssid WiFi 
#define WIFI_PASSWORD "bodoamat12" // password WiFi 

//konfigurasi Broker MQTT Mosquitto
#define MQTT_BROKER "192.168.0.188" // iP komputer 
#define MQTT_PORT 1883
#define MQTT_USER "" // kosongkan jika tanpa auth
#define MQTT_PASS "" // Kosongkan jika tanpa auth

//identitas Perangkat (Harus terdaftar di database 'devices')

#define DEVICE_CODE "ESP32-SHOE-001" 
#define SHOE_ID 1                   

//konfigurasi Sensor (DHT22 & MQ-135)
// 
#define DHT_PIN 25    //pin dht
#define DHT_TYPE DHT22 // tipe sensor dht22
#define MQ135_PIN 36   // pin mq135
#define TRIG_US 12     // pin trig ultrasonik
#define ECHO_US 13     // pin echo ultrasonik
#define DISTANCE_THRESHOLD 15.0f // jarak threshold deteksi sepatu (cm)

// Konfigurasi aktuator relay
#define RELAY_HEATER_ACTIVE_STATE LOW // relay 30A Heater: active-Low
#define RELAY_UV_ACTIVE_STATE HIGH    // relay 4-Channel Ch 3 fan: active-high 
#define RELAY_FAN_ACTIVE_STATE HIGH   // relay 4-Channel Ch 4 uv: active-high 

// konfigurasi penggunaan hi-z bypass (hanya untuk modul relay tertentu yang bocor arus)
#define RELAY_HEATER_USE_HIZ true
#define RELAY_UV_USE_HIZ false
#define RELAY_FAN_USE_HIZ false

#define RELAY_HEATER_PIN 14    // relay 30A Hairdryer (heater)
#define RELAY_UV_PIN 27        // relay Ch 4: uv
#define RELAY_FAN_POWER_PIN 26   // relay Ch 3: fan


// pengaman Kecepatan Blower simulasi 
#define MIN_FAN_SPEED 120
#define NORMAL_FAN_SPEED 180

//pengaturan interval & sinkronisasi
#define TELEMETRY_INTERVAL_MS 5000  // interval kirim telemetri (5 detik)
#define METRICS_SYNC_INTERVAL_S 300 // interval simpan metrik ke NVS Flash (5 menit)

#endif