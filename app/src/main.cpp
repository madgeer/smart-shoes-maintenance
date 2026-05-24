/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - MAIN FIRMWARE (RAMAH PEMULA)
 * =========================================================================
 * File: main.cpp
 * Deskripsi: Berkas utama penggerak sistem. Dibuat sesederhana mungkin
 *            menggunakan gaya prosedural C/Arduino tanpa OOP Class.
 * =========================================================================
 */

#include <Arduino.h>
#include <Config.h>
#include <WiFiManager.h>
#include <SensorManager.h>
#include <ActuatorManager.h>
#include <MetricsManager.h>
#include <MQTTManager.h>

// Objek Jaringan Client dari bawaan library WiFi.h
WiFiClient wifiClient;

// Variabel Pencatat Waktu
unsigned long lastLoopMillis = 0;
unsigned long lastTelemetryMillis = 0;
unsigned long lastLocalMonitorMillis = 0;

// =========================================================================
// FUNGSI CALLBACK KONTROL AKTUATOR (DI-LINK SECARA ELEGANT VIA EXTERN)
// =========================================================================
// Fungsi ini otomatis dipanggil oleh MQTTManager ketika menerima data perintah
void handle_gateway_command(const char* commandId, const char* heaterState, 
                            const char* uvState, const char* fanState, 
                            const char* mode) {
    Serial.println("\n[MAIN] Ada perintah baru masuk dari Gateway!");

    // Ubah status "ON"/"OFF" dari teks menjadi tipe boolean (true/false)
    bool statusHeater = (strcmp(heaterState, "ON") == 0);
    bool statusUV     = (strcmp(uvState, "ON") == 0);
    bool statusFan    = (strcmp(fanState, "ON") == 0);

    // Aktifkan Relay Pemanas, UV, dan Blower
    actuator_set_heater(statusHeater);
    actuator_set_uv(statusUV);
    actuator_set_blower(statusFan);

    // Aktifkan Daya Kipas PWM & Set Kecepatan
    actuator_set_fan_power(statusFan);
    actuator_set_fan_speed(statusFan ? 180 : 0); // Kipas berputar level 180 jika ON

    Serial.println("[MAIN] Perintah sukses dijalankan.");
}

// =========================================================================
// FUNGSI INISIALISASI (STARTUP)
// =========================================================================
void setup() {
    // 1. Nyalakan Serial Monitor untuk memantau log program
    Serial.begin(115200);
    delay(1000);
    
    Serial.println("\n=============================================================");
    Serial.println(" SMART SHOE MAINTENANCE FIRMWARE - GAYA SEDERHANA RAMAH PEMULA");
    Serial.println("=============================================================");

    // 2. Setup Modul Aktuator (Relay & PWM Pin)
    actuator_setup();

    // 3. Setup Modul Sensor (DHT22 & MQ-135)
    sensor_setup();

    // 4. Setup Modul Penyimpanan Metrik Pemakaian (NVS Flash)
    metrics_setup();

    // 5. Sambungkan ke jaringan WiFi
    wifi_setup();

    // 6. Hubungkan Sinkronisasi Waktu Dunia (NTP) agar timestamp akurat
    configTime(0, 0, "pool.ntp.org", "time.nist.gov");
    Serial.println("[MAIN] Menghubungkan sinkronisasi waktu ke internet (NTP)...");

    // 7. Setup topik & identitas MQTT Broker
    mqtt_setup();

    // 8. Tandai waktu awal berjalan
    lastLoopMillis = millis();
    lastTelemetryMillis = millis();
    lastLocalMonitorMillis = millis();

    Serial.println("\n[MAIN] Sistem Siap! Memasuki loop utama program...\n");
}

// =========================================================================
// LOOP UTAMA (RUNNING BERULANG)
// =========================================================================
void loop() {
    unsigned long currentMillis = millis();

    // A. Jalankan loop WiFi & MQTT di latar belakang (non-blocking)
    wifi_loop();
    mqtt_loop(wifiClient);

    // B. Hitung selisih waktu berjalan untuk melacak metrik penggunaan aktif alat
    float elapsedSeconds = (currentMillis - lastLoopMillis) / 1000.0f;
    lastLoopMillis = currentMillis;

    // Pastikan tidak ada lonjakan nilai jika terjadi luapan (overflow millis)
    if (elapsedSeconds > 0 && elapsedSeconds < 60.0f) {
        metrics_update(
            elapsedSeconds, 
            actuator_is_heater_on(), 
            actuator_is_blower_on() || actuator_is_fan_power_on(), 
            actuator_is_uv_on()
        );
    }

    // C. Mengirimkan Telemetri Sensor & Metrik ke Cloud setiap 5 detik
    if (currentMillis - lastTelemetryMillis >= TELEMETRY_INTERVAL_MS) {
        lastTelemetryMillis = currentMillis;

        // 1. Ambil data sensor terkini
        float temp = sensor_read_temperature();
        float hum  = sensor_read_humidity();
        float gas  = sensor_read_gas_level();

        // 2. Ambil data akumulasi durasi dari NVS
        float durTotal = metrics_get_duration_usage();
        float durFan   = metrics_get_fan_usage_duration();
        float durUV    = metrics_get_uv_usage_duration();

        // 3. Kirim ke Broker MQTT jika jaringan aktif
        if (wifi_is_connected() && mqtt_is_connected()) {
            mqtt_publish_telemetry(temp, hum, gas, durTotal, durFan, durUV);
        } else {
            Serial.println("[MAIN] Pengiriman Telemetri tertunda: Koneksi terputus.");
        }
    }

    // D. Cetak pemantauan lokal di Serial Monitor setiap 10 detik
    if (currentMillis - lastLocalMonitorMillis >= 10000) {
        lastLocalMonitorMillis = currentMillis;

        Serial.println("=============================================================");
        Serial.printf("[PEMANTAUAN] WiFi: %s | MQTT: %s | IP: %s\n", 
                      wifi_is_connected() ? "AKTIF" : "PUTUS", 
                      mqtt_is_connected() ? "AKTIF" : "PUTUS",
                      wifi_get_ip().c_str());
        Serial.printf("   - SENSOR   : Suhu: %.1f °C | Lembap: %.1f %% | Gas Bau: %.1f ppm\n", 
                      sensor_read_temperature(), sensor_read_humidity(), sensor_read_gas_level());
        Serial.printf("   - AKTUATOR : Heater: %s | UV: %s | Blower: %s | Fan Power: %s (PWM: %d)\n", 
                      actuator_is_heater_on() ? "MENYALA" : "MATI",
                      actuator_is_uv_on() ? "MENYALA" : "MATI",
                      actuator_is_blower_on() ? "MENYALA" : "MATI",
                      actuator_is_fan_power_on() ? "MENYALA" : "MATI",
                      actuator_get_fan_speed());
        Serial.printf("   - METRIK   : Total Aktif: %.4f jam | Kipas: %.4f jam | UV: %.4f jam\n",
                      metrics_get_duration_usage(), metrics_get_fan_usage_duration(), metrics_get_uv_usage_duration());
        Serial.println("=============================================================");
    }

    // Jeda 1 milidetik untuk memberi nafas pada RTOS ESP32
    delay(1);
}