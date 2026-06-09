import os
from pathlib import Path
import joblib
import numpy as np
import pandas as pd
import psycopg2
from sklearn.preprocessing import StandardScaler
from sklearn.tree import DecisionTreeClassifier

def get_db_connection():
    """Mendapatkan koneksi ke database PostgreSQL."""
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
    """Melatih ulang model Decision Tree untuk klasifikasi tingkat kekeringan sepatu secara dinamis dari database."""
    print("[RETRAINING] Memulai proses penarikan data dari database PostgreSQL...")
    
    conn = None
    try:
        conn = get_db_connection()
    except Exception as e:
        print(f"[RETRAINING] ERROR: Gagal terhubung ke database: {str(e)}")
        return {"success": False, "error": f"Koneksi DB gagal: {str(e)}"}
        
    try:
        # 1. Mengambil riwayat sensor untuk detektor kekeringan (Suhu & Kelembapan)
        print("[RETRAINING] Mengambil riwayat sensor untuk detektor kekeringan...")
        query_dryness = "SELECT humidity as kelembapan_sekarang, temperature as suhu FROM sensor_logs"
        df_dryness = pd.read_sql(query_dryness, conn)
        
        if len(df_dryness) < 10:
            print(f"[RETRAINING] Data tabel untuk Decision Tree terlalu sedikit ({len(df_dryness)} baris). Melewati pelatihan.")
            dryness_metrics = {"status": "skipped", "reason": "Data kurang dari 10 baris"}
        else:
            print(f"[RETRAINING] Memproses {len(df_dryness)} baris data untuk Decision Tree...")
            
            # Rename kolom
            df_dryness = df_dryness.rename(columns={
                'suhu': 'temperature',
                'kelembapan_sekarang': 'humidity'
            })
            
            # Pelabelan berdasarkan Kelembapan (Humidity-only Labeling)
            # Kelas 0: Kering, Kelas 1: Lembap, Kelas 2: Basah
            conds = [
                df_dryness['humidity'] <= 30.0,
                df_dryness['humidity'] > 60.0
            ]
            choices = [0, 2]
            df_dryness['drying_status'] = np.select(conds, choices, default=1)
            
            X_dryness = df_dryness[['humidity']]
            y_dryness = df_dryness['drying_status']
            
            # Standarisasi fitur
            scaler_dryness = StandardScaler()
            X_dryness_scaled = scaler_dryness.fit_transform(X_dryness)
            
            # Melatih Model Decision Tree
            model_dt = DecisionTreeClassifier(max_depth=3, random_state=42)
            model_dt.fit(X_dryness_scaled, y_dryness)
            
            # Simpan model & scaler ke trained_model/
            out_path = Path(model_dir)
            out_path.mkdir(exist_ok=True)
            joblib.dump(model_dt, out_path / "dryness_model.joblib")
            joblib.dump(scaler_dryness, out_path / "dryness_scaler.joblib")
            
            dryness_metrics = {
                "status": "success",
                "row_count": len(df_dryness),
                "model_type": "DecisionTreeClassifier"
            }
            print(f"[RETRAINING] Model Decision Tree sukses diperbarui!")
 
        return {
            "success": True,
            "dryness_metrics": dryness_metrics
        }
        
    except Exception as e:
        print(f"[RETRAINING] ERROR: Gagal memproses pelatihan model: {str(e)}")
        return {
            "success": False, 
            "error": str(e),
            "dryness_metrics": {"status": "failed", "reason": str(e)}
        }
        
    finally:
        if conn:
            conn.close()
            print("[RETRAINING] Koneksi database ditutup.")
