const db = require('../config/db');
const mqttClient = require('../config/mqtt');
const mlService = require('../services/ml');
const wsManager = require('../websocket/socket');
const { sendTelegramNotification } = require('../services/notification');

// Inisialisasi MQTT Listener
const initMqttListener = () => {
  // Melakukan subscribe ke data telemetri dan status koneksi dari perangkat apa pun
  const telemetryTopic = 'v1/devices/+/telemetry';
  const statusTopic = 'v1/devices/+/status';

  mqttClient.subscribe([telemetryTopic, statusTopic], (err) => {
    if (err) {
      console.error(`[MQTT-LISTENER] Gagal men-subscribe topik telemetri/status`, err);
    } else {
      console.log(`[MQTT-LISTENER] Berhasil men-subscribe topik telemetri dan status.`);
    }
  });

  // Menangani pesan MQTT yang masuk
  mqttClient.on('message', async (topic, message) => {
    console.log(`[MQTT-LISTENER] Menerima pesan pada topik: ${topic}`);

    try {
      // A. Menangani status online/offline perangkat keras (LWT / Startup)
      if (topic.endsWith('/status')) {
        const payload = JSON.parse(message.toString());
        const { device_code, status } = payload;

        if (!device_code || !status) {
          console.warn('[MQTT-LISTENER] Payload status tidak lengkap. Dilewati.');
          return;
        }

        const dbStatus = status === 'online' ? 'active' : 'inactive';
        await db.query(
          'UPDATE devices SET status = $1 WHERE device_code = $2',
          [dbStatus, device_code]
        );
        console.log(`[MQTT-LISTENER] Perangkat ${device_code} status diperbarui di DB menjadi: ${dbStatus}`);

        // Siarkan status koneksi ke WebSocket klien
        wsManager.broadcastToDevice(device_code, 'device:status', {
          device_code,
          status
        });
        return;
      }
      // 1. Parsing Payload Telemetri
      const payload = JSON.parse(message.toString());
      const { device_code, shoe_id, telemetry, metrics, timestamp } = payload;
      const shoeId = shoe_id;

      if (!device_code || !shoe_id || !telemetry) {
        console.warn('[MQTT-LISTENER] Payload tidak lengkap. Dilewati.');
        return;
      }

      const { temperature, humidity, gas_level, shoe_present } = telemetry;
      const duration_usage = metrics ? metrics.duration_usage || 0.0 : 0.0;
      const fan_usage_duration = metrics ? metrics.fan_usage_duration || 0.0 : 0.0;
      const uv_usage_duration = metrics ? metrics.uv_usage_duration || 0.0 : 0.0;

      // 2. Cari data perangkat dan status mode kontrol di database
      const deviceResult = await db.query(
        'SELECT id, user_id, device_name, control_mode, heater_state, uv_light_state, fan_state, active_shoe_id, status FROM devices WHERE device_code = $1',
        [device_code]
      );

      if (deviceResult.rows.length === 0) {
        console.warn(`[MQTT-LISTENER] Kode perangkat '${device_code}' tidak terdaftar di sistem. Dilewati.`);
        return;
      }

      const device = deviceResult.rows[0];
      const deviceId = device.id;
      const userId = device.user_id;
      const controlMode = device.control_mode || 'auto';

      // Auto-aktivasi status online perangkat jika sebelumnya tercatat inactive
      if (device.status !== 'active') {
        await db.query('UPDATE devices SET status = $1 WHERE id = $2', ['active', deviceId]);
        wsManager.broadcastToDevice(device_code, 'device:status', {
          device_code,
          status: 'online'
        });
        console.log(`[MQTT-LISTENER] Auto-aktivasi status online perangkat ${device_code} dari telemetri.`);
      }

      // Evaluasi kehadiran sepatu dari ultrasonik fisik jika tersedia
      const physicalShoePresent = (shoe_present !== undefined) ? shoe_present : ((device.active_shoe_id !== null && device.active_shoe_id !== 0) ? true : false);

      let activeShoeId = 0;
      if (physicalShoePresent) {
        activeShoeId = (device.active_shoe_id !== null && device.active_shoe_id !== 0) ? device.active_shoe_id : 1;
      } else {
        activeShoeId = 0;
      }
      const hasShoe = activeShoeId !== 0;

      // Sinkronisasi otomatis ke database jika ada perbedaan status fisik vs database
      if (shoe_present !== undefined) {
        const dbShoeIdVal = hasShoe ? activeShoeId : null;
        if (device.active_shoe_id !== dbShoeIdVal) {
          await db.query(
            'UPDATE devices SET active_shoe_id = $1 WHERE id = $2',
            [dbShoeIdVal, deviceId]
          );
          console.log(`[MQTT-LISTENER] Sinkronisasi otomatis database active_shoe_id ke: ${dbShoeIdVal}`);
        }
      }

      // 3. Simpan data sensor ke tabel `sensor_logs`
      const dbShoeId = hasShoe ? activeShoeId : null;
      const insertLogQuery = `
        INSERT INTO sensor_logs (shoe_id, device_id, temperature, humidity, gas_level, duration_usage, fan_usage_duration, uv_usage_duration)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id, created_at
      `;
      const newLog = await db.query(insertLogQuery, [
        dbShoeId,
        deviceId,
        temperature,
        humidity,
        gas_level,
        duration_usage,
        fan_usage_duration,
        uv_usage_duration
      ]);

      const logId = newLog.rows[0].id;
      const logTimestamp = newLog.rows[0].created_at;

      console.log(`[MQTT-LISTENER] Sukses menyimpan sensor_logs. Log ID: ${logId}`);

      // 4. Siarkan data sensor mentah ke WebSocket secara realtime
      wsManager.broadcastToDevice(device_code, 'sensor:update', {
        device_code,
        shoe_id: activeShoeId,
        data: {
          temperature,
          humidity,
          gas_level,
          timestamp: logTimestamp
        }
      });

      // 5. Integrasi Paralel Inferensi Model ML Service
      let drynessPred = { label: -1, kategori: 'Boks Kosong', gas_mq135_normalisasi: 0.0, kelembapan_normalisasi: 0.0 };
      let dryingPred = { sisa_waktu_menit: 0.0, status: 'Boks Kosong (Sensor tidak aktif)' };

      if (hasShoe) {
        drynessPred = await mlService.predictDryness(gas_level, humidity, temperature);

        const oldestLogResult = await db.query(
          `SELECT humidity FROM sensor_logs 
           WHERE shoe_id = $1 AND created_at >= NOW() - INTERVAL '12 hours' 
           ORDER BY created_at ASC LIMIT 1`,
          [activeShoeId]
        );
        const kelembapanAwal = oldestLogResult.rows.length > 0 ? oldestLogResult.rows[0].humidity : humidity;

        const shoeResult = await db.query('SELECT shoe_material FROM shoes WHERE id = $1', [activeShoeId]);
        const materialName = shoeResult.rows.length > 0 ? shoeResult.rows[0].shoe_material : 'Kanvas';

        const materialMap = { 'Kanvas': 1, 'Kulit': 2, 'Mesh': 3 };
        const jenisBahan = materialMap[materialName] || 1;

        dryingPred = await mlService.predictDryingTime(
          kelembapanAwal,
          humidity,
          temperature,
          jenisBahan,
          gas_level
        );
      }

      // 6. Simpan hasil prediksi gabungan ke database `predictions`
      const insertPredQuery = `
        INSERT INTO predictions (sensor_log_id, prediction_label, confidence_score, estimated_drying_time, drying_status)
        VALUES ($1, $2, NULL, $3, $4)
      `;
      await db.query(insertPredQuery, [
        logId,
        drynessPred.kategori,
        dryingPred.sisa_waktu_menit,
        dryingPred.status
      ]);

      console.log(`[MQTT-LISTENER] Sukses menyimpan hasil prediksi ML.`);

      // 7. Siarkan hasil analisa prediksi ML ke WebSocket secara realtime
      wsManager.broadcastToDevice(device_code, 'prediction:update', {
        device_code,
        shoe_id: activeShoeId,
        prediction: {
          dryness: {
            label: drynessPred.label,
            kategori: drynessPred.kategori,
            gas_mq135_normalisasi: drynessPred.gas_mq135_normalisasi,
            kelembapan_normalisasi: drynessPred.kelembapan_normalisasi
          },
          drying: {
            estimated_drying_time: dryingPred.sisa_waktu_menit,
            drying_status: dryingPred.status
          },
          timestamp: logTimestamp
        }
      });

      // 8. Kirim balik Perintah Aksi Aktuasi Fisik ke ESP32 via MQTT
      const commandTopic = `v1/devices/${device_code}/commands`;

      if (controlMode === 'manual') {
        const commandPayload = {
          command_id: `cmd_${Math.random().toString(16).substring(2, 10)}`,
          device_code: device_code,
          actuators: {
            heater: device.heater_state || 'OFF',
            uv_light: device.uv_light_state || 'OFF',
            fan: device.fan_state || 'OFF'
          },
          mode: 'manual',
          active_shoe_id: activeShoeId,
          timestamp: new Date().toISOString()
        };

        mqttClient.publish(commandTopic, JSON.stringify(commandPayload), { qos: 1 }, () => {
          console.log(`[MQTT-ACTUATOR] Mode MANUAL aktif untuk ${device_code}. Mengunci state:`, commandPayload.actuators);
          wsManager.broadcastToDevice(device_code, 'device:command', commandPayload);
        });
      } else {
        // B. JIKA MODE AUTO: Lakukan kalkulasi otomatis
        // - Heater, UV, dan Kipas dipaksa OFF jika boks kosong (tidak ada sepatu)
        let heaterState = 'OFF';
        let uvState = 'OFF';
        let fanState = 'OFF';

        if (hasShoe) {
          heaterState = humidity > 25.0 ? 'ON' : 'OFF';
          uvState = (drynessPred.kategori === 'Basah' || drynessPred.kategori === 'Lembap') ? 'ON' : 'OFF';
          fanState = (humidity > 25.0 || drynessPred.kategori === 'Basah' || drynessPred.kategori === 'Lembap') ? 'ON' : 'OFF';
        }

        // Simpan status aktuator otomatis yang baru terhitung ke database
        await db.query(
          `UPDATE devices SET heater_state = $1, uv_light_state = $2, fan_state = $3 WHERE device_code = $4`,
          [heaterState, uvState, fanState, device_code]
        );

        const commandPayload = {
          command_id: `cmd_${Math.random().toString(16).substring(2, 10)}`,
          device_code: device_code,
          actuators: {
            heater: heaterState,
            uv_light: uvState,
            fan: fanState
          },
          mode: 'auto',
          active_shoe_id: activeShoeId,
          timestamp: new Date().toISOString()
        };

        mqttClient.publish(commandTopic, JSON.stringify(commandPayload), { qos: 1 }, () => {
          console.log(`[MQTT-ACTUATOR] Mode AUTO aktif untuk ${device_code}. Mengirim hasil:`, commandPayload.actuators);
          wsManager.broadcastToDevice(device_code, 'device:command', commandPayload);
        });
      }
    } catch (err) {
      console.error('[MQTT-LISTENER] Gagal memproses telemetri MQTT:', err.message);
    }
  });
};

module.exports = {
  initMqttListener
};
