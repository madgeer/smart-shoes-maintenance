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
    
    // Inisialisasi pin ultrasonik
    Serial.printf("[SENSOR] Mengatur pin Ultrasonik TRIG pada GPIO %d dan ECHO pada GPIO %d...\n", TRIG_US, ECHO_US);
    pinMode(TRIG_US, OUTPUT);
    pinMode(ECHO_US, INPUT);
     
    // Pastikan Trig pin berkeadaan mati (LOW) di awal
    digitalWrite(TRIG_US, LOW);
    
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

float sensor_read_distance() {
    // Pastikan Trig pin bersih/LOW terlebih dahulu
    digitalWrite(TRIG_US, LOW);
    delayMicroseconds(2);
    
    // Kirim sinyal trigger HIGH selama 10 mikrodetik
    digitalWrite(TRIG_US, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG_US, LOW);
    
    // Baca durasi pulsa HIGH pada Echo pin (dengan batas timeout 30ms / 30000us)
    long duration = pulseIn(ECHO_US, HIGH, 30000);
    
    if (duration == 0) {
        return 999.0f; // Sinyal tidak kembali (out of range)
    }
    
    // Hitung jarak dalam cm (kecepatan suara = 0.0343 cm/us)
    float distance = (duration * 0.0343f) / 2.0f;
    return distance;
}

bool sensor_is_shoe_present() {
    float distance = sensor_read_distance();
    // Serial print opsional untuk mempermudah kalibrasi dan debugging fisik
    Serial.printf("[SENSOR-US] Jarak terdeteksi: %.2f cm\n", distance);
    return (distance > 1.0f && distance < DISTANCE_THRESHOLD);
}
