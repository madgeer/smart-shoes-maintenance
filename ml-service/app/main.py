import os
import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware

from app.models.schemas import (
    MaintenanceRequest,
    MaintenanceResponse,
    DrynessRequest,
    DrynessResponse,
)
from app.services.predictor import PredictorService
from app.services.trainer import train_models_from_db
from app.services.scheduler import run_scheduler

# Global predictor instance
predictor: PredictorService = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Mengelola siklus hidup (lifespan) aplikasi FastAPI."""
    global predictor

    # Menentukan path absolut folder trained_model
    base_dir = os.path.dirname(os.path.abspath(__file__))
    model_dir = os.path.abspath(os.path.join(base_dir, "..", "trained_model"))

    # Verifikasi kelengkapan file model sebelum meluncurkan server
    required_files = [
        "dryness_model.joblib",
        "dryness_scaler.joblib",
    ]
    missing_files = [
        f for f in required_files if not os.path.exists(os.path.join(model_dir, f))
    ]

    if missing_files:
        print(f"[VERIFIKASI] File model tidak lengkap di {model_dir}: {missing_files}")
    else:
        try:
            predictor = PredictorService(model_dir=model_dir)
            print(f"[SUKSES] Semua model ML berhasil dimuat dari {model_dir}")
        except Exception as e:
            print(f"[ERROR] Gagal memuat model ML: {str(e)}")

    # Aktifkan scheduler retraining otomatis di latar belakang secara non-blocking
    if predictor is not None:
        asyncio.create_task(run_scheduler(predictor, model_dir=model_dir))
        print("[LIFESPAN] Scheduler retraining otomatis di latar belakang diaktifkan!")

    yield
    print("[INFO] Server FastAPI dihentikan.")


app = FastAPI(
    title="Smart Shoes Maintenance ML API",
    description="API Machine Learning untuk estimasi pengeringan sepatu (Heuristik) & klasifikasi status kekeringan (Decision Tree).",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS Middleware - Izinkan semua origin untuk akses IoT Hardware / Gateway
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", tags=["Health"])
async def health_check():
    """Memeriksa kesehatan server dan status kesiapan model ML."""
    if predictor is None:
        return {"status": "unhealthy", "message": "Model ML belum berhasil dimuat."}
    return {"status": "healthy", "message": "Server dan model ML siap!"}


@app.post(
    "/predict/maintenance",
    response_model=MaintenanceResponse,
    tags=["Predictions"],
)
async def predict_maintenance(request: MaintenanceRequest):
    """Memprediksi sisa waktu pengeringan sepatu (menit) berdasarkan data sensor."""
    if predictor is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Layanan prediksi belum siap. Model ML tidak ditemukan.",
        )

    # Validasi logika fisik input
    if request.kelembapan_sekarang > request.kelembapan_awal:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Kelembapan saat ini tidak boleh lebih besar dari kelembapan awal.",
        )

    try:
        sisa_waktu, status_desc = predictor.predict_drying_time(
            kelembapan_awal=request.kelembapan_awal,
            kelembapan_sekarang=request.kelembapan_sekarang,
            suhu=request.suhu,
            jenis_bahan=request.jenis_bahan,
            sensor_bau=request.sensor_bau,
        )
        return MaintenanceResponse(sisa_waktu_menit=sisa_waktu, status=status_desc)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Terjadi kesalahan saat memprediksi waktu pengeringan: {str(e)}",
        )


@app.post(
    "/predict/dryness",
    response_model=DrynessResponse,
    tags=["Predictions"],
)
async def predict_dryness(request: DrynessRequest):
    """Mengklasifikasikan status kekeringan sepatu (Kering, Lembap, Basah) menggunakan Decision Tree Classifier."""
    if predictor is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Layanan prediksi belum siap. Model ML tidak ditemukan.",
        )

    try:
        klaster_asli, label, kategori, gas_norm, moist_norm = (
            predictor.predict_dryness_level(
                gas_mq135=request.gas_mq135,
                kelembapan_sekarang=request.kelembapan_sekarang,
                suhu=request.suhu,
            )
        )
        return DrynessResponse(
            klaster_asli=klaster_asli,
            label=label,
            kategori=kategori,
            gas_mq135_normalisasi=gas_norm,
            kelembapan_normalisasi=moist_norm,
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Terjadi kesalahan saat memprediksi tingkat kekeringan: {str(e)}",
        )


@app.post(
    "/train/trigger",
    tags=["Retraining"],
)
async def trigger_retraining():
    """Memicu pelatihan ulang model secara manual berbasis data PostgreSQL aktif."""
    base_dir = os.path.dirname(os.path.abspath(__file__))
    model_dir = os.path.abspath(os.path.join(base_dir, "..", "trained_model"))
    
    # 1. Jalankan training pipeline dari DB
    result = train_models_from_db(model_dir=model_dir)
    
    if not result.get("success"):
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Gagal melatih ulang model: {result.get('error')}",
        )
        
    dryness_metrics = result.get("dryness_metrics", {})
    
    # 2. Reload model secara dinamis jika model sukses dilatih ulang
    if dryness_metrics.get("status") == "success":
        if predictor is not None:
            predictor.reload_models(model_dir=model_dir)
            return {
                "success": True,
                "message": "Pelatihan ulang model selesai dan model baru berhasil di-reload secara dinamis tanpa downtime!",
                "dryness_metrics": dryness_metrics
            }
        else:
            return {
                "success": True,
                "message": "Pelatihan ulang model selesai, tetapi server predictor belum siap untuk me-reload.",
                "dryness_metrics": dryness_metrics
            }
    else:
        return {
            "success": True,
            "message": "Proses pelatihan selesai dilewati karena baris data di database masih terlalu sedikit (minimal 10 baris). Model lama tetap aktif.",
            "dryness_metrics": dryness_metrics
        }