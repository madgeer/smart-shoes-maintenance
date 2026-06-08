from pathlib import Path
import pandas as pd
import numpy as np

# Mengatur random seed agar hasil acak selalu konsisten saat dijalankan ulang
np.random.seed(42)

def generate_decision_tree_dataset(n_samples: int = 1000) -> pd.DataFrame:
    """Menghasilkan dataset sintetis untuk model klasifikasi status kekeringan (Decision Tree).

    Fungsi ini menyimulasikan data fisik dari sensor suhu dan kelembapan
    yang berkorelasi secara realistis.

    Args:
        n_samples (int): Jumlah baris sampel data yang akan dibuat. Defaults to 1000.

    Returns:
        pd.DataFrame: DataFrame Pandas berisi fitur 'temperature' dan 'humidity'.
    """
    print(">>> Menghasilkan Dataset Sensor untuk Decision Tree...")
    
    # 1. Membuat data suhu (20°C s.d 55°C)
    temperature = np.random.uniform(20.0, 55.0, n_samples)
    
    # 2. Membuat data kelembapan (10% s.d 95% RH)
    # Kelembapan cenderung lebih rendah pada suhu tinggi (korelasi fisik negatif)
    humidity_base = 100.0 - (temperature - 20.0) * 1.8
    noise_humidity = np.random.normal(0.0, 8.0, n_samples)
    humidity = humidity_base + noise_humidity
    humidity = np.clip(humidity, 10.0, 95.0)
    
    df = pd.DataFrame({
        'temperature': np.round(temperature, 2),
        'humidity': np.round(humidity, 2)
    })
    
    return df

if __name__ == "__main__":
    # Menentukan direktori penyimpanan secara dinamis berdasarkan lokasi script ini
    dataset_dir = Path(__file__).resolve().parent
    dataset_dir.mkdir(exist_ok=True)
    
    # Lokasi penyimpanan file CSV yang absolut & aman
    smell_path = dataset_dir / "shoe_sensor.csv"
    
    # Membuat dataset
    df_dataset = generate_decision_tree_dataset()
    
    # Menyimpan DataFrame ke file CSV
    df_dataset.to_csv(smell_path, index=False)
    
    print(f"\n[SUKSES] Dataset berhasil dibuat secara profesional!")
    print(f"  - File tersimpan: {smell_path.name} ({len(df_dataset)} baris)")
    print(f"  - Folder tujuan : {dataset_dir}\n")
