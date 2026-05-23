const db = require('../config/db');

// 1. Mengambil riwayat log sensor & hasil prediksi untuk sepatu tertentu
const getSensorLogs = async (req, res) => {
  const { shoe_id } = req.query;
  const limit = parseInt(req.query.limit || '50');

  if (!shoe_id) {
    return res.status(400).json({
      success: false,
      message: 'Parameter shoe_id wajib disertakan dalam query.'
    });
  }

  try {
    // Mengambil data sensor beserta hasil analis ML (Left Join)
    const logsQuery = `
      SELECT 
        s.id as log_id, s.shoe_id, s.device_id, s.temperature, s.humidity, s.gas_level,
        s.duration_usage, s.fan_usage_duration, s.uv_usage_duration, s.created_at,
        p.prediction_label as smell_label, p.confidence_score, p.estimated_drying_time, p.drying_status
      FROM sensor_logs s
      LEFT JOIN predictions p ON p.sensor_log_id = s.id
      WHERE s.shoe_id = $1
      ORDER BY s.created_at DESC
      LIMIT $2
    `;
    const result = await db.query(logsQuery, [shoe_id, limit]);

    // Kembalikan dalam urutan waktu menaik (chronological) agar gampang digambar di chart UI
    const sortedLogs = result.rows.reverse();

    return res.status(200).json({
      success: true,
      data: sortedLogs
    });
  } catch (error) {
    console.error('[LOG-CTRL] Error Get Sensor Logs:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan sistem saat mengambil histori sensor.'
    });
  }
};

// 2. Mencatat tindakan pemeliharaan manual baru pada perangkat
const addMaintenanceLog = async (req, res) => {
  const { device_id, component_name, issue, action_taken } = req.body;

  if (!device_id || !action_taken) {
    return res.status(400).json({
      success: false,
      message: 'Parameter device_id dan action_taken wajib diisi.'
    });
  }

  try {
    const insertQuery = `
      INSERT INTO maintenance_logs (device_id, component_name, issue, action_taken)
      VALUES ($1, $2, $3, $4)
      RETURNING id, device_id, component_name, issue, action_taken, maintenance_date
    `;
    const newLog = await db.query(insertQuery, [device_id, component_name, issue, action_taken]);

    return res.status(201).json({
      success: true,
      message: 'Maintenance log recorded successfully',
      data: newLog.rows[0]
    });
  } catch (error) {
    console.error('[LOG-CTRL] Error Add Maintenance Log:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan sistem saat mencatat pemeliharaan.'
    });
  }
};

// 3. Mengambil riwayat log pemeliharaan untuk perangkat tertentu
const getMaintenanceLogs = async (req, res) => {
  const { device_id } = req.query;

  if (!device_id) {
    return res.status(400).json({
      success: false,
      message: 'Parameter device_id wajib disertakan dalam query.'
    });
  }

  try {
    const result = await db.query(
      'SELECT id, device_id, component_name, issue, action_taken, maintenance_date FROM maintenance_logs WHERE device_id = $1 ORDER BY maintenance_date DESC',
      [device_id]
    );

    return res.status(200).json({
      success: true,
      data: result.rows
    });
  } catch (error) {
    console.error('[LOG-CTRL] Error Get Maintenance Logs:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan sistem saat mengambil histori pemeliharaan.'
    });
  }
};

// 4. Mengambil daftar notifikasi milik pengguna
const getNotifications = async (req, res) => {
  const userId = req.user.id;

  try {
    const result = await db.query(
      'SELECT id, title, message, notification_type, is_read, created_at FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 30',
      [userId]
    );

    return res.status(200).json({
      success: true,
      data: result.rows
    });
  } catch (error) {
    console.error('[LOG-CTRL] Error Get Notifications:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan sistem saat mengambil notifikasi.'
    });
  }
};

module.exports = {
  getSensorLogs,
  addMaintenanceLog,
  getMaintenanceLogs,
  getNotifications
};
