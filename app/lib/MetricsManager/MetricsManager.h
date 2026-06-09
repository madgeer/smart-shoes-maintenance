#ifndef METRICS_MANAGER_H
#define METRICS_MANAGER_H

#include <Arduino.h>

// Inisialisasi NVS Flash untuk memuat metrik tersimpan
void metrics_setup();

// Memperbarui metrik di RAM dan menyinkronkan ke Flash berkala
void metrics_update(float elapsedSeconds, bool heaterOn, bool fanOn, bool uvOn);

// Memaksa sinkronisasi metrik dari RAM ke Flash NVS saat ini
void metrics_sync_to_flash();

// Ambil durasi pemakaian (satuan jam)
float metrics_get_duration_usage();
float metrics_get_fan_usage_duration();
float metrics_get_uv_usage_duration();

#endif // METRICS_MANAGER_H
