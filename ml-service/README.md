# Smart Shoes Maintenance ML 

Proyek Machine Learning dan API untuk sistem perawatan sepatu sepatu pintar (*Smart Shoes*). Sistem ini mengintegrasikan sensor fisik untuk memprediksi **sisa waktu pengeringan sepatu** (Matematika Heuristik) dan **tingkat kekeringan sepatu** (Decision Tree Classifier).

---

## Struktur Proyek
```text
smart-shoes-maintenance-ml/
├── app/
│   ├── models/schemas.py      # Pydantic Schemas untuk request/response API
│   ├── services/predictor.py  # Layanan inferensi loading model & prediksi
│   └── main.py                # Aplikasi Web FastAPI & CORS
├── dataset/                   # Dataset sensor (CSV)
├── tests/                     # Unit testing API dengan Pytest
├── trained_model/             # File model ML (.joblib) hasil pelatihan
├── training/                  # Kode preprocessing data & skrip pelatihan model
├── .gitignore
├── requirements.txt
└── README.md
```

---

## Cara Instalasi & Menjalankan

### 1. Kloning & Persiapan Virtual Environment
Pastikan Anda berada di direktori proyek dan aktifkan virtual environment Anda:
```powershell
# Buat Virtual Environment jika belum ada
python -m venv .venv

# Aktifkan di Windows PowerShell
.venv\Scripts\Activate.ps1
```

### 2. Instalasi Dependensi
Instal semua pustaka Python yang diperlukan:
```powershell
pip install -r requirements.txt
pip install pytest httpx
```

### 3. Menjalankan Unit Testing
Untuk memastikan seluruh logika API & inferensi model berfungsi 100% aman:
```powershell
.venv\Scripts\python -m pytest
```

### 4. Menjalankan Web Server API (FastAPI)
Nyalakan server lokal untuk mulai menerima data sensor:
```powershell
.venv\Scripts\python -m uvicorn app.main:app --reload
```
*   **Aplikasi Berjalan di:** `http://127.0.0.1:8000`
*   **Dokumentasi Swagger UI (Interaktif):** Buka browser Anda ke `http://127.0.0.1:8000/docs`

---

## Fitur Machine Learning
1.  **Estimator Waktu Pengeringan (Matematika Heuristik):** Menghitung estimasi sisa waktu pengeringan sepatu dalam menit secara dinamis berdasarkan jenis bahan sepatu (Mesh, Kanvas, Kulit) dan laju penguapan dinamis berbasis suhu box.
2.  **Detektor Kekeringan (Decision Tree Classifier):** Mengelompokkan tingkat kekeringan sepatu secara objektif ke dalam 3 level target tropis Indonesia (**Kering**, **Lembap**, **Basah**) berdasarkan sensor kelembapan saat ini menggunakan penggolongan Decision Tree Classifier 3-Node.
