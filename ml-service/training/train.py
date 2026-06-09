import sys
from pathlib import Path
import joblib
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.tree import DecisionTreeClassifier

# Dendaftarkan root direktori proyek ke sys.path secara elegan
sys.path.append(str(Path(__file__).resolve().parents[1]))

def train_decision_tree() -> None:
    """Melatih Decision Tree Classifier offline dari file dataset CSV."""
    print("\n>>> Melatih Model Klasifikasi Status Kekeringan (Decision Tree) Offline...")
    
    # Path dataset
    dataset_path = Path("dataset/shoe_sensor.csv")
    if not dataset_path.exists():
        # Jika file tidak ada, coba buat dummy dataset
        print(f"    [WARNING] Dataset {dataset_path} tidak ditemukan. Silakan jalankan script dataset generator.")
        return

    df = pd.read_csv(str(dataset_path))
    
    # Pastikan kolom yang diperlukan ada
    # Jika menggunakan dataset lama, rename kolom/sesuaikan
    if 'humidity' not in df.columns and 'kelembapan_sekarang' in df.columns:
        df = df.rename(columns={'kelembapan_sekarang': 'humidity'})
    if 'temperature' not in df.columns:
        # Jika tidak ada kolom temperature, buat data dummy random
        df['temperature'] = np.random.uniform(25.0, 45.0, len(df))
        
    print(f"    [INFO] Memproses {len(df)} baris data untuk Decision Tree...")
    
    # Pelabelan berdasarkan Kombinasi Suhu & Kelembapan (Thermodynamic Rule-based Labeling)
    # Kelas 0: Kering, Kelas 1: Lembap, Kelas 2: Basah
    conds = [
        (df['humidity'] <= 35.0) | ((df['humidity'] <= 45.0) & (df['temperature'] >= 40.0)),
        (df['humidity'] > 70.0) | ((df['humidity'] > 60.0) & (df['temperature'] < 30.0))
    ]
    choices = [0, 2]
    df['drying_status'] = np.select(conds, choices, default=1)
    
    X = df[['temperature', 'humidity']]
    y = df['drying_status']
    
    # Standarisasi fitur
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # Latih Decision Tree
    model_dt = DecisionTreeClassifier(max_depth=3, random_state=42)
    model_dt.fit(X_scaled, y)
    
    # Simpan model & scaler ke trained_model/
    output_dir = Path("trained_model")
    output_dir.mkdir(exist_ok=True)
    
    joblib.dump(model_dt, output_dir / "dryness_model.joblib")
    joblib.dump(scaler, output_dir / "dryness_scaler.joblib")
    
    print(f"    [INFO] Model Decision Tree sukses disimpan di: {output_dir}")
    print(f"    [INFO] Fitur yang digunakan: ['temperature', 'humidity']")
    print(f"    [INFO] Kelas: 0 (Kering), 1 (Lembap), 2 (Basah)\n")

if __name__ == "__main__":
    train_decision_tree()
