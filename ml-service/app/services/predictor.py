import os
import joblib
import numpy as np
from typing import Tuple, Dict, Any
class PredictorService:
    """Layanan inferensi untuk memuat model ML dan melakukan prediksi waktu & bau sepatu."""

    def __init__(self, model_dir: str = "trained_model") -> None:
        """Memuat model-model .joblib dari folder trained_model/."""
        # 1. Memuat model Estimator Waktu (Regression)
        self.maintenance_model = joblib.load(os.path.join(model_dir, "maintenance_model.joblib"))
        self.maintenance_scaler = joblib.load(os.path.join(model_dir, "maintenance_scaler.joblib"))

        # 2. Memuat paket model Detektor Bau (K-Means)
        smell_package: Dict[str, Any] = joblib.load(os.path.join(model_dir, "smell_model.joblib"))
        self.smell_model = smell_package['model']
        self.cluster_mapping: Dict[int, int] = smell_package['cluster_mapping']
        self.smell_scaler = joblib.load(os.path.join(model_dir, "smell_scaler.joblib"))

    def predict_drying_time(self, kelembapan_awal: float, kelembapan_sekarang: float, suhu: float, jenis_bahan: int, sensor_bau: float) -> Tuple[float, str]:
        """Melakukan normalisasi otomatis dan memprediksi sisa waktu pengeringan."""
        # Melakukan One-Hot Encoding secara dinamis untuk jenis bahan
        bahan_kanvas: float = 1.0 if jenis_bahan == 1 else 0.0
        bahan_kulit: float = 1.0 if jenis_bahan == 2 else 0.0
        bahan_mesh: float = 1.0 if jenis_bahan == 3 else 0.0

        # Membuat format input 2D untuk scaler dengan 7 fitur
        input_data: np.ndarray = np.array([[
            kelembapan_awal,
            kelembapan_sekarang,
            suhu,
            sensor_bau,
            bahan_kanvas,
            bahan_kulit,
            bahan_mesh
        ]])

        # Normalisasi otomatis sebelum prediksi
        input_scaled: np.ndarray = self.maintenance_scaler.transform(input_data)

        # Prediksi waktu
        sisa_waktu: float = float(self.maintenance_model.predict(input_scaled)[0])
        sisa_waktu = max(0.0, sisa_waktu)  # Pengaman agar tidak ada sisa waktu minus

        # Menentukan deskripsi status
        if sisa_waktu == 0.0 or kelembapan_sekarang <= 10.0:
            status = "Selesai (Sepatu sudah kering optimal)"
        elif kelembapan_sekarang > 60.0:
            status = "Sedang dikeringkan (Kondisi sepatu masih sangat basah)"
        else:
            status = "Sedang dikeringkan (Kondisi sepatu hampir kering)"

        return round(sisa_waktu, 2), status
    def predict_smell_level(self, gas_mq135: float, kelembapan_sekarang: float) -> Tuple[int, int, str, float, float]:
        """Melakukan normalisasi, memprediksi klaster K-Means, dan memetakan tingkat bau."""
        # Membuat format input 2D untuk scaler
        input_data: np.ndarray = np.array([[gas_mq135, kelembapan_sekarang]])

        # Normalisasi otomatis gas & kelembapan
        input_scaled: np.ndarray = self.smell_scaler.transform(input_data)
        gas_norm: float = float(input_scaled[0][0])
        moist_norm: float = float(input_scaled[0][1])
        
        # Prediksi klaster acak K-Means
        klaster_asli: int = int(self.smell_model.predict(input_scaled)[0])

        # Memetakan klaster acak K-Means ke label fisik terurut (0: Wangi, 1: Normal, 2: Bau)
        label: int = self.cluster_mapping.get(klaster_asli, klaster_asli)

        # Mengubah label angka menjadi teks deskriptif
        kategori_mapping = {0: "Wangi", 1: "Normal", 2: "Bau"}
        kategori: str = kategori_mapping.get(label, "Tidak Diketahui")

        return klaster_asli, label, kategori, round(gas_norm, 4), round(moist_norm, 4)