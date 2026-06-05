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

      const { temperature, humidity, gas_level } = telemetry;
      const duration_usage = metrics ? metrics.duration_usage || 0.0 : 0.0;
      const fan_usage_duration = metrics ? metrics.fan_usage_duration || 0.0 : 0.0;
      const uv_usage_duration = metrics ? metrics.uv_usage_duration || 0.0 : 0.0;

      // 2. Cari data perangkat dan status mode kontrol di database
      const deviceResult = await db.query(
        'SELECT id, user_id, device_name, control_mode, heater_state, uv_light_state, fan_state FROM devices WHERE device_code = $1',
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

      // 3. Simpan data sensor ke tabel `sensor_logs`
      const insertLogQuery = `
        INSERT INTO sensor_logs (shoe_id, device_id, temperature, humidity, gas_level, duration_usage, fan_usage_duration, uv_usage_duration)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id, created_at
      `;
      const newLog = await db.query(insertLogQuery, [
        shoe_id,
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
        shoe_id,
        data: {
          temperature,
          humidity,
          gas_level,
          timestamp: logTimestamp
        }
      });

      // 5. Integrasi Paralel Inferensi Model ML Service
      
      // A. Model 1: Prediksi Klasifikasi Bau (K-Means)
      const smellPred = await mlService.predictSmell(gas_level, humidity);
      
      // B. Model 2: Prediksi Estimasi Waktu Pengeringan (Regression)
      // B.1 Cari kelembapan awal dalam sesi 12 jam terakhir
      const oldestLogResult = await db.query(
        `SELECT humidity FROM sensor_logs 
         WHERE shoe_id = $1 AND created_at >= NOW() - INTERVAL '12 hours' 
         ORDER BY created_at ASC LIMIT 1`,
        [shoe_id]
      );
      const kelembapanAwal = oldestLogResult.rows.length > 0 ? oldestLogResult.rows[0].humidity : humidity;

      // B.2 Cari bahan/material sepatu
      const shoeResult = await db.query('SELECT shoe_material FROM shoes WHERE id = $1', [shoe_id]);
      const materialName = shoeResult.rows.length > 0 ? shoeResult.rows[0].shoe_material : 'Kanvas';
      
      // B.3 Konversi bahan tekstil ke nilai integer input ML (1: Kanvas, 2: Kulit, 3: Mesh)
      const materialMap = { 'Kanvas': 1, 'Kulit': 2, 'Mesh': 3 };
      const jenisBahan = materialMap[materialName] || 1;

      // B.4 Tembak API model regresi ML
      const dryingPred = await mlService.predictDryingTime(
        kelembapanAwal,
        humidity,
        temperature,
        jenisBahan,
        gas_level
      );

      // 6. Simpan hasil prediksi gabungan ke database `predictions`
      const insertPredQuery = `
        INSERT INTO predictions (sensor_log_id, prediction_label, confidence_score, estimated_drying_time, drying_status)
        VALUES ($1, $2, NULL, $3, $4)
      `;
      await db.query(insertPredQuery, [
        logId,
        smellPred.kategori,
        dryingPred.sisa_waktu_menit,
        dryingPred.status
      ]);

      console.log(`[MQTT-LISTENER] Sukses menyimpan hasil prediksi ML.`);

      // 7. Siarkan hasil analisa prediksi ML ke WebSocket secara realtime
      wsManager.broadcastToDevice(device_code, 'prediction:update', {
        device_code,
        shoe_id,
        prediction: {
          smell: {
            label: smellPred.label,
            kategori: smellPred.kategori,
            gas_mq135_normalisasi: smellPred.gas_mq135_normalisasi,
            kelembapan_normalisasi: smellPred.kelembapan_normalisasi
          },
          drying: {
            estimated_drying_time: dryingPred.sisa_waktu_menit,
            drying_status: dryingPred.status
          },
          timestamp: logTimestamp
        }
      });

      // 8. Logika Peringatan Bau Parah & Notifikasi Otomatis
      if (smellPred.kategori === 'Bau' || humidity > 75.0) {
        let alertTitle = 'Peringatan Kelembapan Tinggi!';
        let alertMsg = `Sepatu terdeteksi sangat lembap (${humidity.toFixed(1)}%). Direkomendasikan sterilisasi & pengeringan otomatis.`;
        let alertType = 'WARNING';

        if (smellPred.kategori === 'Bau') {
          alertTitle = 'Deteksi Bau Sepatu!';
          alertMsg = `Tingkat bau sepatu terdeteksi kurang sedap. Sistem menyalakan sterilisator lampu UV secara otomatis.`;
          alertType = 'DANGER';
        }

        // Simpan Alert Notifikasi ke database PostgreSQL
        const insertNotifQuery = `
          INSERT INTO notifications (user_id, title, message, notification_type)
          VALUES ($1, $2, $3, $4)
        `;
        await db.query(insertNotifQuery, [userId, alertTitle, alertMsg, alertType]);

        // Pancarkan Alert realtime via WebSocket ke client agar muncul Toast Notifikasi
        wsManager.sendAlertToUser(userId, 'notification:alert', {
          user_id: userId,
          notification_type: alertType,
          title: alertTitle,
          message: alertMsg,
          timestamp: logTimestamp
        });

        // Kirim Notifikasi ke Telegram Bot
        if (smellPred.kategori === 'Bau') {
          const tgMessage = `🚨 *DETEKSI BAU SEPATU!*\n📦 Shoe ID: *#${shoeId}*\n🔌 Device: *${device_code}*\n💨 MQ-135 Gas: *${gas_level.toFixed(1)} ppm* (Kondisi: *Bau*)\n💦 Kelembapan: *${humidity.toFixed(1)} %*\n\nSistem menyalakan Lampu UV Steril dan Blower secara otomatis untuk dekontaminasi bakteri.`;
          sendTelegramNotification(tgMessage);
        } else if (humidity > 75.0) {
          const tgMessage = `⚠️ *PERINGATAN KELEMBAPAN TINGGI!*\n📦 Shoe ID: *#${shoeId}*\n🔌 Device: *${device_code}*\n💦 Kelembapan: *${humidity.toFixed(1)} %* (Basah Sekali)\n🌡️ Suhu: *${temperature.toFixed(1)} °C*\n\nSepatu terdeteksi basah sekali. Sistem mengaktifkan Heater dan Blower otomatis untuk memulai pengeringan.`;
          sendTelegramNotification(tgMessage);
        }
      }

      // 9. Kirim balik Perintah Aksi Aktuasi Fisik ke ESP32 via MQTT
      // Sesuai mqtt-specification.md: Gateway mengirim instruksi ke topik 'v1/devices/{device_code}/commands'
      const commandTopic = `v1/devices/${device_code}/commands`;

      if (controlMode === 'manual') {
        // A. JIKA MODE MANUAL: Kirim ulang perintah manual stabil yang tersimpan di DB
        const commandPayload = {
          command_id: `cmd_${Math.random().toString(16).substring(2, 10)}`,
          device_code: device_code,
          actuators: {
            heater: device.heater_state || 'OFF',
            uv_light: device.uv_light_state || 'OFF',
            fan: device.fan_state || 'OFF'
          },
          mode: 'manual',
          timestamp: new Date().toISOString()
        };

        mqttClient.publish(commandTopic, JSON.stringify(commandPayload), { qos: 1 }, () => {
          console.log(`[MQTT-ACTUATOR] Mode MANUAL aktif untuk ${device_code}. Mengunci state:`, commandPayload.actuators);
          // Siarkan ke WebSocket agar UI stabil pada mode manual
          wsManager.broadcastToDevice(device_code, 'device:command', commandPayload);
        });
      } else {
        // B. JIKA MODE AUTO: Lakukan kalkulasi otomatis
        // - Heater aktif jika kelembapan belum optimal kering (>15%)
        // - UV aktif jika bau terdeteksi 'Bau' (mencegah bakteri)
        // - Kipas aktif jika salah satu heater atau UV menyala
        const heaterState = humidity > 15.0 ? 'ON' : 'OFF';
        const uvState = smellPred.kategori === 'Bau' ? 'ON' : 'OFF';
        const fanState = (humidity > 15.0 || smellPred.kategori === 'Bau') ? 'ON' : 'OFF';

        // Deteksi transisi proses pengeringan selesai (Heater dari ON berubah menjadi OFF)
        if (device.heater_state === 'ON' && heaterState === 'OFF') {
          const finishedTitle = 'Proses Pengeringan Selesai!';
          const finishedMsg = `Sepatu dengan ID #${shoeId} telah kering secara optimal (${humidity.toFixed(1)}%). Pemanas otomatis dinonaktifkan.`;

          // Simpan notifikasi ke database PostgreSQL
          await db.query(
            `INSERT INTO notifications (user_id, title, message, notification_type) VALUES ($1, $2, $3, 'INFO')`,
            [userId, finishedTitle, finishedMsg]
          );

          // Pancarkan via WebSocket
          wsManager.sendAlertToUser(userId, 'notification:alert', {
            user_id: userId,
            notification_type: 'INFO',
            title: finishedTitle,
            message: finishedMsg,
            timestamp: logTimestamp
          });

          // Kirim Notifikasi via Telegram Bot
          const tgMsg = `✅ *PROSES PENGERINGAN SELESAI!*\n📦 Shoe ID: *#${shoeId}*\n🔌 Device: *${device_code}*\n💦 Kelembapan Akhir: *${humidity.toFixed(1)} %* (Optimal & Kering)\n🌡️ Suhu Akhir: *${temperature.toFixed(1)} °C*\n\nSepatu telah kering sempurna dan siap digunakan kembali. Pemanas otomatis dimatikan oleh sistem.`;
          sendTelegramNotification(tgMsg);
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
          timestamp: new Date().toISOString()
        };

        mqttClient.publish(commandTopic, JSON.stringify(commandPayload), { qos: 1 }, () => {
          console.log(`[MQTT-ACTUATOR] Mode AUTO aktif untuk ${device_code}. Mengirim hasil ML:`, commandPayload.actuators);
          // Siarkan ke WebSocket agar UI ikut ter-update
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
