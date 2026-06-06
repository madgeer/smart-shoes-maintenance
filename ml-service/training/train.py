import sys
from pathlib import Path
import joblib
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.cluster import KMeans
from sklearn.metrics import mean_squared_error, r2_score

# Daftarkan root direktori proyek ke sys.path secara elegan
sys.path.append(str(Path(__file__).resolve().parents[1]))

from training.preprocessing import preprocess_maintenance_data, preprocess_smell_data

def train_drying_time_estimator() -> None:
    """Melatih dan mengevaluasi model Regresi Linier Berganda untuk estimasi waktu pengeringan."""
    print("\n>>> Melatih Model Estimasi Waktu (Regresi Linier)...")
    
    # Mempersiapkan path menggunakan pathlib
    dataset_path = Path("dataset/maintenance_sensor.csv")
    
    # Preprocessing
    X_train_scaled, X_test_scaled, y_train, y_test, scaler = preprocess_maintenance_data(str(dataset_path))
    
    # Fit Model
    model = LinearRegression()
    model.fit(X_train_scaled, y_train)
    
    # Evaluasi
    y_pred = model.predict(X_test_scaled)
    mse = mean_squared_error(y_test, y_pred)
    rmse = np.sqrt(mse)
    r2 = r2_score(y_test, y_pred)
    
    print(f"    [MSE]  : {mse:.4f}")
    print(f"    [RMSE] : {rmse:.4f} menit")
    print(f"    [R2]   : {r2:.4f}")
    print(f"    [Coef] : {model.coef_}")
    print(f"    [Bias] : {model.intercept_:.4f}")
    
    # Menyimpan Model & Scaler
    output_dir = Path("trained_model")
    output_dir.mkdir(exist_ok=True)
    
    joblib.dump(model, output_dir / "maintenance_model.joblib")
    joblib.dump(scaler, output_dir / "maintenance_scaler.joblib")
    print(f"    [INFO] Model & Scaler berhasil disimpan di: {output_dir}\n")


def train_smell_detector() -> None:
    """Melatih Random Forest Classifier untuk mendeteksi bau sepatu."""
    print(">>> Melatih Model Detektor Bau (Random Forest)...")
    
    # Mempersiapkan path
    dataset_path = Path("dataset/shoe_sensor.csv")
    df = pd.read_csv(str(dataset_path))
    
    # 1. Membersihkan anomali semprotan parfum (gas_level > 180 ppm)
    print(f"    [INFO] Data awal: {len(df)} baris")
    df = df[df['gas_level'] <= 180.0].reset_index(drop=True)
    print(f"    [INFO] Data setelah pembersihan outlier: {len(df)} baris")
    
    # 2. Pelabelan berdasarkan Aturan Batas Sensor (Rule-based Labeling)
    conds = [
        df['gas_level'] <= 158.0,
        (df['gas_level'] > 165.0) | (df['humidity'] > 80.0)
    ]
    choices = [0, 2] # 0: Tidak Bau, 2: Sangat Bau
    df['kategori_bau'] = np.select(conds, choices, default=1) # 1: Bau Sedang
    
    X = df[['temperature', 'humidity', 'gas_level']]
    y = df['kategori_bau']
    
    # Membagi dataset menjadi Train & Test set (80:20)
    from sklearn.model_selection import train_test_split
    from sklearn.preprocessing import StandardScaler
    from sklearn.ensemble import RandomForestClassifier
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    # Standarisasi fitur
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Melatih Model Random Forest
    model = RandomForestClassifier(random_state=42)
    model.fit(X_train_scaled, y_train)
    
    # Evaluasi Model
    y_pred = model.predict(X_test_scaled)
    mse = mean_squared_error(y_test, y_pred)
    
    print(f"    [MSE]  : {mse:.4f}")
    
    # Menyimpan Model & Scaler untuk deployment
    output_dir = Path("trained_model")
    output_dir.mkdir(exist_ok=True)
    
    joblib.dump(model, output_dir / "smell_model.joblib")
    joblib.dump(scaler, output_dir / "smell_scaler.joblib")
    print(f"    [INFO] Model & Scaler Bau berhasil disimpan di: {output_dir}\n")


if __name__ == "__main__":
    import pandas as pd
    train_drying_time_estimator()
    train_smell_detector()
    print(">>> Proses pelatihan selesai dengan sukses!")
