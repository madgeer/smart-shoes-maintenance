from pathlib import Path
import pandas as pd
import numpy as np

# Mengatur random seed agar hasil acak selalu konsisten saat dijalankan ulang
np.random.seed(42)

def generate_maintenance_dataset(n_samples: int = 1000) -> pd.DataFrame:
    """Menghasilkan dataset sintetis untuk estimasi waktu pengeringan sepatu.

    Fungsi ini menyimulasikan data fisik dari sensor kelembapan, suhu, sensor bau,
    dan jenis bahan sepatu untuk menghitung sisa waktu pengeringan menggunakan
    rumus regresi linier.

    Args:
        n_samples (int): Jumlah baris sampel data yang akan dibuat. Defaults to 1000.

    Returns:
        pd.DataFrame: DataFrame Pandas berisi fitur 'kelembapan_awal', 'kelembapan_sekarang',
            'suhu', 'jenis_bahan', 'sensor_bau', dan target 'sisa_waktu'.
    """
    print(">>> Menghasilkan Dataset Estimator Waktu Pengeringan (Regression)...")
    
    # 1. Membuat Fitur Input (X)
    kelembapan_awal: np.ndarray = np.random.uniform(30.0, 90.0, n_samples)
    
    # kelembapan_sekarang: Harus lebih kecil atau sama dengan kelembapan_awal, minimal 10.0%
    kelembapan_sekarang_list: list = []
    for init in kelembapan_awal:
        curr: float = np.random.uniform(10.0, init)
        kelembapan_sekarang_list.append(curr)
    kelembapan_sekarang: np.ndarray = np.array(kelembapan_sekarang_list)
    
    # Suhu pemanas: 30.0°C s.d 70.0°C
    suhu: np.ndarray = np.random.uniform(30.0, 70.0, n_samples)
    
    # Jenis bahan: 1 = Kanvas, 2 = Kulit, 3 = Mesh
    jenis_bahan: np.ndarray = np.random.choice([1, 2, 3], size=n_samples)
    
    # Sensor bau (Amonia): berkorelasi positif dengan kelembapan (sepatu basah/lembap cenderung lebih bau)
    # Plus noise agar realistis
    noise_bau: np.ndarray = np.random.normal(0.0, 40.0, n_samples)
    sensor_bau: np.ndarray = 100.0 + (kelembapan_sekarang / 100.0) * 800.0 + noise_bau
    sensor_bau = np.clip(sensor_bau, 100.0, 1000.0)
    
    # 2. Membuat Target Output (Y): sisa_waktu (Menit)
    noise_waktu: np.ndarray = np.random.normal(0.0, 1.5, n_samples)
    
    # Efek jenis bahan terhadap waktu pengeringan:
    # 2 (Kulit): Lambat kering (+20 menit)
    # 3 (Mesh): Cepat kering (-15 menit)
    # 1 (Kanvas): Baseline (0 menit)
    efek_bahan: np.ndarray = np.where(jenis_bahan == 2, 20.0, np.where(jenis_bahan == 3, -15.0, 0.0))
    
    # Rumus hubungan fisik yang realistis
    sisa_waktu: np.ndarray = (
        1.5 * (kelembapan_sekarang - 10.0)
        - 0.8 * (suhu - 30.0)
        + efek_bahan
        + 0.05 * (sensor_bau - 100.0)
        + noise_waktu
    )
    sisa_waktu = np.clip(sisa_waktu, 0.0, None)
    
    df: pd.DataFrame = pd.DataFrame({
        'kelembapan_awal': np.round(kelembapan_awal, 2),
        'kelembapan_sekarang': np.round(kelembapan_sekarang, 2),
        'suhu': np.round(suhu, 2),
        'jenis_bahan': jenis_bahan,
        'sensor_bau': np.round(sensor_bau, 2),
        'sisa_waktu': np.round(sisa_waktu, 2)
    })
    
    return df

def generate_shoe_smell_dataset(n_samples: int = 1000) -> pd.DataFrame:
    """Menghasilkan dataset murni tanpa label untuk clustering bau sepatu.

    Fungsi ini menyimulasikan 3 kondisi fisik sepatu (Wangi, Normal, Bau) menggunakan
    metode Gaussian Mixture. Output DataFrame sengaja dibuat tanpa label target untuk
    mensimulasikan pembelajaran tidak terarah (Unsupervised Learning) menggunakan K-Means.

    Args:
        n_samples (int): Jumlah baris sampel data yang akan dibuat. Defaults to 1000.

    Returns:
        pd.DataFrame: DataFrame Pandas berisi fitur 'gas_mq135' dan 'kelembapan_sekarang'.
    """
    print(">>> Menghasilkan Dataset Sensor Bau Sepatu Tanpa Label (K-Means)...")
    
    # Proporsi sampel untuk setiap kelompok kondisi
    n_wangi: int = int(n_samples * 0.3)
    n_normal: int = int(n_samples * 0.4)
    n_bau: int = n_samples - n_wangi - n_normal
    
    # 1. Kelompok 1: Kondisi Wangi/Bersih (Gas & Kelembapan rendah)
    gas_wangi: np.ndarray = np.random.normal(200.0, 40.0, n_wangi)
    moist_wangi: np.ndarray = np.random.normal(30.0, 5.0, n_wangi)
    
    # 2. Kelompok 2: Kondisi Normal (Gas & Kelembapan sedang)
    gas_normal: np.ndarray = np.random.normal(450.0, 65.0, n_normal)
    moist_normal: np.ndarray = np.random.normal(50.0, 7.0, n_normal)
    
    # 3. Kelompok 3: Kondisi Bau/Lembap (Gas & Kelembapan tinggi)
    gas_bau: np.ndarray = np.random.normal(750.0, 60.0, n_bau)
    moist_bau: np.ndarray = np.random.normal(75.0, 6.0, n_bau)
    
    # Menggabungkan ketiga klaster fisik
    gas: np.ndarray = np.concatenate([gas_wangi, gas_normal, gas_bau])
    moist: np.ndarray = np.concatenate([moist_wangi, moist_normal, moist_bau])
    
    # Membatasi nilai agar tetap realistis
    gas = np.clip(gas, 100.0, 1000.0)
    moist = np.clip(moist, 10.0, 100.0)
    
    # Mengacak posisi baris data
    indices: np.ndarray = np.arange(n_samples)
    np.random.shuffle(indices)
    
    gas = gas[indices]
    moist = moist[indices]
    
    df: pd.DataFrame = pd.DataFrame({
        'gas_mq135': np.round(gas, 2),
        'kelembapan_sekarang': np.round(moist, 2)
    })
    
    return df

if __name__ == "__main__":
    # Menentukan direktori penyimpanan secara dinamis berdasarkan lokasi script ini
    # (Selalu menunjuk ke folder 'dataset/' di dalam struktur proyek Anda)
    dataset_dir: Path = Path(__file__).resolve().parent
    dataset_dir.mkdir(exist_ok=True)
    
    # Lokasi penyimpanan file CSV yang absolut & aman
    maintenance_path: Path = dataset_dir / "maintenance_sensor.csv"
    smell_path: Path = dataset_dir / "shoe_sensor.csv"
    
    # Membuat dataset
    df_maintenance: pd.DataFrame = generate_maintenance_dataset()
    df_smell: pd.DataFrame = generate_shoe_smell_dataset()
    
    # Menyimpan DataFrame ke file CSV
    df_maintenance.to_csv(maintenance_path, index=False)
    df_smell.to_csv(smell_path, index=False)
    
    print(f"\n[SUKSES] Dataset berhasil dibuat secara profesional!")
    print(f"  - File tersimpan: {maintenance_path.name} ({len(df_maintenance)} baris)")
    print(f"  - File tersimpan: {smell_path.name} ({len(df_smell)} baris)")
    print(f"  - Folder tujuan : {dataset_dir}\n")
