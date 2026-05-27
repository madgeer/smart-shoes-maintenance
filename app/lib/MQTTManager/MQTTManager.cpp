/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - MQTT MANAGER (RAMAH PEMULA)
 * =========================================================================
 * File: MQTTManager.cpp
 * Deskripsi: Pustaka penanganan komunikasi data MQTT dengan serialisasi
 *            JSON telemetri & deserialisasi perintah gateway.
 * =========================================================================
 */

#include "MQTTManager.h"
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <Config.h>
#include <time.h>

// Deklarasi fungsi di main.cpp secara eksternal (menghindari pointer callback rumit)
extern void handle_gateway_command(const char* commandId, const char* heaterState, 
                                    const char* uvState, const char* fanState, 
                                    const char* mode);

// Objek MQTT & variabel konfigurasi
static PubSubClient mqttClient;
static String clientId;
static String statusTopic;
static String telemetryTopic;
static String commandTopic;

static bool isClientConfigured = false;
static unsigned long lastMqttReconnectAttempt = 0;
const unsigned long mqttReconnectInterval = 5000;

// Fungsi pembantu pembacaan waktu NTP UTC ISO 8601
static String get_iso_timestamp() {
    time_t now;
    time(&now);
    struct tm timeinfo;
    if (!gmtime_r(&now, &timeinfo) || now < 100000) {
        return "2026-05-23T08:00:00.000Z"; // Fallback tanggal awal jika NTP belum selesai sinkronisasi
    }
    char buf[30];
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
    return String(buf);
}

// Callback internal saat broker mengirimkan data/command
static void mqtt_message_callback(char* topic, byte* payload, unsigned int length) {
    Serial.printf("[MQTT] Ada pesan masuk di topik: %s\n", topic);

    if (String(topic) == commandTopic) {
        // Gunakan ArduinoJson v6 untuk mem-parsing data perintah JSON
        StaticJsonDocument<384> doc;
        DeserializationError error = deserializeJson(doc, payload, length);

        if (error) {
            Serial.printf("[MQTT] ERROR: Gagal mem-parsing perintah JSON: %s\n", error.c_str());
            return;
        }

        // Ambil elemen kunci
        const char* commandId = doc["command_id"] | "N/A";
        const char* mode = doc["mode"] | "auto";
        
        const char* heaterState = "OFF";
        const char* uvState = "OFF";
        const char* fanState = "OFF";

        if (doc.containsKey("actuators")) {
            JsonObject actuators = doc["actuators"];
            heaterState = actuators["heater"] | "OFF";
            uvState = actuators["uv_light"] | "OFF";
            fanState = actuators["fan"] | "OFF";
        }

        // Panggil fungsi kontrol utama di main.cpp
        handle_gateway_command(commandId, heaterState, uvState, fanState, mode);
    }
}

static void connect_mqtt() {
    Serial.printf("[MQTT] Menghubungkan ke Broker: %s:%d ...\n", MQTT_BROKER, MQTT_PORT);

    // 1. Buat LWT (Last Will and Testament) Offline Payload
    StaticJsonDocument<128> lwtDoc;
    lwtDoc["device_code"] = DEVICE_CODE;
    lwtDoc["status"] = "offline";
    lwtDoc["timestamp"] = get_iso_timestamp();
    
    String lwtPayload;
    serializeJson(lwtDoc, lwtPayload);

    // 2. Hubungkan ke Broker Mosquitto dengan LWT
    if (mqttClient.connect(clientId.c_str(), statusTopic.c_str(), 1, true, lwtPayload.c_str())) {
        Serial.println("[MQTT] Terhubung ke Broker Mosquitto!");

        // A. Publikasikan Status Online (Retained = true agar dashboard tahu status terkini)
        mqtt_publish_status("online");

        // B. Daftarkan diri untuk menerima perintah (Subscribe)
        mqttClient.subscribe(commandTopic.c_str(), 1);
        Serial.printf("[MQTT] Berhasil berlangganan topik: %s\n", commandTopic.c_str());
    } else {
        Serial.printf("[MQTT] Gagal menghubungkan! Kode eror=%d\n", mqttClient.state());
    }
}

void mqtt_setup() {
    // 1. Konstruksi topik secara dinamis berbasis DEVICE_CODE
    statusTopic = "v1/devices/" + String(DEVICE_CODE) + "/status";
    telemetryTopic = "v1/devices/" + String(DEVICE_CODE) + "/telemetry";
    commandTopic = "v1/devices/" + String(DEVICE_CODE) + "/commands";

    // 2. Buat Client ID unik bebas konflik
    String mac = WiFi.macAddress();
    mac.replace(":", "");
    clientId = "ESP32_SHOE_" + mac;

    Serial.printf("[MQTT] Konfigurasi siap. Client ID: %s\n", clientId.c_str());
}

void mqtt_loop(WiFiClient& wifiClient) {
    // Konfigurasi client pertama kali dijalankan
    if (!isClientConfigured) {
        mqttClient.setClient(wifiClient);
        mqttClient.setServer(MQTT_BROKER, MQTT_PORT);
        mqttClient.setCallback(mqtt_message_callback);
        isClientConfigured = true;
    }

    if (!mqttClient.connected()) {
        unsigned long currentMillis = millis();
        if (currentMillis - lastMqttReconnectAttempt >= mqttReconnectInterval) {
            lastMqttReconnectAttempt = currentMillis;
            Serial.println("[MQTT] Koneksi terputus! Mencoba menghubungi ulang...");
            connect_mqtt();
        }
    } else {
        mqttClient.loop();
    }
}

bool mqtt_is_connected() {
    return mqttClient.connected();
}

bool mqtt_publish_status(const char* status) {
    if (!mqtt_is_connected()) return false;

    StaticJsonDocument<128> doc;
    doc["device_code"] = DEVICE_CODE;
    doc["status"] = status;
    doc["timestamp"] = get_iso_timestamp();

    String payload;
    serializeJson(doc, payload);

    return mqttClient.publish(statusTopic.c_str(), payload.c_str(), true); // Retained = true
}

bool mqtt_publish_telemetry(float temp, float hum, float gas, 
                            float duration, float fanDur, float uvDur) {
    if (!mqtt_is_connected()) return false;

    // Susun payload Telemetri
    StaticJsonDocument<256> doc;
    doc["device_code"] = DEVICE_CODE;
    doc["shoe_id"] = SHOE_ID;

    JsonObject telemetry = doc.createNestedObject("telemetry");
    telemetry["temperature"] = serialized(String(temp, 2));
    telemetry["humidity"] = serialized(String(hum, 2));
    telemetry["gas_level"] = serialized(String(gas, 2));

    JsonObject metrics = doc.createNestedObject("metrics");
    metrics["duration_usage"] = serialized(String(duration, 2));
    metrics["fan_usage_duration"] = serialized(String(fanDur, 2));
    metrics["uv_usage_duration"] = serialized(String(uvDur, 2));

    doc["timestamp"] = get_iso_timestamp();

    String payload;
    serializeJson(doc, payload);

    bool success = mqttClient.publish(telemetryTopic.c_str(), payload.c_str(), false);
    if (success) {
        Serial.println("[MQTT] Sukses mempublikasikan telemetri.");
    } else {
        Serial.println("[MQTT] Gagal mengirim telemetri!");
    }
    return success;
}
