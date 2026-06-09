#include "MetricsManager.h"
#include <Config.h>
#include <Preferences.h>

static Preferences prefs;

static float durationTotal = 0.0f;
static float durationFan = 0.0f;
static float durationUV = 0.0f;

static unsigned long lastSyncTime = 0;

void metrics_setup() {
    // membuka ruang penyimpanan namespace "shoe_metrics" (Read/Write)
    prefs.begin("shoe_metrics", false);
    
    //muat data dari NVS Flash, default ke 0.0f jika belum ada
    durationTotal = prefs.getFloat("dur_total", 0.0f);
    durationFan   = prefs.getFloat("dur_fan", 0.0f);
    durationUV    = prefs.getFloat("dur_uv", 0.0f);
    
    lastSyncTime = millis();
    
    Serial.println("[METRIC] Sukses memuat riwayat pemakaian dari NVS Flash:");
    Serial.printf("   - Total Durasi: %.4f jam\n", durationTotal);
    Serial.printf("   - Kipas Aktif : %.4f jam\n", durationFan);
    Serial.printf("   - UV Aktif    : %.4f jam\n", durationUV);
}

void metrics_update(float elapsedSeconds, bool heaterOn, bool fanOn, bool uvOn) {
    // konversi detik ke jam (1 detik = 1 / 3600 jam)
    float hours = elapsedSeconds / 3600.0f;
    
    // akumlasi ke RAM
    durationTotal += hours;
    if (fanOn) {
        durationFan += hours;
    }
    if (uvOn) {
        durationUV += hours;
    }
    
    // Sinkronisasikan berkala ke Flash NVS untuk meminimalisir wear-out NVS sector
    unsigned long currentMillis = millis();
    if (currentMillis - lastSyncTime >= (METRICS_SYNC_INTERVAL_S * 1000)) {
        metrics_sync_to_flash();
    }
}

void metrics_sync_to_flash() {
    lastSyncTime = millis();
    
    prefs.putFloat("dur_total", durationTotal);
    prefs.putFloat("dur_fan", durationFan);
    prefs.putFloat("dur_uv", durationUV);
    
    Serial.println("[METRIC] 💾 Metrik sukses disinkronkan ke Flash NVS.");
}

float metrics_get_duration_usage() { return durationTotal; }
float metrics_get_fan_usage_duration() { return durationFan; }
float metrics_get_uv_usage_duration() { return durationUV; }
