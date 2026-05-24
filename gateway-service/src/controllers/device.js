const db = require('../config/db');

// 1. Mendaftarkan perangkat baru (ESP32) untuk User yang sedang login
const registerDevice = async (req, res) => {
  const { device_name, device_code } = req.body;
  const userId = req.user.id; // Diambil dari middleware JWT verifyToken

  if (!device_name || !device_code) {
    return res.status(400).json({
      success: false,
      message: 'Parameter device_name dan device_code wajib diisi.'
    });
  }

  try {
    // Cek apakah device_code sudah digunakan oleh orang lain
    const checkDevice = await db.query('SELECT id FROM devices WHERE device_code = $1', [device_code]);
    if (checkDevice.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Kode perangkat (device_code) sudah terdaftar di sistem.'
      });
    }

    // Masukkan data perangkat baru ke database
    const insertQuery = `
      INSERT INTO devices (user_id, device_name, device_code, status)
      VALUES ($1, $2, $3, 'active')
      RETURNING id, user_id, device_name, device_code, status, created_at
    `;
    const newDevice = await db.query(insertQuery, [userId, device_name, device_code]);

    return res.status(201).json({
      success: true,
      message: 'Device registered successfully',
      data: newDevice.rows[0]
    });
  } catch (error) {
    console.error('[DEVICE-CTRL] Error Register Device:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan sistem saat mendaftarkan perangkat.'
    });
  }
};

// 2. Mengambil daftar perangkat milik user yang sedang login
const getDevices = async (req, res) => {
  const userId = req.user.id;

  try {
    const devices = await db.query(
      'SELECT id, device_name, device_code, status, created_at FROM devices WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );

    return res.status(200).json({
      success: true,
      data: devices.rows
    });
  } catch (error) {
    console.error('[DEVICE-CTRL] Error Get Devices:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan sistem saat mengambil data perangkat.'
    });
  }
};

module.exports = {
  registerDevice,
  getDevices
};
