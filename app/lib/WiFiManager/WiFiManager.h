#ifndef WIFI_MANAGER_H
#define WIFI_MANAGER_H

#include <Arduino.h>

// inisialisasi koneksi WiFi awal
void wifi_setup();

// loop pemantauan status koneksi WiFi secara non-blocking
void wifi_loop();

// cek apakah WiFi terhubung
bool wifi_is_connected();

// ambil string alamat IP lokal perangkat
String wifi_get_ip();

#endif
