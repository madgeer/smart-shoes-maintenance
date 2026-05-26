const db = require('../config/db');
const mqttClient = require('../config/mqtt');
const wsManager = require('../websocket/socket');

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
      'SELECT id, device_name, device_code, status, control_mode, heater_state, uv_light_state, fan_state, created_at FROM devices WHERE user_id = $1 ORDER BY created_at DESC',
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

// 3. Mengirim perintah kendali manual aktuator ke perangkat via MQTT
const sendDeviceCommand = async (req, res) => {
  const { device_code } = req.params;
  const { mode, actuators } = req.body;

  if (!device_code || !actuators) {
    return res.status(400).json({
      success: false,
      message: 'Parameter device_code dan actuators wajib diisi.'
    });
  }

  try {
    // Validasi apakah perangkat ini terdaftar di DB
    const checkDevice = await db.query('SELECT id FROM devices WHERE device_code = $1', [device_code]);
    if (checkDevice.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: `Perangkat dengan kode '${device_code}' tidak terdaftar.`
      });
    }

    const activeMode = mode || 'manual';
    const hState = actuators.heater || 'OFF';
    const uvState = actuators.uv_light || 'OFF';
    const fState = actuators.fan || 'OFF';

    // Simpan status kontrol baru ke database PostgreSQL
    await db.query(
      `UPDATE devices 
       SET control_mode = $1, heater_state = $2, uv_light_state = $3, fan_state = $4 
       WHERE device_code = $5`,
      [activeMode, hState, uvState, fState, device_code]
    );
    console.log(`[DEVICE-CTRL] Status kontrol disimpan ke DB untuk ${device_code}: mode=${activeMode}, heater=${hState}, uv=${uvState}, fan=${fState}`);

    const commandTopic = `v1/devices/${device_code}/commands`;
    const commandPayload = {
      command_id: `cmd_${Math.random().toString(16).substring(2, 10)}`,
      device_code: device_code,
      actuators: {
        heater: hState,
        uv_light: uvState,
        fan: fState
      },
      mode: activeMode,
      timestamp: new Date().toISOString()
    };

    // Publish komando ke broker MQTT Mosquitto
    mqttClient.publish(commandTopic, JSON.stringify(commandPayload), { qos: 1 }, (err) => {
      if (err) {
        console.error(`[DEVICE-CTRL] Gagal mempublikasikan komando ke ${commandTopic}:`, err.message);
      } else {
        console.log(`[DEVICE-CTRL] Berhasil mempublikasikan komando manual ke ${commandTopic}:`, commandPayload.actuators);
      }
    });

    // Siarkan juga ke semua koneksi WebSocket room agar UI langsung ter-update secara real-time
    wsManager.broadcastToDevice(device_code, 'device:command', commandPayload);

    return res.status(200).json({
      success: true,
      message: 'Command published successfully',
      data: commandPayload
    });
  } catch (error) {
    console.error('[DEVICE-CTRL] Error Send Device Command:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan sistem saat mengirim perintah.'
    });
  }
};

module.exports = {
  registerDevice,
  getDevices,
  sendDeviceCommand
};
