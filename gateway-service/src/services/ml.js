const axios = require('axios');
require('dotenv').config();

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:8000';

/**
 * Memanggil ML Service untuk mendapatkan prediksi klasifikasi tingkat kekeringan sepatu (Decision Tree)
 * @param {number} gasMq135 - Nilai sensor gas MQ-135
 * @param {number} kelembapanSekarang - Nilai kelembapan sensor DHT22
 * @returns {Promise<object>} Hasil prediksi dari ML Service
 */
const predictDryness = async (gasMq135, kelembapanSekarang, suhu) => {
  try {
    const url = `${ML_SERVICE_URL}/predict/dryness`;
    const payload = {
      gas_mq135: parseFloat(gasMq135),
      kelembapan_sekarang: parseFloat(kelembapanSekarang),
      suhu: parseFloat(suhu || 25.0)
    };

    console.log(`[ML-SERVICE] Mengirim data ke Classifier:`, payload);
    const response = await axios.post(url, payload, { timeout: 2000 });
    return response.data;
  } catch (error) {
    console.error(`[ML-SERVICE] Gagal memprediksi tingkat kekeringan sepatu:`, error.message);
    // Fallback default jika ML Service mati agar sistem tetap jalan
    return {
      klaster_asli: -1,
      label: 1, // Default ke 'Lembap'
      kategori: 'Lembap',
      gas_mq135_normalisasi: 0.5,
      kelembapan_normalisasi: 0.5,
      is_fallback: true
    };
  }
};

/**
 * Memanggil ML Service untuk mendapatkan estimasi sisa waktu pengeringan sepatu (Perhitungan Matematika)
 * @param {number} kelembapanAwal - Kelembapan sepatu di awal pengeringan (%)
 * @param {number} kelembapanSekarang - Kelembapan sepatu saat ini (%)
 * @param {number} suhu - Suhu heater pengering (°C)
 * @param {number} jenisBahan - Kode bahan sepatu (1: Kanvas, 2: Kulit, 3: Mesh)
 * @param {number} sensorBau - Kadar gas MQ-135 (ppm)
 * @returns {Promise<object>} Hasil prediksi dari ML Service
 */
const predictDryingTime = async (kelembapanAwal, kelembapanSekarang, suhu, jenisBahan, sensorBau) => {
  try {
    const url = `${ML_SERVICE_URL}/predict/maintenance`;
    
    // Logika pengaman fisik: kelembapan sekarang tidak boleh lebih besar dari kelembapan awal
    let adjustedKelembapanAwal = parseFloat(kelembapanAwal);
    let adjustedKelembapanSekarang = parseFloat(kelembapanSekarang);
    if (adjustedKelembapanSekarang > adjustedKelembapanAwal) {
      adjustedKelembapanAwal = adjustedKelembapanSekarang; // Samakan agar tidak ditolak API FastAPI
    }

    const payload = {
      kelembapan_awal: adjustedKelembapanAwal,
      kelembapan_sekarang: adjustedKelembapanSekarang,
      suhu: parseFloat(suhu),
      jenis_bahan: parseInt(jenisBahan),
      sensor_bau: parseFloat(sensorBau)
    };

    console.log(`[ML-SERVICE] Mengirim data ke Estimator Waktu (Matematika):`, payload);
    const response = await axios.post(url, payload, { timeout: 2000 });
    return response.data;
  } catch (error) {
    console.error(`[ML-SERVICE] Gagal memprediksi sisa waktu pengeringan:`, error.message);
    // Fallback default jika ML Service mati
    return {
      sisa_waktu_menit: kelembapanSekarang <= 25.0 ? 0.0 : 30.0,
      status: 'Sedang dikeringkan (Layanan ML sedang Offline)',
      is_fallback: true
    };
  }
};

module.exports = {
  predictDryness,
  predictDryingTime
};
