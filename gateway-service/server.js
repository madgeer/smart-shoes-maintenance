const express = require('express');
const http = require('http');
const cors = require('cors');
require('dotenv').config();

// Import Konfigurasi & Modul Kustom
const db = require('./src/config/db');
const mqttClient = require('./src/config/mqtt'); // Klien MQTT
const apiRoutes = require('./src/routes/api');
const { initSocket } = require('./src/websocket/socket');
const { initMqttListener } = require('./src/mqtt/listener');

const app = express();
const server = http.createServer(app);

const PORT = process.env.PORT || 3000;

// 1. Global Middlewares
// -------------------------------------------------------------------------
app.use(cors({ origin: '*' })); // Mengaktifkan CORS untuk seluruh request Dashboard/IoT Client
app.use(express.json()); // Parsing JSON request bodies
app.use(express.urlencoded({ extended: true }));

// 2. Health-Check REST API
// -------------------------------------------------------------------------
app.get('/', (req, res) => {
  return res.status(200).json({
    status: 'online',
    message: 'Welcome to Smart Shoes Maintenance Gateway Service API!',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Health check database
app.get('/health/db', async (req, res) => {
  try {
    const result = await db.query('SELECT NOW()');
    return res.status(200).json({
      status: 'healthy',
      database: 'connected',
      time: result.rows[0].now
    });
  } catch (error) {
    return res.status(500).json({
      status: 'unhealthy',
      database: 'disconnected',
      error: error.message
    });
  }
});

// 3. Mount Rute REST API
// -------------------------------------------------------------------------
// Semua endpoint berawalan '/api/v1' sesuai dengan dokumen 'docs/api-docs.md'
app.use('/api/v1', apiRoutes);

// 4. Inisialisasi Server WebSocket (Socket.io)
// -------------------------------------------------------------------------
initSocket(server);

// 5. Inisialisasi MQTT Telemetry Processor
// -------------------------------------------------------------------------
// Dijalankan begitu koneksi ke broker MQTT berhasil established
mqttClient.on('connect', () => {
  console.log('[SYSTEM] Mosquitto siap, memulai MQTT Telemetry Listener...');
  initMqttListener();
});

// 6. Jalankan Server HTTP
// -------------------------------------------------------------------------
server.listen(PORT, () => {
  console.log(`=================================================================`);
  console.log(`🚀 GATEWAY SERVICE BERHASIL DIJALANKAN DI PORT: ${PORT}`);
  console.log(`📡 WebSocket server aktif di: ws://localhost:${PORT}/realtime`);
  console.log(`📄 REST API Base URL aktif di: http://localhost:${PORT}/api/v1`);
  console.log(`=================================================================`);
});

// Penanganan anggun pemutusan server (Graceful Shutdown)
process.on('SIGTERM', () => {
  console.log('[SYSTEM] Menerima sinyal SIGTERM. Menutup server secara anggun...');
  server.close(() => {
    console.log('[SYSTEM] Server HTTP ditutup.');
    db.pool.end(() => {
      console.log('[SYSTEM] Pool koneksi PostgreSQL ditutup.');
      process.exit(0);
    });
  });
});
