from pydantic import BaseModel, Field

class MaintenanceRequest(BaseModel):
    """Skema input untuk request estimasi waktu pengeringan sepatu."""

    kelembapan_awal: float = Field(
        ..., ge=30.0, le=90.0, description="Kelembapan awal sepatu (%)"
    )
    kelembapan_sekarang: float = Field(
        ..., ge=10.0, le=90.0, description="Kelembapan sepatu saat ini (%)"
    )
    suhu: float = Field(
        ..., ge=30.0, le=70.0, description="Suhu pemanas (°C)"
    )
    jenis_bahan: int = Field(
        ..., ge=1, le=3, description="Jenis bahan sepatu (1: Kanvas, 2: Kulit, 3: Mesh)"
    )
    sensor_bau: float = Field(
        ..., ge=100.0, le=1000.0, description="Kadar gas Amonia MQ-135 (ppm)"
    )
class MaintenanceResponse(BaseModel):
    """Skema output untuk response estimasi waktu pengeringan sepatu."""

    sisa_waktu_menit: float = Field(..., description="Sisa waktu pengeringan (menit)")
    status: str = Field(..., description="Status kelayakan kondisi pengeringan")

class SmellRequest(BaseModel):
    """Skema input untuk request deteksi bau sepatu dari sensor."""
    gas_mq135: float = Field(
        ..., ge=100.0, le=1000.0, description="Nilai mentah sensor gas MQ-135"
    )
    kelembapan_sekarang: float = Field(
        ..., ge=10.0, le=100.0, description="Nilai kelembapan sepatu saat ini (%)"
    )


class SmellResponse(BaseModel):
    """Skema output untuk response klasifikasi bau sepatu dari K-Means."""

    klaster_asli: int = Field(..., description="ID klaster asli dari K-Means")
    label: int = Field(..., description="Label tingkat bau terurut (0: Wangi, 1: Normal, 2: Bau)")
    kategori: str = Field(..., description="Kategori deskriptif tingkat bau")
    gas_mq135_normalisasi: float = Field(..., description="Nilai sensor gas ter-scaling [0-1]")
    kelembapan_normalisasi: float = Field(..., description="Nilai sensor kelembapan ter-scaling [0-1]")