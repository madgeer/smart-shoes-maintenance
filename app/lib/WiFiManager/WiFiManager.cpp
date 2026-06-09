#include "WiFiManager.h"
#include <WiFi.h>
#include <Config.h>

static unsigned long lastWifiCheck = 0;

// Fungsi untuk menginisialisasi koneksi WiFi
void wifi_setup() {
    Serial.println("\n[WIFI] Memulai koneksi WiFi...");
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    
    // tunggu koneksi saat startup (maksimal 10 detik)
    int retries = 0;
    while (WiFi.status() != WL_CONNECTED && retries < 20) {
        delay(500);
        Serial.print(".");
        retries++;
    }
    
    if (WiFi.status() == WL_CONNECTED) {
        Serial.printf("\n[WIFI] Sukses terhubung! IP: %s\n", WiFi.localIP().toString().c_str());
    } else {
        Serial.println("\n[WIFI] Gagal terhubung pada startup. Reconnect loop aktif di background.");
    }
}

void wifi_loop() {
    unsigned long currentMillis = millis();
    // periksa status WiFi secara berkala setiap 10 detik (non-blocking)
    if (currentMillis - lastWifiCheck >= 10000) {
        lastWifiCheck = currentMillis;
        
        if (WiFi.status() != WL_CONNECTED) {
            Serial.println("[WIFI] Koneksi terputus! Mencoba menghubungkan kembali...");
            WiFi.disconnect();
            WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
        }
    }
}

// Fungsi untuk memeriksa apakah WiFi terhubung
bool wifi_is_connected() {
    return (WiFi.status() == WL_CONNECTED);
}


String wifi_get_ip() {
    if (wifi_is_connected()) {
        return WiFi.localIP().toString();
    }
    return "0.0.0.0";
}
