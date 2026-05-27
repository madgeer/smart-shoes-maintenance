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
        print("[RETRAINING] Mengambil riwayat telemetri untuk estimasi waktu...")
        
        # Query sensor_logs gabung dengan shoes dan predictions
        query_maint = """
        SELECT 
          s.humidity as kelembapan_sekarang,
          s.temperature as suhu,
          s.gas_level as sensor_bau,
          sh.shoe_material as jenis_bahan_str,
          p.estimated_drying_time as sisa_waktu,
          s.created_at,
          s.shoe_id
        FROM sensor_logs s
        JOIN shoes sh ON s.shoe_id = sh.id
        JOIN predictions p ON p.sensor_log_id = s.id
        WHERE p.estimated_drying_time IS NOT NULL
        ORDER BY s.shoe_id, s.created_at ASC
        """
        df_maint = pd.read_sql(query_maint, conn)
        
        if len(df_maint) < 10:
            print(f"[RETRAINING] Data tabel untuk regresi terlalu sedikit ({len(df_maint)} baris). Melewati regresi.")
            regression_metrics = {"status": "skipped", "reason": "Data kurang dari 10 baris"}
        else:
            print(f"[RETRAINING] Memproses {len(df_maint)} baris data regresi...")
            
            # Pembagian sesi dinamis menggunakan Pandas (sesi baru jika beda waktu > 6 jam)
            df_maint['created_at'] = pd.to_datetime(df_maint['created_at'])
            df_maint['time_diff'] = df_maint.groupby('shoe_id')['created_at'].diff()
            df_maint['new_session'] = (df_maint['time_diff'] > pd.Timedelta(hours=6)) | (df_maint['time_diff'].isna())
            df_maint['session_id'] = df_maint.groupby('shoe_id')['new_session'].cumsum()
            
            # Menentukan kelembapan awal di setiap sesi
            df_maint['kelembapan_awal'] = df_maint.groupby(['shoe_id', 'session_id'])['kelembapan_sekarang'].transform('first')
            
            # Map jenis bahan ke integer (1: Kanvas, 2: Kulit, 3: Mesh)
            material_map = {'Kanvas': 1.0, 'Kulit': 2.0, 'Mesh': 3.0}
            df_maint['jenis_bahan'] = df_maint['jenis_bahan_str'].map(material_map).fillna(1.0)
            
            # One-Hot Encoding fitur bahan
            df_maint['bahan_kanvas'] = (df_maint['jenis_bahan'] == 1.0).astype(float)
            df_maint['bahan_kulit'] = (df_maint['jenis_bahan'] == 2.0).astype(float)
            df_maint['bahan_mesh'] = (df_maint['jenis_bahan'] == 3.0).astype(float)
            
            feature_cols = [
                'kelembapan_awal',
                'kelembapan_sekarang',
                'suhu',
                'sensor_bau',
                'bahan_kanvas',
                'bahan_kulit',
                'bahan_mesh'
            ]
            
            X = df_maint[feature_cols].to_numpy()
            y = df_maint['sisa_waktu'].to_numpy()
            
            # Split & Fit Scaler
            X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
            scaler_maint = MinMaxScaler()
            X_train_scaled = scaler_maint.fit_transform(X_train)
            X_test_scaled = scaler_maint.transform(X_test)
            
            # Training Model Regresi
            model_maint = LinearRegression()
            model_maint.fit(X_train_scaled, y_train)
            
            # Evaluasi
            y_pred = model_maint.predict(X_test_scaled)
            mse = mean_squared_error(y_test, y_pred)
            r2 = r2_score(y_test, y_pred)
            
            # Simpan berkas regresi
            out_path = Path(model_dir)
            out_path.mkdir(exist_ok=True)
            joblib.dump(model_maint, out_path / "maintenance_model.joblib")
            joblib.dump(scaler_maint, out_path / "maintenance_scaler.joblib")
            
            regression_metrics = {
                "status": "success",
                "row_count": len(df_maint),
                "mse": float(mse),
                "r2_score": float(r2)
            }
            print(f"[RETRAINING] Model Regresi sukses diperbarui! MSE: {mse:.4f}, R2: {r2:.4f}")

        # B. TRAINING PIPELINE 2: DETEKTOR BAU (K-MEANS)
        # =====================================================================
        print("[RETRAINING] Mengambil riwayat sensor untuk detektor bau...")
        query_smell = "SELECT gas_level as gas_mq135, humidity as kelembapan_sekarang FROM sensor_logs"
        df_smell = pd.read_sql(query_smell, conn)
        
        if len(df_smell) < 10:
            print(f"[RETRAINING] Data tabel untuk K-Means terlalu sedikit ({len(df_smell)} baris). Melewati K-Means.")
            smell_metrics = {"status": "skipped", "reason": "Data kurang dari 10 baris"}
        else:
            print(f"[RETRAINING] Memproses {len(df_smell)} baris data K-Means...")
            X_smell = df_smell[['gas_mq135', 'kelembapan_sekarang']].to_numpy()
            
            # Fit Scaler
            scaler_smell = MinMaxScaler()
            X_smell_scaled = scaler_smell.fit_transform(X_smell)
            
            # Fit K-Means
            kmeans = KMeans(n_clusters=3, random_state=42, n_init=10)
            kmeans.fit(X_smell_scaled)
            
            # Urutkan Centroid berbasis jarak Euclidean ke origin (0,0) untuk melabeli secara fisik:
            # 0: Terdekat (Wangi), 1: Sedang (Normal), 2: Terjauh (Bau)
            centroids = kmeans.cluster_centers_
            distances = [float(np.sqrt(c[0]**2 + c[1]**2)) for c in centroids]
            sorted_indices = np.argsort(distances)
            cluster_mapping = {
                int(sorted_indices[0]): 0,
                int(sorted_indices[1]): 1,
                int(sorted_indices[2]): 2
            }
            
            # Simpan paket K-Means
            smell_package = {
                'model': kmeans,
                'cluster_mapping': cluster_mapping,
                'scaler': scaler_smell
            }
            
            out_path = Path(model_dir)
            out_path.mkdir(exist_ok=True)
            joblib.dump(smell_package, out_path / "smell_model.joblib")
            joblib.dump(scaler_smell, out_path / "smell_scaler.joblib")
            
            smell_metrics = {
                "status": "success",
                "row_count": len(df_smell),
                "cluster_mapping": cluster_mapping
            }
            print(f"[RETRAINING] Model K-Means sukses diperbarui! Mapping: {cluster_mapping}")

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
