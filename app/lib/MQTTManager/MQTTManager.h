/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - MQTT MANAGER (RAMAH PEMULA)
 * =========================================================================
 * File: MQTTManager.h
 * Deskripsi: Deklarasi fungsi sederhana untuk menangani protokol MQTT & JSON.
 * =========================================================================
 */

#ifndef MQTTMANAGER_H
#define MQTTMANAGER_H

#include <Arduino.h>
#include <WiFi.h>

// Inisialisasi awal topik dan Client ID
void mqtt_setup();

// Loop berkala untuk menjaga koneksi ke broker & memproses antrean pesan
void mqtt_loop(WiFiClient& wifiClient);

// Cek status koneksi ke broker
bool mqtt_is_connected();

// Publikasikan data telemetri berformat JSON
bool mqtt_publish_telemetry(float temp, float hum, float gas, 
                            float duration, float fanDur, float uvDur);

// Publikasikan status online / offline
bool mqtt_publish_status(const char* status);

#endif // MQTTMANAGER_H
