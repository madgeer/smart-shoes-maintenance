/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - SENSOR MANAGER IMPLEMENTATION
 * =========================================================================
 * File: SensorManager.cpp
 * =========================================================================
 */

#include "SensorManager.h"
#include <Config.h>
#include <DHT.h>

static DHT dht(DHT_PIN, DHT_TYPE);

void sensor_setup() {
    Serial.printf("[SENSOR] Menginisialisasi DHT22 pada GPIO %d...\n", DHT_PIN);
    dht.begin();
    
    Serial.printf("[SENSOR] Mengatur pin analog input MQ-135 pada GPIO %d...\n", MQ135_PIN);
    pinMode(MQ135_PIN, INPUT);
    
    Serial.println("[SENSOR] Seluruh modul sensor siap dibaca.");
}

float sensor_read_temperature() {
    float t = dht.readTemperature();
    // Jika pembacaan gagal (NaN), berikan nilai default ruangan 25.0 °C
    if (isnan(t)) {
        return 25.0f;
    }
    return t;
}

float sensor_read_humidity() {
    float h = dht.readHumidity();
    // Jika pembacaan gagal (NaN), berikan nilai default kelembapan 50.0 %
    if (isnan(h)) {
        return 50.0f;
    }
    return h;
}

float sensor_read_gas_level() {
    // Membaca ADC 12-bit (0-4095) bawaan ESP32
    int adcVal = analogRead(MQ135_PIN);
    
    // Konversi sederhana ADC ke rentang perkiraan kadar gas ppm (100 - 1000 ppm)
    float ppm = 100.0f + (adcVal / 4095.0f) * 900.0f;
    return ppm;
}
