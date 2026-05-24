/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - ACTUATOR MANAGER (RAMAH PEMULA)
 * =========================================================================
 * File: ActuatorManager.cpp
 * Deskripsi: Pustaka kontrol aktuator menggunakan fungsi dan variabel global.
 * =========================================================================
 */

#include "ActuatorManager.h"
#include <Config.h>

// Variabel status global (gaya pemula)
static bool heaterState = false;
static bool uvState = false;
static bool blowerState = false;
static bool fanPowerState = false;
static uint8_t fanSpeed = 0;

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

// Fungsi pengaman internal agar Plate Heater tidak meleleh (overheating)
static void apply_safety_interlock() {
    if (heaterState) {
        bool updated = false;

        // Jika Heater menyala, Blower dan Kipas PWM WAJIB ikut menyala!
        if (!blowerState) {
            blowerState = true;
            write_relay(RELAY_BLOWER_PIN, true);
            updated = true;
        }

        if (!fanPowerState) {
            fanPowerState = true;
            write_relay(RELAY_FAN_POWER_PIN, true);
            updated = true;
        }

        if (fanSpeed < 180) {
            fanSpeed = 180; // Paksa kipas berputar minimal pada level sedang-tinggi
            ledcWrite(PWM_FAN_CHANNEL, fanSpeed);
            updated = true;
        }

        if (updated) {
            Serial.println("[ACTUATOR] 🛡️ SAFETY INTERLOCK: Heater Aktif! Blower & Kipas PWM otomatis dinyalakan untuk sirkulasi panas.");
        }
    }
}

void actuator_setup() {
    // 1. Atur ke-4 pin Relay sebagai output digital
    pinMode(RELAY_HEATER_PIN, OUTPUT);
    pinMode(RELAY_UV_PIN, OUTPUT);
    pinMode(RELAY_BLOWER_PIN, OUTPUT);
    pinMode(RELAY_FAN_POWER_PIN, OUTPUT);

    // 2. Matikan semua beban saat awal dinyalakan
    actuator_turn_all_off();

    // 3. Setup PWM Fan menggunakan module LEDC ESP32
    Serial.printf("[ACTUATOR] Mengatur pin PWM Fan ke GPIO %d (Ch: %d)...\n", 
                  PWM_FAN_SPEED_PIN, PWM_FAN_CHANNEL);
    ledcSetup(PWM_FAN_CHANNEL, PWM_FAN_FREQ, PWM_FAN_RES);
    ledcAttachPin(PWM_FAN_SPEED_PIN, PWM_FAN_CHANNEL);
    ledcWrite(PWM_FAN_CHANNEL, 0); // Kecepatan awal 0

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
    // PROTEKSI: Jangan matikan blower utama jika heater pemanas masih menyala!
    if (heaterState && !on) {
        Serial.println("[ACTUATOR] WARNING: Keamanan! Motor Blower harus tetap ON karena Heater sedang menyala.");
        return;
    }

    blowerState = on;
    write_relay(RELAY_BLOWER_PIN, blowerState);
    Serial.printf("[ACTUATOR] Motor Blower diatur ke: %s\n", blowerState ? "ON" : "OFF");
}

void actuator_set_fan_power(bool on) {
    // PROTEKSI: Jangan matikan daya kipas PWM jika heater pemanas masih menyala!
    if (heaterState && !on) {
        Serial.println("[ACTUATOR] WARNING: Keamanan! Daya Kipas PWM harus tetap ON karena Heater sedang menyala.");
        return;
    }

    fanPowerState = on;
    write_relay(RELAY_FAN_POWER_PIN, fanPowerState);
    Serial.printf("[ACTUATOR] Daya Kipas PWM diatur ke: %s\n", fanPowerState ? "ON" : "OFF");
}

void actuator_set_fan_speed(uint8_t speed) {
    // PROTEKSI: Kipas PWM tidak boleh diam/terlalu lambat jika heater menyala!
    if (heaterState && speed < 120) {
        Serial.printf("[ACTUATOR] WARNING: Keamanan! Kipas PWM dipaksa kecepatan 120 (dari permintaan %d) karena Heater aktif.\n", speed);
        fanSpeed = 120;
    } else {
        fanSpeed = speed;
    }

    ledcWrite(PWM_FAN_CHANNEL, fanSpeed);
    Serial.printf("[ACTUATOR] Kecepatan Kipas PWM diatur ke: %d/255\n", fanSpeed);
}

void actuator_turn_all_off() {
    heaterState = false;
    uvState = false;
    blowerState = false;
    fanPowerState = false;
    fanSpeed = 0;

    write_relay(RELAY_HEATER_PIN, false);
    write_relay(RELAY_UV_PIN, false);
    write_relay(RELAY_BLOWER_PIN, false);
    write_relay(RELAY_FAN_POWER_PIN, false);
    ledcWrite(PWM_FAN_CHANNEL, 0);

    Serial.println("[ACTUATOR] Seluruh aktuator dimatikan dengan aman.");
}

bool actuator_is_heater_on() { return heaterState; }
bool actuator_is_uv_on() { return uvState; }
bool actuator_is_blower_on() { return blowerState; }
bool actuator_is_fan_power_on() { return fanPowerState; }
uint8_t actuator_get_fan_speed() { return fanSpeed; }
