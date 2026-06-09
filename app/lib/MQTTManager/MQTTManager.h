#ifndef MQTT_MANAGER_H
#define MQTT_MANAGER_H

#include <Arduino.h>
#include <WiFi.h>

// insialiasasi konfigurasi MQTT
void mqtt_setup();

// memelihara koneksi dan memproses event loop MQTT
void mqtt_loop(WiFiClient& wifiClient);

// publikasi data telemetri & metrik ke broker MQTT
void mqtt_publish_telemetry(float temp, float hum, float gas, 
                            float durTotal, float durFan, float durUV,
                            bool shoePresent);

// cek apakah terhubung ke broker MQTT
bool mqtt_is_connected();

#endif // MQTT_MANAGER_H
