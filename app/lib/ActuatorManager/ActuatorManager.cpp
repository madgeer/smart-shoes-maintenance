/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - ACTUATOR MANAGER IMPLEMENTATION
 * =========================================================================
 * File: ActuatorManager.cpp
 * =========================================================================
 */

#include "ActuatorManager.h"
#include <Config.h>

static bool heaterState = false;
static bool uvState = false;
static bool fanPowerState = false;
static uint8_t fanSpeedSetting = 0;

// Fungsi pembantu lokal untuk menyalakan/mematikan relay secara fisik
static void write_relay(uint8_t pin, bool active) {
    if (RELAY_ACTIVE_STATE == LOW) {
        // Active-Low: Beri LOW untuk MENYALAKAN, HIGH untuk MEMATIKAN
        digitalWrite(pin, active ? LOW : HIGH);
    } else {
        // Active-High: Beri HIGH untuk MENYALAKAN, LOW untuk MEMATIKAN
        digitalWrite(pin, active ? HIGH : LOW);
    }
}

// Fungsi keselamatan internal agar plate heater tidak meleleh (overheating)
static void apply_safety_interlock() {
    if (heaterState) {
        bool updated = false;

        // Jika Heater menyala, Kipas/Blower sirkulasi udara WAJIB ikut menyala!
        if (!fanPowerState) {
            fanPowerState = true;
            write_relay(RELAY_FAN_POWER_PIN, true);
            updated = true;
        }

        if (fanSpeedSetting < NORMAL_FAN_SPEED) {
            fanSpeedSetting = NORMAL_FAN_SPEED;
            updated = true;
        }

        if (updated) {
            Serial.println("[ACTUATOR] 🛡️ SAFETY INTERLOCK: Heater Aktif! Kipas otomatis dihidupkan untuk sirkulasi panas.");
        }
    }
}

void actuator_setup() {
    // Atur pin-pin Relay sebagai output digital
    pinMode(RELAY_HEATER_PIN, OUTPUT);
    pinMode(RELAY_UV_PIN, OUTPUT);
    pinMode(RELAY_FAN_POWER_PIN, OUTPUT);

    // Matikan semua beban saat awal dinyalakan
    actuator_turn_all_off();

    Serial.println("[ACTUATOR] Seluruh komponen aktuator siap dikontrol.");
}

void actuator_set_heater(bool on) {
    heaterState = on;
    write_relay(RELAY_HEATER_PIN, heaterState);
    Serial.printf("[ACTUATOR] Heater diatur ke: %s\n", heaterState ? "ON" : "OFF");

    // Lakukan pengecekan keselamatan
    apply_safety_interlock();
}

void actuator_set_uv(bool on) {
    uvState = on;
    write_relay(RELAY_UV_PIN, uvState);
    Serial.printf("[ACTUATOR] Lampu UV diatur ke: %s\n", uvState ? "ON" : "OFF");
}

void actuator_set_blower(bool on) {
    // Karena pin blower fisik disatukan dengan Kipas utama di GPIO 27 pada wiring.md:
    actuator_set_fan_power(on);
}

void actuator_set_fan_power(bool on) {
    // PROTEKSI: Jangan matikan kipas pendingin jika heater masih menyala!
    if (heaterState && !on) {
        Serial.println("[ACTUATOR] WARNING: Keamanan! Daya Kipas harus tetap ON karena Heater sedang menyala.");
        return;
    }

    fanPowerState = on;
    write_relay(RELAY_FAN_POWER_PIN, fanPowerState);
    Serial.printf("[ACTUATOR] Kipas Blower diatur ke: %s\n", fanPowerState ? "ON" : "OFF");
}

void actuator_set_fan_speed(uint8_t speed) {
    // PROTEKSI: Kipas tidak boleh diam jika heater aktif!
    if (heaterState && speed < MIN_FAN_SPEED) {
        Serial.printf("[ACTUATOR] WARNING: Keamanan! Kipas dipaksa kecepatan %d karena Heater aktif.\n", MIN_FAN_SPEED);
        fanSpeedSetting = MIN_FAN_SPEED;
    } else {
        fanSpeedSetting = speed;
    }
    Serial.printf("[ACTUATOR] Kecepatan Kipas diatur ke: %d/255\n", fanSpeedSetting);
}

void actuator_turn_all_off() {
    heaterState = false;
    uvState = false;
    fanPowerState = false;
    fanSpeedSetting = 0;

    write_relay(RELAY_HEATER_PIN, false);
    write_relay(RELAY_UV_PIN, false);
    write_relay(RELAY_FAN_POWER_PIN, false);

    Serial.println("[ACTUATOR] Seluruh aktuator dimatikan dengan aman.");
}

bool actuator_is_heater_on() { return heaterState; }
bool actuator_is_uv_on() { return uvState; }
bool actuator_is_blower_on() { return fanPowerState; } // Disamakan dengan fanPowerState
bool actuator_is_fan_power_on() { return fanPowerState; }
uint8_t actuator_get_fan_speed() { return fanSpeedSetting; }
