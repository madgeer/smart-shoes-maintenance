/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - MQTT MANAGER
 * =========================================================================
 * File: MQTTManager.h
 * Deskripsi: Deklarasi modul komunikasi MQTT untuk ESP32.
 * =========================================================================
 */

#ifndef MQTT_MANAGER_H
#define MQTT_MANAGER_H

#include <Arduino.h>
#include <WiFi.h>

// Inisialisasi konfigurasi MQTT
void mqtt_setup();

// Memelihara koneksi dan memproses event loop MQTT
void mqtt_loop(WiFiClient& wifiClient);

// Publikasi data telemetri & metrik ke broker MQTT
void mqtt_publish_telemetry(float temp, float hum, float gas, 
                            float durTotal, float durFan, float durUV);

// Cek apakah terhubung ke broker MQTT
bool mqtt_is_connected();

#endif // MQTT_MANAGER_H
