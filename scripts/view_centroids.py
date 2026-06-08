# =========================================================================
# SMART SHOES MAINTENANCE - ML DECISION TREE VIEWER UTILITY
# File: view_centroids.py (Overwritten to view Decision Tree splits)
# =========================================================================

import os
import joblib
import numpy as np

# Path ke model trained
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
model_path = os.path.join(base_dir, "ml-service", "trained_model", "smell_model.joblib")
scaler_path = os.path.join(base_dir, "ml-service", "trained_model", "smell_scaler.joblib")

if not os.path.exists(model_path) or not os.path.exists(scaler_path):
    print("=========================================================")
    print(" [ERROR] File model Decision Tree atau Scaler tidak ditemukan!")
    print(f" Path Model : {model_path}")
    print(f" Path Scaler: {scaler_path}")
    print(" Pastikan model sudah dilatih.")
    print("=========================================================")
    exit(1)

try:
    model = joblib.load(model_path)
    scaler = joblib.load(scaler_path)
    
    print("\n========================================================")
    print("   STRUKTUR LOGIKA POHON KEPUTUSAN (DECISION TREE) AKTIF")
    print("========================================================")
    
    # Rata-rata dan standar deviasi dari scaler untuk mengembalikan standarisasi fitur
    means = scaler.mean_
    stds = np.sqrt(scaler.var_)
    
    tree = model.tree_
    
    def recurse(node, depth):
        indent = "  " * depth
        if tree.feature[node] != -2: # internal node
            feature_idx = tree.feature[node]
            feature_name = "Suhu" if feature_idx == 0 else "Kelembapan"
            unit = "°C" if feature_idx == 0 else "% RH"
            threshold_scaled = tree.threshold[node]
            
            # Balikkan standarisasi ke nilai fisik asli
            threshold_original = threshold_scaled * stds[feature_idx] + means[feature_idx]
            
            print(f"{indent}IF {feature_name} <= {threshold_original:.2f}{unit}:")
            recurse(tree.children_left[node], depth + 1)
            print(f"{indent}ELSE (IF {feature_name} > {threshold_original:.2f}{unit}):")
            recurse(tree.children_right[node], depth + 1)
        else: # leaf node
            # Kelas dengan jumlah suara terbanyak di daun ini
            class_idx = np.argmax(tree.value[node])
            class_names = {0: "KERING", 1: "LEMBAP", 2: "BASAH"}
            print(f"{indent}==> MAKA STATUS: {class_names.get(class_idx)}")
            
    recurse(0, 1)
    print("========================================================\n")

except Exception as e:
    print(f"[ERROR] Gagal memuat atau membaca data Decision Tree: {str(e)}")
