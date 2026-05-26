const express = require('express');
const router = express.Router();

// Import Middleware
const { verifyToken } = require('../middleware/auth');

// Import Controllers
const authController = require('../controllers/auth');
const deviceController = require('../controllers/device');
const shoeController = require('../controllers/shoe');
const logController = require('../controllers/log');

// =========================================================================
// 1. RUTE PUBLIK (TIDAK BUTUH JWT)
// =========================================================================
router.post('/auth/register', authController.register);
router.post('/auth/login', authController.login);

// =========================================================================
// 2. RUTE TERPROTEKSI (WAJIB MEMILIKI JWT DI HEADER AUTHORIZATION)
// =========================================================================

// --- A. Manajemen Perangkat (Devices) ---
router.post('/devices', verifyToken, deviceController.registerDevice);
router.get('/devices', verifyToken, deviceController.getDevices);
router.post('/devices/:device_code/commands', verifyToken, deviceController.sendDeviceCommand);

// --- B. Manajemen Sepatu (Shoes) ---
router.post('/shoes', verifyToken, shoeController.addShoe);
router.get('/shoes', verifyToken, shoeController.getShoes);

// --- C. Telemetri Sensor & Riwayat ---
router.get('/sensor-logs', verifyToken, logController.getSensorLogs);

// --- D. Pemeliharaan Alat (Maintenance) ---
router.post('/maintenance-logs', verifyToken, logController.addMaintenanceLog);
router.get('/maintenance-logs', verifyToken, logController.getMaintenanceLogs);

// --- E. Notifikasi Pengguna ---
router.get('/notifications', verifyToken, logController.getNotifications);

module.exports = router;
