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
        query_smell = "SELECT humidity as kelembapan_sekarang, temperature as suhu FROM sensor_logs"
        df_smell = pd.read_sql(query_smell, conn)
        
        if len(df_smell) < 10:
            print(f"[RETRAINING] Data tabel untuk Decision Tree terlalu sedikit ({len(df_smell)} baris). Melewati pelatihan.")
            smell_metrics = {"status": "skipped", "reason": "Data kurang dari 10 baris"}
        else:
            print(f"[RETRAINING] Memproses {len(df_smell)} baris data untuk Decision Tree...")
            
            # Rename kolom
            df_smell = df_smell.rename(columns={
                'suhu': 'temperature',
                'kelembapan_sekarang': 'humidity'
            })
            
            # Pelabelan berdasarkan Aturan Batas Kelembapan (Rule-based Labeling)
            # Kelas 0: Kering (< 40.0% RH), Kelas 1: Lembap (40.0% - 70.0% RH), Kelas 2: Basah (> 70.0% RH)
            conds = [
                df_smell['humidity'] <= 40.0,
                df_smell['humidity'] > 70.0
            ]
            choices = [0, 2]
            df_smell['drying_status'] = np.select(conds, choices, default=1)
            
            X_smell = df_smell[['temperature', 'humidity']]
            y_smell = df_smell['drying_status']
            
            # Standarisasi fitur
            scaler_smell = StandardScaler()
            X_smell_scaled = scaler_smell.fit_transform(X_smell)
            
            # Melatih Model Decision Tree dengan kedalaman maksimal agar mudah divisualisasikan
            model_dt = DecisionTreeClassifier(max_depth=3, random_state=42)
            model_dt.fit(X_smell_scaled, y_smell)
            
            # Simpan model & scaler ke trained_model/
            out_path = Path(model_dir)
            out_path.mkdir(exist_ok=True)
            joblib.dump(model_dt, out_path / "smell_model.joblib")
            joblib.dump(scaler_smell, out_path / "smell_scaler.joblib")
            
            smell_metrics = {
                "status": "success",
                "row_count": len(df_smell),
                "model_type": "DecisionTreeClassifier"
            }
            print(f"[RETRAINING] Model Decision Tree sukses diperbarui!")
 
        return {
            "success": True,
            "smell_metrics": smell_metrics
        }
        
    except Exception as e:
        print(f"[RETRAINING] ERROR: Gagal memproses pelatihan model: {str(e)}")
        return {
            "success": False, 
            "error": str(e),
            "smell_metrics": {"status": "failed", "reason": str(e)}
        }
        
    finally:
        if conn:
            conn.close()
            print("[RETRAINING] Koneksi database ditutup.")
