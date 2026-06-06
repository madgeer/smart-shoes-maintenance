import os
import sys
from pathlib import Path
import joblib
import numpy as np
import pandas as pd
import psycopg2
from sklearn.linear_model import LinearRegression
from sklearn.cluster import KMeans
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score

# Helper untuk mendapatkan koneksi database
def get_db_connection():
    host = os.environ.get("DB_HOST", "db")
    port = os.environ.get("DB_PORT", "5432")
    user = os.environ.get("DB_USER", "postgres")
    password = os.environ.get("DB_PASSWORD", "postgres")
    database = os.environ.get("DB_NAME", "smartshoe_db")
    
    return psycopg2.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        database=database
    )

def train_models_from_db(model_dir: str = "trained_model") -> dict:
    """Melatih ulang model Regresi Linier dan K-Means secara dinamis menggunakan data dari database."""
    print("[RETRAINING] Memulai proses penarikan data dari database PostgreSQL...")
    
    conn = None
    try:
        conn = get_db_connection()
    except Exception as e:
        print(f"[RETRAINING] ERROR: Gagal terhubung ke database: {str(e)}")
        return {"success": False, "error": f"Koneksi DB gagal: {str(e)}"}
        
    try:
        # A. TRAINING PIPELINE 1: ESTIMASI WAKTU PENGERINGAN (REGRESSION)
        # =====================================================================
        # Dinonaktifkan karena menggunakan rumus matematika logis (heuristik)
        regression_metrics = {
            "status": "disabled",
            "reason": "Menggunakan estimasi berbasis rumus matematika di predictor.py"
        }
        print("[RETRAINING] Regresi dinonaktifkan (menggunakan rumus matematika logis).")

        # B. TRAINING PIPELINE 2: DETEKTOR BAU (RANDOM FOREST)
        # =====================================================================
        print("[RETRAINING] Mengambil riwayat sensor untuk detektor bau...")
        query_smell = "SELECT gas_level as gas_mq135, humidity as kelembapan_sekarang, temperature as suhu FROM sensor_logs"
        df_smell = pd.read_sql(query_smell, conn)
        
        if len(df_smell) < 10:
            print(f"[RETRAINING] Data tabel untuk Random Forest terlalu sedikit ({len(df_smell)} baris). Melewati Random Forest.")
            smell_metrics = {"status": "skipped", "reason": "Data kurang dari 10 baris"}
        else:
            print(f"[RETRAINING] Memproses {len(df_smell)} baris data Random Forest...")
            
            # 1. Membersihkan anomali semprotan parfum (gas_level > 180 ppm) jika ada
            df_smell = df_smell[df_smell['gas_mq135'] <= 180.0].reset_index(drop=True)
            
            # Rename kolom agar persis seperti training Google Sheets
            df_smell = df_smell.rename(columns={
                'suhu': 'temperature',
                'kelembapan_sekarang': 'humidity',
                'gas_mq135': 'gas_level'
            })
            
            # 2. Pelabelan berdasarkan Aturan Batas Sensor (Rule-based Labeling)
            conds = [
                df_smell['gas_level'] <= 158.0,
                (df_smell['gas_level'] > 165.0) | (df_smell['humidity'] > 80.0)
            ]
            choices = [0, 2] # 0: Tidak Bau, 2: Sangat Bau
            df_smell['kategori_bau'] = np.select(conds, choices, default=1) # 1: Bau Sedang
            
            X_smell = df_smell[['temperature', 'humidity', 'gas_level']]
            y_smell = df_smell['kategori_bau']
            
            # Standarisasi fitur menggunakan StandardScaler (seperti di skrip user)
            from sklearn.preprocessing import StandardScaler
            from sklearn.ensemble import RandomForestClassifier
            
            scaler_smell = StandardScaler()
            X_smell_scaled = scaler_smell.fit_transform(X_smell)
            
            # Melatih Model Random Forest
            model_rf = RandomForestClassifier(random_state=42)
            model_rf.fit(X_smell_scaled, y_smell)
            
            # Simpan model & scaler ke trained_model/
            out_path = Path(model_dir)
            out_path.mkdir(exist_ok=True)
            joblib.dump(model_rf, out_path / "smell_model.joblib")
            joblib.dump(scaler_smell, out_path / "smell_scaler.joblib")
            
            smell_metrics = {
                "status": "success",
                "row_count": len(df_smell),
                "model_type": "RandomForestClassifier"
            }
            print(f"[RETRAINING] Model Random Forest sukses diperbarui!")

        return {
            "success": True,
            "regression_metrics": regression_metrics,
            "smell_metrics": smell_metrics
        }
        
    except Exception as e:
        print(f"[RETRAINING] ERROR: Gagal memproses pelatihan model: {str(e)}")
        return {"success": False, "error": str(e)}
        
    finally:
        if conn:
            conn.close()
            print("[RETRAINING] Koneksi database ditutup.")
