/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - WIFI MANAGER (RAMAH PEMULA)
 * =========================================================================
 * File: WiFiManager.cpp
 * Deskripsi: Implementasi fungsi WiFi menggunakan variabel global sederhana.
 * =========================================================================
 */

#include "WiFiManager.h"
#include <WiFi.h>
#include <Config.h>

// Variabel lokal untuk mencatat waktu reconnect terakhir
unsigned long lastWifiReconnectAttempt = 0;
const unsigned long wifiReconnectInterval = 10000; // Coba reconnect setiap 10 detik

void wifi_setup() {
    // Atur mode ke Station
    WiFi.mode(WIFI_STA);
    
    Serial.println("\n[WIFI] Memulai koneksi WiFi...");
    Serial.printf("[WIFI] Menghubungkan ke SSID: %s...\n", WIFI_SSID);
    
    // Mulai koneksi asinkron (non-blocking)
    if (strlen(WIFI_PASSWORD) > 0) {
        WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    } else {
        WiFi.begin(WIFI_SSID);
    }
}

void wifi_loop() {
    // Jika koneksi terputus, coba hubungkan kembali setiap 10 detik secara asinkron
    if (!wifi_is_connected()) {
        unsigned long currentMillis = millis();
        if (currentMillis - lastWifiReconnectAttempt >= wifiReconnectInterval) {
            lastWifiReconnectAttempt = currentMillis;
            Serial.println("[WIFI] Koneksi terputus! Mencoba hubungkan kembali...");
            
            WiFi.disconnect();
            if (strlen(WIFI_PASSWORD) > 0) {
                WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
            } else {
                WiFi.begin(WIFI_SSID);
            }
        }
    }
}

bool wifi_is_connected() {
    return (WiFi.status() == WL_CONNECTED);
}

String wifi_get_ip() {
    if (wifi_is_connected()) {
        return WiFi.localIP().toString();
    }
    return "0.0.0.0";
}
