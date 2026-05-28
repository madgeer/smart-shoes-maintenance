/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - ESP32 INTERACTIVE HARDWARE EMULATOR
 * =========================================================================
 * Script ini menyimulasikan perangkat fisik pengering sepatu berbasis ESP32.
 * Menghubungkan diri ke Mosquitto Broker via MQTT untuk:
 * 1. Mengirim telemetri sensor (Suhu, Kelembapan, Kadar Gas Bau) setiap 5 detik.
 * 2. Menerima instruksi perintah aktuator (Heater, Kipas, Lampu UV) dari Gateway.
 * 3. Menyediakan simulasi fisika interaktif (nilai sensor merespon aktuator).
 * =========================================================================
 */

const readline = require('readline');

let mqtt;
try {
  mqtt = require('mqtt');
} catch (e) {
  console.error('\nERROR: Library "mqtt" tidak ditemukan.');
  console.error('Silakan jalankan perintah berikut di folder "scripts" terlebih dahulu:');
  console.error('   npm install\n');
  process.exit(1);
}

// 1. Konfigurasi Parameter Default dari CLI
// -------------------------------------------------------------------------
const args = process.argv.slice(2);
let deviceCode = 'ESP32-SHOE-001';
let shoeId = 1;
let brokerUrl = 'mqtt://localhost:1883';

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--device' && args[i + 1]) {
    deviceCode = args[i + 1];
    i++;
  } else if (args[i] === '--shoe' && args[i + 1]) {
    shoeId = parseInt(args[i + 1], 10);
    i++;
  } else if (args[i] === '--broker' && args[i + 1]) {
    brokerUrl = args[i + 1];
    i++;
  }
}

// 2. State Fisik & Metrik Perangkat (Model Simulasi Fisika)
// -------------------------------------------------------------------------
let physicalState = {
  temperature: 25.0,       // Suhu awal ambient (°C)
  humidity: 75.0,          // Kelembapan awal sepatu basah (%)
  gas_level: 450.0,        // Kadar bau MQ-135 awal (ppm)
  actuators: {
    heater: 'OFF',
    uv_light: 'OFF',
    fan: 'OFF'
  },
  mode: 'auto',            // auto / manual
  metrics: {
    duration_usage: 0.0,      // Total durasi aktif (jam)
    fan_usage_duration: 0.0,  // Durasi blower aktif (jam)
    uv_usage_duration: 0.0    // Durasi UV aktif (jam)
  },
  lastCommandId: 'N/A',
  connectionStatus: 'MENGHUBUNGKAN...',
  isWaitingForInput: false // State pengaman input terminal
};

const AMBIENT_TEMP = 25.0;
const MAX_HEATER_TEMP = 48.0;
const MIN_HUMIDITY = 12.0;
const MIN_GAS_LEVEL = 120.0;

// 3. Konfigurasi Koneksi MQTT & LWT (Last Will and Testament)
// -------------------------------------------------------------------------
const clientId = `ESP32_SHOE_${Math.random().toString(16).substring(2, 10).toUpperCase()}`;
console.clear();
console.log(`[SIMULATOR] Memulai koneksi ke Broker: ${brokerUrl} dengan Client ID: ${clientId}...`);

const statusTopic = `v1/devices/${deviceCode}/status`;
const telemetryTopic = `v1/devices/${deviceCode}/telemetry`;
const commandTopic = `v1/devices/${deviceCode}/commands`;

const client = mqtt.connect(brokerUrl, {
  clientId: clientId,
  keepalive: 60,
  clean: true,
  // Last Will: Jika perangkat terputus mendadak, broker otomatis kirim status offline
  will: {
    topic: statusTopic,
    payload: JSON.stringify({
      device_code: deviceCode,
      status: 'offline',
      timestamp: new Date().toISOString()
    }),
    qos: 1,
    retain: true
  }
});

// 4. Integrasi Event MQTT
// -------------------------------------------------------------------------
client.on('connect', () => {
  physicalState.connectionStatus = 'TERHUBUNG';
  
  // A. Subscribe ke Topik Perintah Aktuator
  client.subscribe(commandTopic, { qos: 1 }, (err) => {
    if (err) {
      console.error(`[MQTT] Gagal berlangganan topik perintah: ${commandTopic}`);
    }
  });

  // B. Publish Status Online ke Broker (Retain = true)
  const onlinePayload = {
    device_code: deviceCode,
    status: 'online',
    timestamp: new Date().toISOString()
  };
  client.publish(statusTopic, JSON.stringify(onlinePayload), { qos: 1, retain: true });

  drawDashboard();
});

client.on('message', (topic, message) => {
  if (topic === commandTopic) {
    try {
      const payload = JSON.parse(message.toString());
      
      // Update status aktuator fisik sesuai perintah dari Gateway Service
      if (payload.actuators) {
        physicalState.actuators.heater = payload.actuators.heater || physicalState.actuators.heater;
        physicalState.actuators.uv_light = payload.actuators.uv_light || physicalState.actuators.uv_light;
        physicalState.actuators.fan = payload.actuators.fan || physicalState.actuators.fan;
      }
      
      if (payload.mode) {
        physicalState.mode = payload.mode;
      }

      if (payload.command_id) {
        physicalState.lastCommandId = payload.command_id;
      }

      drawDashboard();
    } catch (err) {
      // Abaikan jika payload bukan JSON valid
    }
  }
});

client.on('close', () => {
  physicalState.connectionStatus = 'TERPUTUS';
  drawDashboard();
});

client.on('error', (err) => {
  physicalState.connectionStatus = `ERROR: ${err.message}`;
  drawDashboard();
});

// 5. Loop Simulasi Fisika & Pengiriman Telemetri (Tiap 5 Detik)
// -------------------------------------------------------------------------
setInterval(() => {
  if (client.connected) {
    // A. Akumulasi Durasi Waktu Pemakaian (Dipercepat: 1 tick = +0.05 jam / 3 menit)
    physicalState.metrics.duration_usage += 0.05;
    if (physicalState.actuators.fan === 'ON') {
      physicalState.metrics.fan_usage_duration += 0.05;
    }
    if (physicalState.actuators.uv_light === 'ON') {
      physicalState.metrics.uv_usage_duration += 0.05;
    }

    // B. Perhitungan Fisika Suhu
    if (physicalState.actuators.heater === 'ON') {
      // Suhu naik jika pemanas aktif (ke batas maksimum 48 derajat)
      physicalState.temperature = Math.min(MAX_HEATER_TEMP, physicalState.temperature + 1.5);
    } else {
      // Suhu turun menuju suhu ruangan jika pemanas nonaktif
      if (physicalState.temperature > AMBIENT_TEMP) {
        physicalState.temperature = Math.max(AMBIENT_TEMP, physicalState.temperature - 0.5);
      } else {
        physicalState.temperature = Math.min(AMBIENT_TEMP, physicalState.temperature + 0.2);
      }
    }

    // C. Perhitungan Fisika Kelembapan
    if (physicalState.actuators.heater === 'ON' && physicalState.actuators.fan === 'ON') {
      // Pengeringan sangat cepat jika Heater + Fan menyala
      physicalState.humidity = Math.max(MIN_HUMIDITY, physicalState.humidity - 2.2);
    } else if (physicalState.actuators.heater === 'ON') {
      // Pengeringan lambat jika hanya Heater menyala
      physicalState.humidity = Math.max(MIN_HUMIDITY, physicalState.humidity - 0.8);
    } else if (physicalState.actuators.fan === 'ON') {
      // Pengeringan minimal jika hanya Kipas menyala
      physicalState.humidity = Math.max(MIN_HUMIDITY, physicalState.humidity - 0.3);
    }

    // D. Perhitungan Fisika Kadar Bau (Gas MQ-135)
    if (physicalState.actuators.uv_light === 'ON' && physicalState.actuators.fan === 'ON') {
      // Dekontaminasi cepat jika UV + Fan menyala (udara tersirkulasi)
      physicalState.gas_level = Math.max(MIN_GAS_LEVEL, physicalState.gas_level - 18.0);
    } else if (physicalState.actuators.uv_light === 'ON') {
      // Dekontaminasi sedang jika hanya lampu UV menyala
      physicalState.gas_level = Math.max(MIN_GAS_LEVEL, physicalState.gas_level - 10.0);
    }

    // E. Siapkan payload telemetri sesuai standard mqtt-specification.md
    const telemetryPayload = {
      device_code: deviceCode,
      shoe_id: shoeId,
      telemetry: {
        temperature: parseFloat(physicalState.temperature.toFixed(2)),
        humidity: parseFloat(physicalState.humidity.toFixed(2)),
        gas_level: parseFloat(physicalState.gas_level.toFixed(2))
      },
      metrics: {
        duration_usage: parseFloat(physicalState.metrics.duration_usage.toFixed(2)),
        fan_usage_duration: parseFloat(physicalState.metrics.fan_usage_duration.toFixed(2)),
        uv_usage_duration: parseFloat(physicalState.metrics.uv_usage_duration.toFixed(2))
      },
      timestamp: new Date().toISOString()
    };

    // F. Publikasikan Telemetri ke Broker
    client.publish(telemetryTopic, JSON.stringify(telemetryPayload), { qos: 0 });
    
    drawDashboard();
  }
}, 5000);

// 6. Tampilan Terminal Dashboard (CLI visual)
// -------------------------------------------------------------------------
function drawDashboard() {
  // Jika sedang menunggu input interaktif, cegah layar di-clear/di-update otomatis
  if (physicalState.isWaitingForInput) return;

  // Clear layar CLI
  console.clear();
  
  // Format warna untuk indikator koneksi
  let connColor = '\x1b[31m'; // Merah
  if (physicalState.connectionStatus === 'TERHUBUNG') connColor = '\x1b[32m'; // Hijau
  
  // Format warna status aktuator
  const getActuatorStr = (state, type) => {
    if (state === 'ON') {
      const color = type === 'heater' ? '\x1b[41m\x1b[37m' : type === 'uv' ? '\x1b[45m\x1b[37m' : '\x1b[44m\x1b[37m';
      return `${color}  ON  \x1b[0m`;
    }
    return '\x1b[2m[ OFF ]\x1b[0m';
  };

  // Format kategori kondisi sensor untuk mempermudah monitoring
  let humidDesc = '\x1b[32mKering / Optimal\x1b[0m';
  if (physicalState.humidity > 60) humidDesc = '\x1b[31mBasah Sekali\x1b[0m';
  else if (physicalState.humidity > 30) humidDesc = '\x1b[33mLembap\x1b[0m';

  let gasDesc = '\x1b[32mAman / Segar\x1b[0m';
  if (physicalState.gas_level > 600) gasDesc = '\x1b[31mBau Parah\x1b[0m';
  else if (physicalState.gas_level > 350) gasDesc = '\x1b[33mKurang Sedap\x1b[0m';

  console.log(`================================================================`);
  console.log(` SIMULATOR PERANGKAT FISIK ESP32 - SMART SHOE MAINTENANCE   `);
  console.log(`================================================================`);
  console.log(` Status Koneksi  : ${connColor}${physicalState.connectionStatus}\x1b[0m`);
  console.log(` Broker MQTT     : \x1b[36m${brokerUrl}\x1b[0m`);
  console.log(` Device Code     : \x1b[33m${deviceCode}\x1b[0m | 📦 Shoe ID: \x1b[35m${shoeId}\x1b[0m`);
  console.log(`  Client ID       : \x1b[90m${clientId}\x1b[0m`);
  console.log(`----------------------------------------------------------------`);
  console.log(` TELEMETRI SENSOR (Dikirim berkala tiap 5 detik):`);
  console.log(`    Suhu        : \x1b[1m${physicalState.temperature.toFixed(1)} °C\x1b[0m`);
  console.log(`    Kelembapan   : \x1b[1m${physicalState.humidity.toFixed(1)} %\x1b[0m (${humidDesc})`);
  console.log(`    Sensor Bau   : \x1b[1m${physicalState.gas_level.toFixed(1)} ppm\x1b[0m (${gasDesc})`);
  console.log(`----------------------------------------------------------------`);
  console.log(` STATUS AKTUATOR FISIK (Menerima perintah Gateway):`);
  console.log(`    Pemanas (Heater)  : ${getActuatorStr(physicalState.actuators.heater, 'heater')}`);
  console.log(`    Lampu UV Steril   : ${getActuatorStr(physicalState.actuators.uv_light, 'uv')}`);
  console.log(`    Kipas Blower      : ${getActuatorStr(physicalState.actuators.fan, 'fan')}`);
  console.log(`    Mode Operasional  : \x1b[1m${physicalState.mode.toUpperCase()}\x1b[0m`);
  console.log(`    Last Command ID   : \x1b[90m${physicalState.lastCommandId}\x1b[0m`);
  console.log(`----------------------------------------------------------------`);
  console.log(` METRIK AKUMULASI WAKTU (Skala Dipercepat):`);
  console.log(`    Total Durasi    : \x1b[36m${physicalState.metrics.duration_usage.toFixed(2)} jam\x1b[0m`);
  console.log(`    Kipas Aktif      : \x1b[36m${physicalState.metrics.fan_usage_duration.toFixed(2)} jam\x1b[0m`);
  console.log(`    UV Aktif         : \x1b[36m${physicalState.metrics.uv_usage_duration.toFixed(2)} jam\x1b[0m`);
  console.log(`================================================================`);
  console.log(` MENU INTERAKTIF (Ketik angka menu lalu Enter):`);
  console.log(` \x1b[92m[1] Basahi Sepatu (Set kelembapan ke 82% & suhu 25°C)\x1b[0m`);
  console.log(` \x1b[93m[2] Buat Sepatu Bau (Set gas MQ-135 ke 680 ppm)\x1b[0m`);
  console.log(` \x1b[96m[3] Bersihkan Manual (Set kelembapan ke 14% & gas ke 120 ppm)\x1b[0m`);
  console.log(` \x1b[95m[4] Ganti Kode Alat & ID Sepatu\x1b[0m`);
  console.log(` \x1b[94m[5] Set Nilai Sensor Kustom (Dinamis)\x1b[0m`);
  console.log(` \x1b[31m[Q] Keluar dari Emulator\x1b[0m`);
  console.log(`================================================================`);
  process.stdout.write(' Pilihan Anda: ');
}

// 7. Penanganan Input Keyboard Interaktif
// -------------------------------------------------------------------------
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.on('line', (line) => {
  const choice = line.trim();
  
  if (choice === '1') {
    physicalState.humidity = 82.0;
    physicalState.temperature = AMBIENT_TEMP;
    drawDashboard();
  } else if (choice === '2') {
    physicalState.gas_level = 680.0;
    drawDashboard();
  } else if (choice === '3') {
    physicalState.humidity = 14.0;
    physicalState.gas_level = 120.0;
    physicalState.actuators = { heater: 'OFF', uv_light: 'OFF', fan: 'OFF' };
    drawDashboard();
  } else if (choice === '4') {
    physicalState.isWaitingForInput = true;
    rl.question('\n Masukkan Device Code baru (misal: ESP32-SHOE-001): ', (newDev) => {
      if (newDev.trim()) deviceCode = newDev.trim();
      rl.question(' Masukkan Shoe ID baru (angka): ', (newShoe) => {
        const parsed = parseInt(newShoe, 10);
        if (!isNaN(parsed)) shoeId = parsed;
        
        // Rekoneksi dengan LWT topik baru
        client.end(true, () => {
          console.log('\n Menginisiasi ulang koneksi MQTT...');
          process.exit(0); // Exit dan jalankan ulang untuk reconnect
        });
      });
    });
  } else if (choice === '5') {
    physicalState.isWaitingForInput = true;
    console.clear();
    console.log(`================================================================`);
    console.log(` SET NILAI SENSOR KUSTOM (DINAMIS)                             `);
    console.log(`================================================================`);
    console.log(` * Tekan Enter langsung jika tidak ingin mengubah nilai sensor.  `);
    console.log(` * Gunakan format angka desimal positif (contoh: 28.5 atau 60).  `);
    console.log(`----------------------------------------------------------------`);
    
    rl.question(` Masukkan Suhu baru (°C) [Sekarang: ${physicalState.temperature.toFixed(1)} °C]: `, (tempStr) => {
      let nextTemp = physicalState.temperature;
      if (tempStr.trim() !== '') {
        const val = parseFloat(tempStr.trim());
        if (!isNaN(val) && val >= 0) {
          nextTemp = val;
        } else {
          console.log(` \x1b[31m[!] Input tidak valid. Menggunakan nilai lama: ${nextTemp.toFixed(1)} °C\x1b[0m`);
        }
      }
      
      rl.question(` Masukkan Kelembapan baru (%) [Sekarang: ${physicalState.humidity.toFixed(1)} %]: `, (humStr) => {
        let nextHum = physicalState.humidity;
        if (humStr.trim() !== '') {
          const val = parseFloat(humStr.trim());
          if (!isNaN(val) && val >= 0 && val <= 100) {
            nextHum = val;
          } else {
            console.log(` \x1b[31m[!] Input tidak valid (harus 0-100%). Menggunakan nilai lama: ${nextHum.toFixed(1)} %\x1b[0m`);
          }
        }
        
        rl.question(` Masukkan Kadar Gas MQ-135 baru (ppm) [Sekarang: ${physicalState.gas_level.toFixed(1)} ppm]: `, (gasStr) => {
          let nextGas = physicalState.gas_level;
          if (gasStr.trim() !== '') {
            const val = parseFloat(gasStr.trim());
            if (!isNaN(val) && val >= 0) {
              nextGas = val;
            } else {
              console.log(` \x1b[31m[!] Input tidak valid. Menggunakan nilai lama: ${nextGas.toFixed(1)} ppm\x1b[0m`);
            }
          }
          
          // Simpan state sensor baru
          physicalState.temperature = nextTemp;
          physicalState.humidity = nextHum;
          physicalState.gas_level = nextGas;
          
          console.log(`----------------------------------------------------------------`);
          console.log(` \x1b[32m[SUKSES] Nilai sensor kustom berhasil diperbarui!\x1b[0m`);
          console.log(` Suhu       : \x1b[1m${physicalState.temperature.toFixed(1)} °C\x1b[0m`);
          console.log(` Kelembapan : \x1b[1m${physicalState.humidity.toFixed(1)} %\x1b[0m`);
          console.log(` Gas MQ-135 : \x1b[1m${physicalState.gas_level.toFixed(1)} ppm\x1b[0m`);
          console.log(`================================================================`);
          console.log(` Layar dashboard akan disegarkan kembali dalam 1.5 detik...`);
          
          setTimeout(() => {
            physicalState.isWaitingForInput = false;
            drawDashboard();
          }, 1500);
        });
      });
    });
  } else if (choice.toLowerCase() === 'q') {
    console.log('\n Mematikan emulator dan melepaskan koneksi MQTT. Sampai jumpa!');
    client.end(false, () => {
      process.exit(0);
    });
  } else {
    drawDashboard();
  }
});
