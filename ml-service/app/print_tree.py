import os
import joblib
import numpy as np

def main():
    model_path = "trained_model/dryness_model.joblib"
    scaler_path = "trained_model/dryness_scaler.joblib"
    
    if not os.path.exists(model_path) or not os.path.exists(scaler_path):
        print("Model atau scaler tidak ditemukan.")
        return
        
    model = joblib.load(model_path)
    scaler = joblib.load(scaler_path)
    
    print("\n=== STRUKTUR LOGIKA POHON KEPUTUSAN (DECISION TREE) ===")
    
    # Rata-rata dan standar deviasi dari scaler
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
            
            print(f"{indent}IF {feature_name} <= {threshold_original:.1f}{unit}:")
            recurse(tree.children_left[node], depth + 1)
            print(f"{indent}ELSE (IF {feature_name} > {threshold_original:.1f}{unit}):")
            recurse(tree.children_right[node], depth + 1)
        else: # leaf node
            # Kelas dengan jumlah suara terbanyak di daun ini
            class_idx = np.argmax(tree.value[node])
            class_names = {0: "KERING", 1: "LEMBAP", 2: "BASAH"}
            print(f"{indent}==> MAKA STATUS: {class_names.get(class_idx)}")
            
    recurse(0, 1)
    print("======================================================\n")

if __name__ == "__main__":
    main()
