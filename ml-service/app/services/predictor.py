import os
import joblib
import numpy as np
from typing import Tuple, Dict, Any
class PredictorService:
    """Layanan inferensi untuk memuat model ML dan melakukan prediksi waktu & bau sepatu."""

    def __init__(self, model_dir: str = "trained_model") -> None:
        """Memuat model-model .joblib dari folder trained_model/."""
        self.reload_models(model_dir)

    def reload_models(self, model_dir: str) -> None:
        """Memuat ulang model detektor bau secara dinamis tanpa downtime."""
        print(f"[DYNAMIC-RELOAD] Memuat ulang semua model ML dari: {model_dir}")
        # 1. Memuat paket model Detektor Bau (K-Means atau Random Forest)
        smell_data = joblib.load(os.path.join(model_dir, "smell_model.joblib"))
        if isinstance(smell_data, dict):
            self.smell_model = smell_data['model']
            self.cluster_mapping = smell_data.get('cluster_mapping', {})
            self.is_random_forest = False
        else:
            self.smell_model = smell_data
            self.cluster_mapping = {}
            self.is_random_forest = True
            
        self.smell_scaler = joblib.load(os.path.join(model_dir, "smell_scaler.joblib"))
        print("[DYNAMIC-RELOAD] Semua model ML berhasil dimuat ulang secara dinamis!")

    def predict_drying_time(self, kelembapan_awal: float, kelembapan_sekarang: float, suhu: float, jenis_bahan: int, sensor_bau: float) -> Tuple[float, str]:
        """Memprediksi sisa waktu pengeringan sepatu secara matematis/rule-based."""
        if kelembapan_sekarang <= 15.0:
            return 0.0, "Selesai (Sepatu sudah kering optimal)"

        # Selisih kelembapan ke target kering (15%)
        selisih_kelembapan = kelembapan_sekarang - 15.0

        # Laju pengeringan dasar (% kelembapan berkurang per menit)
        # Pada suhu 25 derajat berkurang 0.5% per menit. Laju meningkat 0.02% per 1 derajat suhu naik.
        laju_dasar = 0.5 + 0.02 * (suhu - 25.0)
        laju_dasar = max(0.1, laju_dasar)  # Batas bawah laju pengeringan agar tidak nol/negatif

        # Pengali berdasarkan jenis bahan sepatu (1: Kanvas, 2: Kulit, 3: Mesh)
        pengali_bahan = {
            1: 1.0,  # Kanvas (sedang)
            2: 0.7,  # Kulit (lambat)
            3: 1.5   # Mesh (cepat)
        }.get(jenis_bahan, 1.0)

        laju_aktual = laju_dasar * pengali_bahan

        # Estimasi sisa waktu
        sisa_waktu = selisih_kelembapan / laju_aktual

        # Menentukan deskripsi status
        if kelembapan_sekarang > 60.0:
            status = "Sedang dikeringkan (Kondisi sepatu masih sangat basah)"
        else:
            status = "Sedang dikeringkan (Kondisi sepatu hampir kering)"

        return round(sisa_waktu, 2), status
    def predict_smell_level(self, gas_mq135: float, kelembapan_sekarang: float, suhu: float = 25.0) -> Tuple[int, int, str, float, float]:
        """Melakukan normalisasi/standarisasi, memprediksi, dan memetakan tingkat bau."""
        if getattr(self, 'is_random_forest', False):
            import pandas as pd
            # Random Forest menggunakan 3 fitur: temperature, humidity, gas_level
            input_df = pd.DataFrame([[suhu, kelembapan_sekarang, gas_mq135]], columns=['temperature', 'humidity', 'gas_level'])
            input_scaled = self.smell_scaler.transform(input_df)
            
            label = int(self.smell_model.predict(input_scaled)[0])
            klaster_asli = label
            
            gas_norm = float(input_scaled[0][2])
            moist_norm = float(input_scaled[0][1])
        else:
            input_data = np.array([[gas_mq135, kelembapan_sekarang]])
            input_scaled = self.smell_scaler.transform(input_data)
            gas_norm = float(input_scaled[0][0])
            moist_norm = float(input_scaled[0][1])
            
            klaster_asli = int(self.smell_model.predict(input_scaled)[0])
            label = self.cluster_mapping.get(klaster_asli, klaster_asli)
            
        # --- HYBRID SAFETY OVERRIDE ---
        # Jika gas di atas 165 ppm atau kelembapan di atas 80%, paksa jadi Sangat Bau (Class 2)
        # karena data latih sangat minim contoh kelembapan tinggi + gas tinggi.
        if gas_mq135 > 165.0 or kelembapan_sekarang > 80.0:
            label = 2
            klaster_asli = 2
        # ------------------------------
        
        kategori_mapping = {0: "Tidak Bau", 1: "Bau Sedang", 2: "Sangat Bau"}
        kategori = kategori_mapping.get(label, "Tidak Diketahui")
            
        return klaster_asli, label, kategori, round(gas_norm, 4), round(moist_norm, 4)