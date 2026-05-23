import pytest
from fastapi.testclient import TestClient
from app.main import app

@pytest.fixture
def client():
    """Fixture untuk menyediakan TestClient yang memicu event startup & shutdown (lifespan)."""
    with TestClient(app) as c:
        yield c

def test_health_check(client) -> None:
    """Menguji endpoint /health untuk memastikan server sehat."""
    response = client.get("/health")
    assert response.status_code == 200
    json_data = response.json()
    assert json_data["status"] == "healthy"

def test_predict_maintenance_success(client) -> None:
    """Menguji estimasi waktu pengeringan dengan kondisi normal (happy path)."""
    payload = {
        "kelembapan_awal": 80.0,
        "kelembapan_sekarang": 30.0,
        "suhu": 45.0,
        "jenis_bahan": 1,
        "sensor_bau": 300.0
    }
    response = client.post("/predict/maintenance", json=payload)
    assert response.status_code == 200
    json_data = response.json()
    # Sisa waktu harus berupa angka desimal >= 0 dan ada keterangannya
    assert "sisa_waktu_menit" in json_data
    assert json_data["sisa_waktu_menit"] >= 0.0
    assert "status" in json_data


def test_predict_maintenance_validation_error(client) -> None:
    """Menguji apakah API menolak input kelembapan sekarang > kelembapan awal (HTTP 400)."""
    payload = {
        "kelembapan_awal": 50.0,
        "kelembapan_sekarang": 70.0,  # Tidak logis: sekarang > awal
        "suhu": 45.0,
        "jenis_bahan": 1,
        "sensor_bau": 300.0
    }
    response = client.post("/predict/maintenance", json=payload)
    assert response.status_code == 400
    json_data = response.json()
    assert "tidak boleh lebih besar" in json_data["detail"]

def test_predict_smell_wangi(client) -> None:
    """Menguji sensor gas & kelembapan rendah (harus diklasifikasi sebagai Wangi)."""
    payload = {
        "gas_mq135": 150.0,
        "kelembapan_sekarang": 25.0
    }
    response = client.post("/predict/smell", json=payload)
    assert response.status_code == 200
    json_data = response.json()
    assert json_data["kategori"] == "Wangi"
    assert json_data["label"] == 0

def test_predict_smell_bau(client) -> None:
    """Menguji sensor gas & kelembapan tinggi pekat (harus diklasifikasi sebagai Bau)."""
    payload = {
        "gas_mq135": 850.0,
        "kelembapan_sekarang": 85.0
    }
    response = client.post("/predict/smell", json=payload)
    assert response.status_code == 200
    json_data = response.json()
    assert json_data["kategori"] == "Bau"
    assert json_data["label"] == 2