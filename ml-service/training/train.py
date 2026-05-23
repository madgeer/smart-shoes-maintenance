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
    """Melatih K-Means untuk mendeteksi bau sepatu secara 'buta' & memetakan klaster."""
    print(">>> Melatih Model Detektor Bau (K-Means Clustering)...")
    
    # Mempersiapkan path
    dataset_path = Path("dataset/shoe_sensor.csv")
    
    # Preprocessing
    X_scaled, scaler = preprocess_smell_data(str(dataset_path))
    
    # Fit Model
    kmeans = KMeans(n_clusters=3, random_state=42, n_init=10)
    kmeans.fit(X_scaled)
    
    # Hitung Jarak Euclidean dari Centroid ke Origin (0,0)
    centroids = kmeans.cluster_centers_
    distances = [float(np.sqrt(c[0]**2 + c[1]**2)) for c in centroids]
    
    print("    [Centroids] setelah Latihan:")
    for idx, (c, dist) in enumerate(zip(centroids, distances)):
        print(f"      - Klaster {idx}: Gas={c[0]:.4f}, Kelembapan={c[1]:.4f} | Jarak={dist:.4f}")
        
    # Urutkan klaster: Terdekat -> Wangi (0), Sedang -> Normal (1), Terjauh -> Bau (2)
    sorted_indices = np.argsort(distances)
    cluster_mapping = {
        int(sorted_indices[0]): 0,
        int(sorted_indices[1]): 1,
        int(sorted_indices[2]): 2
    }
    
    print("    [Mapping] Hasil Jarak Euclidean:")
    print(f"      - Klaster {sorted_indices[0]} (Terdekat) -> Wangi (0)")
    print(f"      - Klaster {sorted_indices[1]} (Sedang)   -> Normal (1)")
    print(f"      - Klaster {sorted_indices[2]} (Terjauh)  -> Bau (2)")
    print(f"      - Dict: {cluster_mapping}")
    
    # Menyimpan Paket Model & Scaler
    smell_package = {
        'model': kmeans,
        'cluster_mapping': cluster_mapping,
        'scaler': scaler
    }
    
    output_dir = Path("trained_model")
    output_dir.mkdir(exist_ok=True)
    
    joblib.dump(smell_package, output_dir / "smell_model.joblib")
    joblib.dump(scaler, output_dir / "smell_scaler.joblib")
    print(f"    [INFO] Model & Scaler Bau berhasil disimpan di: {output_dir}\n")


if __name__ == "__main__":
    train_drying_time_estimator()
    train_smell_detector()
    print(">>> Proses pelatihan selesai dengan sukses!")
