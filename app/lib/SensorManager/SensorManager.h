/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - SENSOR MANAGER (RAMAH PEMULA)
 * =========================================================================
 * File: SensorManager.h
 * Deskripsi: Deklarasi fungsi pembacaan sensor DHT22 & MQ-135 secara sederhana.
 * =========================================================================
 */

#ifndef SENSORMANAGER_H
#define SENSORMANAGER_H

#include <Arduino.h>

// Inisialisasi awal modul sensor
void sensor_setup();

// Membaca suhu dari DHT22 (°C)
float sensor_read_temperature();

// Membaca kelembapan dari DHT22 (%)
float sensor_read_humidity();

// Membaca kadar gas dari MQ-135 (dengan penyaringan noise ADC)
float sensor_read_gas_level();

#endif // SENSORMANAGER_H
