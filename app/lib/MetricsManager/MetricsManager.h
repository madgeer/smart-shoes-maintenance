/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - METRICS MANAGER (RAMAH PEMULA)
 * =========================================================================
 * File: MetricsManager.h
 * Deskripsi: Deklarasi fungsi sederhana untuk mencatat & menyimpan metrik
 *            pemakaian secara persisten ke NVS Flash ESP32.
 * =========================================================================
 */

#ifndef METRICSMANAGER_H
#define METRICSMANAGER_H

#include <Arduino.h>

// Inisialisasi awal NVS dan pemuatan data metrik tersimpan
void metrics_setup();

// Perbarui metrik waktu berjalan di RAM
void metrics_update(float elapsedSeconds, bool heaterActive, bool fanActive, bool uvActive);

// Sinkronisasi data RAM ke Flash NVS
void metrics_sync_to_flash();

// Mengosongkan/Reset total data metrik di Flash NVS
void metrics_reset();

// Getter untuk mendapatkan data metrik terakumulasi (satuan jam)
float metrics_get_duration_usage();
float metrics_get_fan_usage_duration();
float metrics_get_uv_usage_duration();

#endif // METRICSMANAGER_H
