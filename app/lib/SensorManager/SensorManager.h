/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - SENSOR MANAGER
 * =========================================================================
 * File: SensorManager.h
 * Deskripsi: Deklarasi modul pembacaan sensor DHT22 & MQ-135.
 * =========================================================================
 */

#ifndef SENSOR_MANAGER_H
#define SENSOR_MANAGER_H

#include <Arduino.h>

// Inisialisasi pin dan objek sensor
void sensor_setup();

// Membaca suhu (°C) dari sensor DHT22
float sensor_read_temperature();

// Membaca kelembapan (%) dari sensor DHT22
float sensor_read_humidity();

// Membaca nilai kadar gas (ppm) dari sensor MQ-135
float sensor_read_gas_level();

#endif // SENSOR_MANAGER_H
