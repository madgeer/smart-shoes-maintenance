/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - ACTUATOR MANAGER
 * =========================================================================
 * File: ActuatorManager.h
 * Deskripsi: Deklarasi modul pengontrol relay Heater, UV, dan Kipas.
 * =========================================================================
 */

#ifndef ACTUATOR_MANAGER_H
#define ACTUATOR_MANAGER_H

#include <Arduino.h>

// Inisialisasi pin relay
void actuator_setup();

// Kontrol saklar Heater
void actuator_set_heater(bool on);

// Kontrol saklar Lampu UV
void actuator_set_uv(bool on);

// Kontrol saklar Blower (Kipas Utama)
void actuator_set_blower(bool on);

// Kontrol saklar Daya Kipas PWM
void actuator_set_fan_power(bool on);

// Kontrol kecepatan Kipas (Simulasi/Dummy kompatibilitas)
void actuator_set_fan_speed(uint8_t speed);

// Matikan seluruh aktuator dengan aman
void actuator_turn_all_off();

// Cek status aktuator
bool actuator_is_heater_on();
bool actuator_is_uv_on();
bool actuator_is_blower_on();
bool actuator_is_fan_power_on();
uint8_t actuator_get_fan_speed();

#endif // ACTUATOR_MANAGER_H
