/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - METRICS MANAGER (RAMAH PEMULA)
 * =========================================================================
 * File: MetricsManager.cpp
 * Deskripsi: Pustaka pencatatan metrik persisten menggunakan fungsi global.
 * =========================================================================
 */

#include "MetricsManager.h"
#include <Preferences.h>
#include <Config.h>

// Objek penyimpan data bawaan ESP32 dan variabel global RAM
static Preferences prefs;
static float durationUsage = 0.0f;
static float fanUsageDuration = 0.0f;
static float uvUsageDuration = 0.0f;
static unsigned long lastSyncMillis = 0;

void metrics_setup() {
    Serial.println("[METRICS] Membuka NVS Flash 'shoe_metrics'...");
    
    // Buka namespace "shoe_metrics" (false = read/write)
    prefs.begin("shoe_metrics", false);
    
    // Muat data metrik lama dari Flash NVS. Jika kosong, default ke 0.0
    durationUsage = prefs.getFloat("dur", 0.0f);
    fanUsageDuration = prefs.getFloat("fan", 0.0f);
    uvUsageDuration = prefs.getFloat("uv", 0.0f);
    
    prefs.end();
    
    lastSyncMillis = millis();

    Serial.printf("[METRICS] Metrik dimuat:\n");
    Serial.printf("   - Total Aktif  : %.4f jam\n", durationUsage);
    Serial.printf("   - Kipas Aktif  : %.4f jam\n", fanUsageDuration);
    Serial.printf("   - UV Aktif     : %.4f jam\n", uvUsageDuration);
}

void metrics_update(float elapsedSeconds, bool heaterActive, bool fanActive, bool uvActive) {
    float elapsedHours = elapsedSeconds / 3600.0f;

    // Tambahkan waktu berjalan di RAM jika ada aktivitas sistem
    if (heaterActive || fanActive || uvActive) {
        durationUsage += elapsedHours;
    }
    if (fanActive) {
        fanUsageDuration += elapsedHours;
    }
    if (uvActive) {
        uvUsageDuration += elapsedHours;
    }

    // Auto-sync berkala dari RAM ke memori NVS Flash setiap 5 menit (mencegah aus memori)
    unsigned long currentMillis = millis();
    if (currentMillis - lastSyncMillis >= (METRICS_SYNC_INTERVAL_S * 1000)) {
        metrics_sync_to_flash();
    }
}

void metrics_sync_to_flash() {
    Serial.println("[METRICS] Menyimpan data RAM ke Flash NVS (Sync)...");
    
    prefs.begin("shoe_metrics", false);
    
    prefs.putFloat("dur", durationUsage);
    prefs.putFloat("fan", fanUsageDuration);
    prefs.putFloat("uv", uvUsageDuration);
    
    prefs.end();
    
    lastSyncMillis = millis();
    Serial.println("[METRICS] Sinkronisasi data sukses.");
}

void metrics_reset() {
    Serial.println("[METRICS] Mereset data metrik secara permanen di Flash NVS!");
    
    prefs.begin("shoe_metrics", false);
    prefs.clear(); // Hapus seluruh namespace
    prefs.end();

    durationUsage = 0.0f;
    fanUsageDuration = 0.0f;
    uvUsageDuration = 0.0f;
    
    lastSyncMillis = millis();
    Serial.println("[METRICS] Reset metrik sukses.");
}

float metrics_get_duration_usage() { return durationUsage; }
float metrics_get_fan_usage_duration() { return fanUsageDuration; }
float metrics_get_uv_usage_duration() { return uvUsageDuration; }
