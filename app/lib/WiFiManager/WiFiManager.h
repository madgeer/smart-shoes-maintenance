/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - WIFI MANAGER (RAMAH PEMULA)
 * =========================================================================
 * File: WiFiManager.h
 * Deskripsi: Deklarasi fungsi sederhana untuk mengelola koneksi WiFi.
 *            Sengaja dibuat tanpa Class agar mudah dipahami pemula.
 * =========================================================================
 */

#ifndef WIFIMANAGER_H
#define WIFIMANAGER_H

#include <Arduino.h>

// Fungsi inisialisasi WiFi
void wifi_setup();

// Fungsi loop berkala untuk menjaga koneksi (non-blocking)
void wifi_loop();

// Cek apakah WiFi terhubung
bool wifi_is_connected();

// Dapatkan alamat IP lokal perangkat
String wifi_get_ip();

#endif // WIFIMANAGER_H
