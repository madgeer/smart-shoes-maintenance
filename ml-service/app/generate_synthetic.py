import os
import random
import datetime
import psycopg2

def get_db_connection():
    host = os.environ.get("DB_HOST", "db")
    port = os.environ.get("DB_PORT", "5432")
    user = os.environ.get("DB_USER", "postgres")
    password = os.environ.get("DB_PASSWORD", "postgres")
    database = os.environ.get("DB_NAME", "smartshoe_db")
    
    return psycopg2.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        database=database
    )

def main():
    print("[SYNTHETIC-GEN] Menghubungkan ke database PostgreSQL...")
    conn = get_db_connection()
    cur = conn.cursor()
    
    # 1. Pastikan ada user, device, dan shoe
    cur.execute("SELECT id FROM users LIMIT 1;")
    user_row = cur.fetchone()
    if not user_row:
        cur.execute(
            "INSERT INTO users (name, email, password) VALUES (%s, %s, %s) RETURNING id;",
            ("Default User", "user@smartshoe.local", "hashed_password")
        )
        user_id = cur.fetchone()[0]
    else:
        user_id = user_row[0]
        
    cur.execute("SELECT id FROM devices LIMIT 1;")
    device_row = cur.fetchone()
    if not device_row:
        cur.execute(
            "INSERT INTO devices (user_id, device_name, device_code, status) VALUES (%s, %s, %s, %s) RETURNING id;",
            (user_id, "ESP32 Shoe Box", "ESP32-SHOE-001", "active")
        )
        device_id = cur.fetchone()[0]
    else:
        device_id = device_row[0]
        
    cur.execute("SELECT id FROM shoes LIMIT 1;")
    shoe_row = cur.fetchone()
    if not shoe_row:
        cur.execute(
            "INSERT INTO shoes (user_id, shoe_name, shoe_type, shoe_material) VALUES (%s, %s, %s, %s) RETURNING id;",
            (user_id, "Nike Mesh Runner", "Running", "Mesh")
        )
        shoe_id = cur.fetchone()[0]
    else:
        shoe_id = shoe_row[0]

    # 2. Bersihkan sensor_logs lama agar datanya bersih
    print("[SYNTHETIC-GEN] Mengosongkan tabel sensor_logs lama...")
    cur.execute("TRUNCATE TABLE sensor_logs CASCADE;")
    conn.commit()

    # 3. Generate data simulasi
    print("[SYNTHETIC-GEN] Memulai pembuatan 1000 data log sensor...")
    
    # Parameter simulasi
    num_cycles = 5
    points_per_cycle = 200 # Total 1000 data points
    start_time = datetime.datetime.now() - datetime.timedelta(days=2)
    time_step = datetime.timedelta(seconds=10)
    
    logs_inserted = 0
    current_time = start_time
    
    for cycle in range(num_cycles):
        print(f"   - Membuat Siklus Pengeringan #{cycle + 1}...")
        for step in range(points_per_cycle):
            # Fase 1: Basah/Dingin (40 data pertama)
            if step < 40:
                temp = 25.0 + random.uniform(-0.5, 0.5)
                humidity = 80.0 + random.uniform(-2.0, 2.0)
                gas = 165.0 + random.uniform(-4.0, 4.0)
                duration = 0.0
                fan_dur = 0.0
                uv_dur = 0.0
            
            # Fase 2: Pengeringan Aktif / Pemanasan (120 data berikutnya)
            elif step < 160:
                t = (step - 40) / 120.0 # progress 0.0 s.d. 1.0
                # Suhu naik dari 25 ke 47 derajat Celcius
                temp = 25.0 + 22.0 * t + random.uniform(-1.0, 1.0)
                # Kelembapan turun dari 80% ke 30% RH
                humidity = 80.0 - 50.0 * t + random.uniform(-1.5, 1.5)
                # Gas turun sedikit karena udara mengalir
                gas = 165.0 - 35.0 * t + random.uniform(-3.0, 3.0)
                duration = t * 0.5 # simulasi 30 menit
                fan_dur = t * 0.5
                uv_dur = t * 0.1
                
            # Fase 3: Kering / Pasca-Pemanasan (40 data terakhir)
            else:
                t = (step - 160) / 40.0 # progress 0.0 s.d. 1.0
                # Suhu turun kembali mendekati suhu ruang
                temp = 47.0 - 18.0 * t + random.uniform(-0.8, 0.8)
                # Kelembapan stabil/rendah di sekitar 30%
                humidity = 30.0 + random.uniform(-1.0, 1.0)
                # Gas stabil di baseline bersih
                gas = 130.0 + random.uniform(-2.0, 2.0)
                duration = 0.5
                fan_dur = 0.5
                uv_dur = 0.1
            
            # Batasi nilai kelembapan agar logis (0-100)
            humidity = max(0.0, min(100.0, humidity))
            
            # Insert ke database
            cur.execute(
                """
                INSERT INTO sensor_logs 
                (shoe_id, device_id, temperature, humidity, gas_level, duration_usage, fan_usage_duration, uv_usage_duration, created_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);
                """,
                (shoe_id, device_id, temp, humidity, gas, duration, fan_dur, uv_dur, current_time)
            )
            
            current_time += time_step
            logs_inserted += 1
            
    conn.commit()
    cur.close()
    conn.close()
    print(f"[SYNTHETIC-GEN] BERHASIL! Sukses mengimpor {logs_inserted} data sensor realistik ke database.")

if __name__ == "__main__":
    main()
