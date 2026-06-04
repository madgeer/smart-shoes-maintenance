/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - WIFI MANAGER
 * =========================================================================
 * File: WiFiManager.h
 * Deskripsi: Deklarasi modul wifi untuk ESP32.
 * =========================================================================
 */

#ifndef WIFI_MANAGER_H
#define WIFI_MANAGER_H

#include <Arduino.h>

// Inisialisasi koneksi WiFi awal
void wifi_setup();

// Loop pemantauan status koneksi WiFi secara non-blocking
void wifi_loop();

// Cek apakah WiFi terhubung
bool wifi_is_connected();

// Ambil string alamat IP lokal perangkat
String wifi_get_ip();

#endif // WIFI_MANAGER_H
