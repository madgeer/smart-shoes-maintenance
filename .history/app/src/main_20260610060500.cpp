#include <Arduino.h>
#include <Config.h>
#include <WiFiManager.h>
#include <SensorManager.h>
#include <ActuatorManager.h>
#include <MetricsManager.h>
#include <MQTTManager.h>

// Objek Jaringan Client bawaan library WiFi.h
WiFiClient wifiClient;

// variabel Pencatat Waktu
unsigned long lastLoopMillis = 0;
unsigned long lastTelemetryMillis = 0;
unsigned long lastLocalMonitorMillis = 0;
unsigned long lastUltrasonicMillis = 0;

// Fungsi ini otomatis dipanggil oleh MQTTManager ketika menerima data perintah
void handle_gateway_command(const char* commandId, const char* heaterState, 
                            const char* uvState, const char* fanState, 
                            const char* mode) {
    Serial.println("\n[MAIN] Ada perintah baru masuk dari Gateway!");

    // ubah status "ON"/"OFF" dari teks menjadi tipe boolean (true/false)
    bool statusHeater = (strcmp(heaterState, "ON") == 0);
    bool statusUV     = (strcmp(uvState, "ON") == 0);
    bool statusFan    = (strcmp(fanState, "ON") == 0);

    // aktifkan relay pemanas, uv, dan kipas power
    actuator_set_heater(statusHeater);
    actuator_set_uv(statusUV);
    actuator_set_blower(statusFan);

    // aktifkan Kecepatan Kipas (Simulasi/Dummy kompatibilitas)
    actuator_set_fan_speed(statusFan ? NORMAL_FAN_SPEED : 0);

    Serial.println("[MAIN] Perintah sukses dijalankan.");
}
void setup() {
    //menyalakan Serial Monitor untuk memantau log program
    Serial.begin(115200);
    delay(1000);
    
    Serial.println("\n=============================================================");
    Serial.println(" SMART SHOE MAINTENANCE FIRMWARE - ESP32 SYSTEM STARTUP");
    Serial.println("=============================================================");

    //setup Modul Aktuator
    actuator_setup();

    //setup Modul Sensor
    sensor_setup();

    //setup Modul Penyimpanan Metrik Pemakaian
    metrics_setup();

    //sambungkan ke jaringan WiFi
    wifi_setup();

    //hubungkan Sinkronisasi Waktu Dunia (NTP) agar timestamp akurat
    configTime(0, 0, "pool.ntp.org", "time.nist.gov");
    Serial.println("[MAIN] Menghubungkan sinkronisasi waktu ke internet (NTP)...");

    //setup topik & identitas MQTT Broker
    mqtt_setup();

    //tandai waktu awal berjalan
    lastLoopMillis = millis();
    lastTelemetryMillis = millis();
    lastLocalMonitorMillis = millis();

    Serial.println("\n[MAIN] Sistem Siap! Memasuki loop utama program...\n");
}

void loop() {
    unsigned long currentMillis = millis();

    //jalankan loop WiFi & MQTT di latar belakang (non-blocking)
    wifi_loop();
    mqtt_loop(wifiClient);

    //hitung selisih waktu berjalan untuk melacak metrik penggunaan aktif alat
    float elapsedSeconds = (currentMillis - lastLoopMillis) / 1000.0f;
    lastLoopMillis = currentMillis;

    //pastikan tidak ada lonjakan nilai jika terjadi luapan (overflow millis)
    if (elapsedSeconds > 0 && elapsedSeconds < 60.0f) {
        metrics_update(
            elapsedSeconds, 
            actuator_is_heater_on(), 
            actuator_is_blower_on(), 
            actuator_is_uv_on()
        );
    }

    //mengukur Jarak & Mengirimkan Telemetri Sensor / Metrik
    //baca ultrasonik setiap 1 detik secara non-blocking
    static bool lastShoePresent = false;
    static bool firstRead = true;
    
    if (currentMillis - lastUltrasonicMillis >= 1000) {
        lastUltrasonicMillis = currentMillis;
        bool isPresent = sensor_is_shoe_present();
        
        //kirim telemetri instan jika status kehadiran berubah 
        if (firstRead || isPresent != lastShoePresent) {
            firstRead = false;
            lastShoePresent = isPresent;
            
            float temp = sensor_read_temperature();
            float hum  = sensor_read_humidity();
            float gas  = sensor_read_gas_level();
            float durTotal = metrics_get_duration_usage();
            float durFan   = metrics_get_fan_usage_duration();
            float durUV    = metrics_get_uv_usage_duration();
            
            if (wifi_is_connected() && mqtt_is_connected()) {
                mqtt_publish_telemetry(temp, hum, gas, durTotal, durFan, durUV, isPresent);
                lastTelemetryMillis = currentMillis; // reset timer telemetri reguler
                Serial.println("[MAIN] Mengirim telemetri instan akibat perubahan status kehadiran sepatu.");
            }
        }
    }

    //kirim data sensor reguler ke Cloud secara berkala setiap 5 detik
    if (currentMillis - lastTelemetryMillis >= TELEMETRY_INTERVAL_MS) {
        lastTelemetryMillis = currentMillis;

        float temp = sensor_read_temperature();
        float hum  = sensor_read_humidity();
        float gas  = sensor_read_gas_level();
        bool isPresent = lastShoePresent;

        float durTotal = metrics_get_duration_usage();
        float durFan   = metrics_get_fan_usage_duration();
        float durUV    = metrics_get_uv_usage_duration();

        if (wifi_is_connected() && mqtt_is_connected()) {
            mqtt_publish_telemetry(temp, hum, gas, durTotal, durFan, durUV, isPresent);
        } else {
            Serial.println("[MAIN] Pengiriman Telemetri tertunda: Koneksi terputus.");
        }
    }

    //cetak pemantauan lokal di Serial Monitor setiap 10 detik
    if (currentMillis - lastLocalMonitorMillis >= 10000) {
        lastLocalMonitorMillis = currentMillis;

        Serial.println("=============================================================");
        Serial.printf("[PEMANTAUAN] WiFi: %s | MQTT: %s | IP: %s\n", 
                      wifi_is_connected() ? "AKTIF" : "PUTUS", 
                      mqtt_is_connected() ? "AKTIF" : "PUTUS",
                      wifi_get_ip().c_str());
        Serial.printf("   - SENSOR   : Suhu: %.1f °C | Lembap: %.1f %% | Gas Bau: %.1f ppm\n", 
                      sensor_read_temperature(), sensor_read_humidity(), sensor_read_gas_level());
        Serial.printf("   - AKTUATOR : Heater: %s | UV: %s | Kipas: %s (Simulasi PWM: %d)\n", 
                      actuator_is_heater_on() ? "MENYALA" : "MATI",
                      actuator_is_uv_on() ? "MENYALA" : "MATI",
                      actuator_is_fan_power_on() ? "MENYALA" : "MATI",
                      actuator_get_fan_speed());
        Serial.printf("   - METRIK   : Total Aktif: %.4f jam | Kipas: %.4f jam | UV: %.4f jam\n",
                      metrics_get_duration_usage(), metrics_get_fan_usage_duration(), metrics_get_uv_usage_duration());
        Serial.println("=============================================================");
    }

    // Jeda 1 milidetik 
    delay(1);
}
