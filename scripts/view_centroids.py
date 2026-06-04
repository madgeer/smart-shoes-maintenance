# =========================================================================
# SMART SHOES MAINTENANCE - ML CENTROID VIEWER UTILITY
# File: view_centroids.py
# =========================================================================

import os
import joblib
import numpy as np

# Path ke model trained
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
model_path = os.path.join(base_dir, "ml-service", "trained_model", "smell_model.joblib")

if not os.path.exists(model_path):
    print("=========================================================")
    print(" [ERROR] File model K-Means tidak ditemukan!")
    print(f" Path: {model_path}")
    print(" Pastikan kamu sudah menaruh file model atau melatih model.")
    print("=========================================================")
    exit(1)

try:
    # 1. Memuat paket model
    package = joblib.load(model_path)
    kmeans = package['model']
    cluster_mapping = package['cluster_mapping']
    scaler = package['scaler']

    # 2. Ambil centroid (titik tengah klaster) dalam skala normalisasi [0, 1]
    centroids_scaled = kmeans.cluster_centers_

    # 3. Kembalikan normalisasi ke nilai unit fisik asli menggunakan inverse_transform
    centroids_original = scaler.inverse_transform(centroids_scaled)

    # Invert mapping untuk mencari klaster asli berdasarkan label fisik
    # cluster_mapping berupa: {klaster_asli: label_fisik}
    inv_mapping = {v: k for k, v in cluster_mapping.items()}

    kategori_names = {
        0: "WANGI (Kering & Segar - Terdekat ke Origin)",
        1: "NORMAL (Kondisi Sedang)",
        2: "BAU (Lembap & Berbau - Terjauh dari Origin)"
    }

    print("\n=========================================================")
    print("   TITIK TENGAH (CENTROID) K-MEANS AKTIF PADA SISTEM ML  ")
    print("=========================================================")
    print(" Menampilkan batas acuan koordinat sensor fisik saat ini:")
    print("---------------------------------------------------------")

    for label_fisik in sorted(inv_mapping.keys()):
        klaster_asli = inv_mapping[label_fisik]
        
        # Ambil nilai koordinat sensor fisik asli
        gas_ppm = centroids_original[klaster_asli][0]
        humidity_percent = centroids_original[klaster_asli][1]
        
        # Ambil nilai koordinat normalisasi ter-scale [0, 1]
        gas_norm = centroids_scaled[klaster_asli][0]
        humidity_norm = centroids_scaled[klaster_asli][1]
        
        print(f" [+] Kategori: {kategori_names[label_fisik]}")
        print(f"    -> Kadar Gas MQ-135  : {gas_ppm:.2f} ppm (Skala Norm: {gas_norm:.4f})")
        print(f"    -> Kelembapan Udara   : {humidity_percent:.2f} %   (Skala Norm: {humidity_norm:.4f})")
        print("---------------------------------------------------------")
    print(" *Catatan: Batas ini akan bergeser otomatis saat retraining.")
    print("=========================================================\n")

except Exception as e:
    print(f"[ERROR] Gagal memuat atau membaca data centroid: {str(e)}")
