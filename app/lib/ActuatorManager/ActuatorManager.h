/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - ACTUATOR MANAGER (RAMAH PEMULA)
 * =========================================================================
 * File: ActuatorManager.h
 * Deskripsi: Deklarasi fungsi sederhana untuk mengontrol Relay 4-Channel & PWM Fan.
 * =========================================================================
 */

#ifndef ACTUATORMANAGER_H
#define ACTUATORMANAGER_H

#include <Arduino.h>

// Inisialisasi pin relay dan PWM fan
void actuator_setup();

// Kontrol aktuator individu
void actuator_set_heater(bool on);
void actuator_set_uv(bool on);
void actuator_set_blower(bool on);
void actuator_set_fan_power(bool on);
void actuator_set_fan_speed(uint8_t speed); // 0 - 255

// Matikan semua beban secara aman
void actuator_turn_all_off();

// Status aktuator saat ini (getter status)
bool actuator_is_heater_on();
bool actuator_is_uv_on();
bool actuator_is_blower_on();
bool actuator_is_fan_power_on();
uint8_t actuator_get_fan_speed();

#endif // ACTUATORMANAGER_H
