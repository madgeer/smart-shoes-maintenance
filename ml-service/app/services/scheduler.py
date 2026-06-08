import asyncio
import os
from app.services.trainer import train_models_from_db
from app.services.predictor import PredictorService

# Interval retrain default: 7 hari (dalam detik)
DEFAULT_INTERVAL_SECONDS = 60 * 60 * 24 * 7

async def run_scheduler(predictor: PredictorService, model_dir: str = "trained_model") -> None:
    """Fungsi scheduler asinkron latar belakang untuk melatih ulang model secara berkala."""
    
    # Ambil interval dari environment jika ada (memungkinkan penyesuaian cepat saat testing)
    interval_str = os.environ.get("RETRAIN_INTERVAL_SECONDS")
    if interval_str:
        try:
            interval = int(interval_str)
            print(f"[SCHEDULER] Menggunakan interval kustom dari env: {interval} detik.")
        except ValueError:
            interval = DEFAULT_INTERVAL_SECONDS
    else:
        interval = DEFAULT_INTERVAL_SECONDS
        
    print(f"[SCHEDULER] Memulai penjadwal latar belakang otomatis. Siklus retraining: setiap {interval} detik.")
    
    # Beri jeda awal 30 detik agar server FastAPI startup sempurna dan database siap
    await asyncio.sleep(30)
    
    while True:
        try:
            print("[SCHEDULER] Menjalankan siklus pelatihan ulang model otomatis...")
            
            # 1. Jalankan training pipeline dari DB
            result = train_models_from_db(model_dir=model_dir)
            
            # 2. Jika sukses melatih ulang, reload model secara dinamis tanpa downtime
            if result.get("success"):
                smell_metrics = result.get("smell_metrics", {})
                
                # Cek apakah model berhasil diperbarui
                if smell_metrics.get("status") == "success":
                    predictor.reload_models(model_dir=model_dir)
                    print("[SCHEDULER] Siklus retraining SUKSES. Model dinamis di-reload.")
                else:
                    print("[SCHEDULER] Siklus retraining selesai, namun data di DB masih sedikit. Model lama tetap aktif.")
            else:
                print(f"[SCHEDULER] Siklus retraining GAGAL: {result.get('error')}")
                
        except Exception as e:
            print(f"[SCHEDULER] Error tak terduga pada loop scheduler: {str(e)}")
            
        # Tidur hingga siklus berikutnya
        print(f"[SCHEDULER] Menunggu {interval} detik hingga siklus pelatihan berikutnya...")
        await asyncio.sleep(interval)
