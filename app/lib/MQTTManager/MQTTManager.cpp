/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - MQTT MANAGER IMPLEMENTATION
 * =========================================================================
 * File: MQTTManager.cpp
 * =========================================================================
 */

#include "MQTTManager.h"
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <Config.h>

static PubSubClient client;
static unsigned long lastReconnectAttempt = 0;

// Link ke callback eksternal di main.cpp
extern void handle_gateway_command(const char* commandId, const char* heaterState, 
                                    const char* uvState, const char* fanState, 
                                    const char* mode);

// Fungsi callback internal saat broker menerima pesan
static void mqtt_callback(char* topic, byte* payload, unsigned int length) {
    Serial.printf("[MQTT] Menerima pesan di topik: %s\n", topic);
    
    // Parsing JSON Payload menggunakan ArduinoJson
    StaticJsonDocument<256> doc;
    DeserializationError error = deserializeJson(doc, payload, length);
    
    if (error) {
        Serial.print("[MQTT] Gagal parse JSON payload: ");
        Serial.println(error.c_str());
        return;
    }
    
    const char* commandId = doc["command_id"] | "N/A";
    const char* heaterState = doc["actuators"]["heater"] | "OFF";
    const char* uvState = doc["actuators"]["uv_light"] | "OFF";
    const char* fanState = doc["actuators"]["fan"] | "OFF";
    const char* mode = doc["mode"] | "auto";
    
    // Panggil handler utama di main.cpp
    handle_gateway_command(commandId, heaterState, uvState, fanState, mode);
}

void mqtt_setup() {
    client.setServer(MQTT_BROKER, MQTT_PORT);
    client.setCallback(mqtt_callback);
}

static bool mqtt_reconnect() {
    Serial.println("[MQTT] Menghubungkan ke Broker Mosquitto...");
    
    // Generate Client ID acak
    String clientId = "ESP32Client-" + String(random(0xffff), HEX);
    
    // Topik LWT Status
    String statusTopic = "v1/devices/" + String(DEVICE_CODE) + "/status";
    
    // Payload LWT offline (Retained)
    StaticJsonDocument<128> lwtDoc;
    lwtDoc["device_code"] = DEVICE_CODE;
    lwtDoc["status"] = "offline";
    String lwtPayload;
    serializeJson(lwtDoc, lwtPayload);
    
    // Hubungkan ke broker dengan LWT (Will Retain = true, QoS = 1)
    if (client.connect(clientId.c_str(), 
                       MQTT_USER[0] ? MQTT_USER : NULL, 
                       MQTT_PASS[0] ? MQTT_PASS : NULL, 
                       statusTopic.c_str(), 1, true, lwtPayload.c_str())) {
                       
        Serial.println("[MQTT] Berhasil terhubung ke Broker.");
        
        // Kirim status Online ke Broker (Retain = true)
        StaticJsonDocument<128> onlineDoc;
        onlineDoc["device_code"] = DEVICE_CODE;
        onlineDoc["status"] = "online";
        String onlinePayload;
        serializeJson(onlineDoc, onlinePayload);
        client.publish(statusTopic.c_str(), onlinePayload.c_str(), true);
        
        // Subscribe ke topik perintah alat
        String commandTopic = "v1/devices/" + String(DEVICE_CODE) + "/commands";
        client.subscribe(commandTopic.c_str(), 1);
        Serial.printf("[MQTT] Berhasil men-subscribe topik: %s\n", commandTopic.c_str());
        
        return true;
    }
    
    Serial.printf("[MQTT] Gagal terhubung, status rc = %d\n", client.state());
    return false;
}

void mqtt_loop(WiFiClient& wifiClient) {
    static bool clientInitialized = false;
    if (!clientInitialized) {
        client.setClient(wifiClient);
        clientInitialized = true;
    }
    
    if (!client.connected()) {
        unsigned long currentMillis = millis();
        // Upayakan penyambungan ulang setiap 5 detik secara non-blocking
        if (currentMillis - lastReconnectAttempt >= 5000) {
            lastReconnectAttempt = currentMillis;
            if (mqtt_reconnect()) {
                lastReconnectAttempt = 0;
            }
        }
    } else {
        client.loop();
    }
}

void mqtt_publish_telemetry(float temp, float hum, float gas, 
                            float durTotal, float durFan, float durUV) {
    if (!client.connected()) return;
    
    // Bungkus data telemetri sesuai standard mqtt-specification.md
    StaticJsonDocument<512> doc;
    doc["device_code"] = DEVICE_CODE;
    doc["shoe_id"] = SHOE_ID;
    
    JsonObject telemetryObj = doc.createNestedObject("telemetry");
    telemetryObj["temperature"] = round(temp * 100.0) / 100.0;
    telemetryObj["humidity"] = round(hum * 100.0) / 100.0;
    telemetryObj["gas_level"] = round(gas * 100.0) / 100.0;
    
    JsonObject metricsObj = doc.createNestedObject("metrics");
    metricsObj["duration_usage"] = round(durTotal * 100.0) / 100.0;
    metricsObj["fan_usage_duration"] = round(durFan * 100.0) / 100.0;
    metricsObj["uv_usage_duration"] = round(durUV * 100.0) / 100.0;
    
    String payload;
    serializeJson(doc, payload);
    
    String topic = "v1/devices/" + String(DEVICE_CODE) + "/telemetry";
    
    if (client.publish(topic.c_str(), payload.c_str())) {
        Serial.printf("[MQTT] Berhasil kirim telemetri ke topik %s\n", topic.c_str());
    } else {
        Serial.println("[MQTT] Gagal mempublikasikan telemetri.");
    }
}

bool mqtt_is_connected() {
    return client.connected();
}
