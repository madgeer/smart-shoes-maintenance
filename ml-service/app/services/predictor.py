import os
import joblib
import numpy as np
from typing import Tuple

class PredictorService:
    """Layanan inferensi untuk memuat model ML (Decision Tree) dan melakukan prediksi status kekeringan sepatu."""

    def __init__(self, model_dir: str = "trained_model") -> None:
        """Memuat model dan scaler .joblib dari folder trained_model/."""
        self.reload_models(model_dir)

    def reload_models(self, model_dir: str) -> None:
        """Memuat ulang model detektor kekeringan secara dinamis tanpa downtime."""
        print(f"[DYNAMIC-RELOAD] Memuat ulang model Decision Tree dari: {model_dir}")
        self.dryness_model = joblib.load(os.path.join(model_dir, "dryness_model.joblib"))
        self.dryness_scaler = joblib.load(os.path.join(model_dir, "dryness_scaler.joblib"))
        print("[DYNAMIC-RELOAD] Model Decision Tree sukses dimuat ulang!")

    def predict_drying_time(self, kelembapan_awal: float, kelembapan_sekarang: float, suhu: float, jenis_bahan: int, sensor_bau: float) -> Tuple[float, str]:
        """Memprediksi sisa waktu pengeringan sepatu secara matematis/rule-based."""
        if kelembapan_sekarang <= 25.0:
            return 0.0, "Selesai (Sepatu sudah kering optimal)"

        # Selisih kelembapan ke target kering (25%)
        selisih_kelembapan = kelembapan_sekarang - 25.0

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

    def predict_dryness_level(self, gas_mq135: float, kelembapan_sekarang: float, suhu: float = 25.0) -> Tuple[int, int, str, float, float]:
        """Memprediksi status kekeringan sepatu (Kering, Lembap, Basah) menggunakan model Decision Tree."""
        import pandas as pd
        
        # Model Decision Tree: Menggunakan 1 fitur (humidity)
        input_df = pd.DataFrame([[kelembapan_sekarang]], columns=['humidity'])
        input_scaled = self.dryness_scaler.transform(input_df)
        
        label = int(self.dryness_model.predict(input_scaled)[0])
        klaster_asli = label
        
        gas_norm = 0.0  # Dummy karena tidak lagi menggunakan sensor gas MQ-135
        moist_norm = float(input_scaled[0][0])
        kategori_mapping = {0: "Kering", 1: "Lembap", 2: "Basah"}
        
        kategori = kategori_mapping.get(label, "Tidak Diketahui")
            
        return klaster_asli, label, kategori, round(gas_norm, 4), round(moist_norm, 4)