
#ifndef SENSOR_MANAGER_H
#define SENSOR_MANAGER_H

#include <Arduino.h>

// inisialisasi pin dan objek sensor
void sensor_setup();

// membaca suhudari sensor DHT22
float sensor_read_temperature();

// membaca kelembapan dari sensor DHT22
float sensor_read_humidity();

// membaca nilai kadar gas  dari sensor MQ-135
float sensor_read_gas_level();

// membaca jarak (cm) menggunakan sensor ultrasonik
float sensor_read_distance();

// mengecek apakah terdapat sepatu di dalam boks (jarak < DISTANCE_THRESHOLD)
bool sensor_is_shoe_present();

#endif // SENSOR_MANAGER_H
