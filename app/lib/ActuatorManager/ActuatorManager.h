

#ifndef ACTUATOR_MANAGER_H
#define ACTUATOR_MANAGER_H

#include <Arduino.h>

// Inisialisasi pin relay
void actuator_setup();

//mengontrol saklar heater
void actuator_set_heater(bool on);

//mengontrol saklar uv
void actuator_set_uv(bool on);

// kontrol saklar blower
void actuator_set_blower(bool on);

// kontrol saklar daya Kipas pwm
void actuator_set_fan_power(bool on);

// kontrol kecepatan Kipas (Simulasi/dummy kompatibilitas)
void actuator_set_fan_speed(uint8_t speed);

// mmatikan seluruh aktuator dengan aman
void actuator_turn_all_off();

// cek status aktuator
bool actuator_is_heater_on();
bool actuator_is_uv_on();
bool actuator_is_blower_on();
bool actuator_is_fan_power_on();
uint8_t actuator_get_fan_speed();

#endif 
