/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - SENSOR MANAGER (RAMAH PEMULA)
 * =========================================================================
 * File: SensorManager.cpp
 * Deskripsi: Pustaka pembacaan sensor menggunakan fungsi global sederhana.
 * =========================================================================
 */

#include "SensorManager.h"
#include <DHT.h>
#include <Config.h>

// Inisialisasi Objek DHT secara statis (gaya Arduino standar)
DHT dht(DHT_PIN, DHT_TYPE);

// Fungsi internal pembantu untuk meratakan pembacaan ADC (moving average)
static float filter_analog_read(uint8_t pin, int samples) {
    long sum = 0;
    for (int i = 0; i < samples; i++) {
        sum += analogRead(pin);
        delay(5); // Jeda singkat agar ADC stabil
    }
    return (float)sum / samples;
}

void sensor_setup() {
    Serial.println("[SENSOR] Mengaktifkan sensor DHT22...");
    dht.begin();
    
    pinMode(MQ135_PIN, INPUT);
    Serial.println("[SENSOR] Sensor MQ-135 dan DHT22 siap.");
}

float sensor_read_temperature() {
    float t = dht.readTemperature();
    
    // Jika DHT22 tidak terbaca (NaN), berikan fallback suhu ruangan aman
    if (isnan(t)) {
        Serial.println("[SENSOR] WARNING: Gagal membaca suhu DHT22! Menggunakan fallback 25.0 °C.");
        return 25.0;
    }
    return t;
}

float sensor_read_humidity() {
    float h = dht.readHumidity();
    
    // Jika DHT22 tidak terbaca (NaN), berikan fallback kelembapan sedang aman
    if (isnan(h)) {
        Serial.println("[SENSOR] WARNING: Gagal membaca kelembapan DHT22! Menggunakan fallback 50.0 %.");
        return 50.0;
    }
    return h;
}

float sensor_read_gas_level() {
    // Saring noise pembacaan analog dari pin MQ-135 dengan rata-rata 10 kali baca
    float rawAverage = filter_analog_read(MQ135_PIN, 10);
    
    // Jika sensor terlepas atau terbaca 0, berikan nilai aman 150 ppm (udara bersih)
    if (rawAverage <= 0.1) {
        return 150.0;
    }
    
    // Konversi nilai ADC (0-4095) ke simulasi nilai PPM (100 - 1000) secara linier
    float ppmSimulated = (rawAverage / 4095.0) * 1000.0;
    
    if (ppmSimulated < 120.0) ppmSimulated = 120.0;
    
    return ppmSimulated;
}
