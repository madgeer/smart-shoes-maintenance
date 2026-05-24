from typing import Tuple
from pathlib import Path
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler

def preprocess_maintenance_data(
    filepath: str | Path
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, MinMaxScaler]:
    """Memuat, membagi, dan menormalisasi dataset estimator waktu pengeringan sepatu.

    Args:
        filepath (str | Path): Path file CSV dataset maintenance.

    Returns:
        Tuple: (X_train_scaled, X_test_scaled, y_train, y_test, scaler)
    """
    # Memastikan path dalam format string untuk kompatibilitas pandas
    df = pd.read_csv(str(filepath))
    
    # Lakukan One-Hot Encoding untuk kolom kategorikal 'jenis_bahan'
    df['bahan_kanvas'] = (df['jenis_bahan'] == 1).astype(float)
    df['bahan_kulit'] = (df['jenis_bahan'] == 2).astype(float)
    df['bahan_mesh'] = (df['jenis_bahan'] == 3).astype(float)
    
    # Pisahkan Fitur (X) dan Target (Y)
    feature_cols = [
        'kelembapan_awal',
        'kelembapan_sekarang',
        'suhu',
        'sensor_bau',
        'bahan_kanvas',
        'bahan_kulit',
        'bahan_mesh'
    ]
    X = df[feature_cols].to_numpy()
    y = df['sisa_waktu'].to_numpy()
    
    # Split Train (80%) & Test (20%)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Fit & Transform MinMaxScaler
    scaler = MinMaxScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    return X_train_scaled, X_test_scaled, y_train, y_test, scaler

def preprocess_smell_data(filepath: str | Path) -> Tuple[np.ndarray, MinMaxScaler]:
    """Memuat dan menormalisasi dataset bau sepatu untuk model K-Means.

    Args:
        filepath (str | Path): Path file CSV dataset bau sepatu.

    Returns:
        Tuple: (X_scaled, scaler)
    """
    df = pd.read_csv(str(filepath))
    
    # K-Means hanya membutuhkan fitur sensor tanpa target label
    X = df[['gas_mq135', 'kelembapan_sekarang']].to_numpy()
    
    # Fit & Transform MinMaxScaler
    scaler = MinMaxScaler()
    X_scaled = scaler.fit_transform(X)
    
    return X_scaled, scaler
