const mqtt = require('mqtt');
require('dotenv').config();

const brokerUrl = process.env.MQTT_BROKER || 'mqtt://localhost';
const options = {
  port: parseInt(process.env.MQTT_PORT || '1883'),
  keepalive: parseInt(process.env.MQTT_KEEPALIVE || '60'),
  clientId: `smartshoe_gateway_${Math.random().toString(16).substring(2, 10)}`,
  clean: true,
  reconnectPeriod: 5000, // Mencoba menyambung kembali setiap 5 detik jika terputus
};

console.log(`[MQTT] Menghubungkan ke broker di: ${brokerUrl}:${options.port}...`);
const client = mqtt.connect(brokerUrl, options);

client.on('connect', () => {
  console.log('[MQTT] Berhasil terhubung ke Mosquitto Broker.');
});

client.on('error', (err) => {
  console.error('[MQTT] Koneksi gagal:', err);
});

client.on('close', () => {
  console.warn('[MQTT] Koneksi ke Broker terputus.');
});

module.exports = client;
