-- =========================================================================
-- SMART SHOES MAINTENANCE - DATABASE SEED DATA (MOCK DATA FOR TESTING)
-- =========================================================================

-- Bersihkan data lama jika ada (opsional untuk re-seeding)
TRUNCATE TABLE maintenance_logs, notifications, predictions, sensor_logs, shoes, devices, users RESTART IDENTITY CASCADE;

-- 1. Insert Mock Users
-- Password hash untuk 'password123' menggunakan bcrypt
INSERT INTO users (name, email, password, created_at)
VALUES (
    'John Doe', 
    'johndoe@example.com', 
    '$2a$10$cJxOnevDl7myk4UuNz9aQutHmw6iPzTUFly/QZqbgrGqzpHGC67H6', -- Hashed 'password123'
    NOW() - INTERVAL '7 days'
);

-- 2. Insert Mock Devices
INSERT INTO devices (user_id, device_name, device_code, status, created_at)
VALUES (
    1, -- Referensi ke John Doe
    'Pengering Kamar Utama', 
    'ESP32-SHOE-001', 
    'active', 
    NOW() - INTERVAL '5 days'
);

-- 3. Insert Mock Shoes for John Doe
INSERT INTO shoes (user_id, shoe_name, shoe_type, shoe_material, created_at)
VALUES 
(1, 'Nike Air Max Blue', 'Running', 'Mesh', NOW() - INTERVAL '4 days'),
(1, 'Adidas Samba Black', 'Casual', 'Kanvas', NOW() - INTERVAL '4 days'),
(1, 'Prada Derby Leather', 'Formal', 'Kulit', NOW() - INTERVAL '4 days');

-- 4. Insert Mock Notifications for John Doe
INSERT INTO notifications (user_id, title, message, notification_type, is_read, created_at)
VALUES 
(
    1, 
    'Perangkat Berhasil Terhubung', 
    'Perangkat Pengering Kamar Utama (ESP32-SHOE-001) sekarang berstatus online dan terhubung ke akun Anda.', 
    'INFO', 
    true, 
    NOW() - INTERVAL '24 hours'
),
(
    1, 
    'Peringatan Sepatu Sangat Basah', 
    'Sepatu Nike Air Max Blue terdeteksi sangat lembap (Kelembapan 85%). Kipas dan Heater otomatis dinyalakan.', 
    'WARNING', 
    false, 
    NOW() - INTERVAL '2 hours'
),
(
    1, 
    'Proses Pengeringan Selesai', 
    'Sepatu Nike Air Max Blue telah kering optimal secara otomatis! Heater dan UV telah dimatikan.', 
    'INFO', 
    false, 
    NOW() - INTERVAL '10 minutes'
);

-- 5. Insert Mock Maintenance Logs for Device
INSERT INTO maintenance_logs (device_id, component_name, issue, action_taken, maintenance_date)
VALUES (
    1, 
    'UV Lamp & Blower Fan', 
    'Akumulasi debu tebal pada kipas peniup dan sensor sinar UV', 
    'Pembersihan manual baling-baling blower dan sterilisasi kaca pelindung lampu UV', 
    NOW() - INTERVAL '3 days'
);

-- 6. Insert Mock Sensor Logs & Predictions (Simulasi Sesi Pengeringan 2 Jam)
-- Kita simulasikan log sensor bertahap dari basah/bau hingga kering/wangi

-- Data Sensor Log 1: Mulai Pengeringan (Kondisi Basah & Bau Parah)
INSERT INTO sensor_logs (shoe_id, device_id, temperature, humidity, gas_level, duration_usage, fan_usage_duration, uv_usage_duration, created_at)
VALUES (1, 1, 26.5, 85.0, 750.0, 0.05, 0.05, 0.05, NOW() - INTERVAL '2 hours');

INSERT INTO predictions (sensor_log_id, prediction_label, confidence_score, estimated_drying_time, drying_status, created_at)
VALUES (1, 'Bau', NULL, 45.0, 'Sedang dikeringkan (Kondisi sepatu masih sangat basah)', NOW() - INTERVAL '2 hours');


-- Data Sensor Log 2: Setelah 20 Menit (Suhu meningkat, kelembapan mulai turun)
INSERT INTO sensor_logs (shoe_id, device_id, temperature, humidity, gas_level, duration_usage, fan_usage_duration, uv_usage_duration, created_at)
VALUES (1, 1, 35.0, 72.0, 620.0, 0.38, 0.38, 0.38, NOW() - INTERVAL '1 hour 40 minutes');

INSERT INTO predictions (sensor_log_id, prediction_label, confidence_score, estimated_drying_time, drying_status, created_at)
VALUES (2, 'Bau', NULL, 35.5, 'Sedang dikeringkan (Kondisi sepatu masih sangat basah)', NOW() - INTERVAL '1 hour 40 minutes');


-- Data Sensor Log 3: Setelah 40 Menit (Heater stabil pada 45 derajat)
INSERT INTO sensor_logs (shoe_id, device_id, temperature, humidity, gas_level, duration_usage, fan_usage_duration, uv_usage_duration, created_at)
VALUES (1, 1, 45.2, 58.0, 480.0, 0.72, 0.72, 0.72, NOW() - INTERVAL '1 hour 20 minutes');

INSERT INTO predictions (sensor_log_id, prediction_label, confidence_score, estimated_drying_time, drying_status, created_at)
VALUES (3, 'Normal', NULL, 24.8, 'Sedang dikeringkan (Kondisi sepatu hampir kering)', NOW() - INTERVAL '1 hour 20 minutes');


-- Data Sensor Log 4: Setelah 1 Jam (Kelembapan menurun pesat)
INSERT INTO sensor_logs (shoe_id, device_id, temperature, humidity, gas_level, duration_usage, fan_usage_duration, uv_usage_duration, created_at)
VALUES (1, 1, 45.0, 42.0, 320.0, 1.05, 1.05, 1.05, NOW() - INTERVAL '1 hour');

INSERT INTO predictions (sensor_log_id, prediction_label, confidence_score, estimated_drying_time, drying_status, created_at)
VALUES (4, 'Normal', NULL, 15.2, 'Sedang dikeringkan (Kondisi sepatu hampir kering)', NOW() - INTERVAL '1 hour');


-- Data Sensor Log 5: Setelah 1 Jam 20 Menit (Bau teratasi, kelembapan rendah)
INSERT INTO sensor_logs (shoe_id, device_id, temperature, humidity, gas_level, duration_usage, fan_usage_duration, uv_usage_duration, created_at)
VALUES (1, 1, 45.1, 28.0, 190.0, 1.38, 1.38, 1.05, NOW() - INTERVAL '40 minutes'); -- UV dimatikan setelah 1 jam (1.05) karena bau sudah normal

INSERT INTO predictions (sensor_log_id, prediction_label, confidence_score, estimated_drying_time, drying_status, created_at)
VALUES (5, 'Wangi', NULL, 6.4, 'Sedang dikeringkan (Kondisi sepatu hampir kering)', NOW() - INTERVAL '40 minutes');


-- Data Sensor Log 6: Setelah 1 Jam 40 Menit (Pengeringan selesai)
INSERT INTO sensor_logs (shoe_id, device_id, temperature, humidity, gas_level, duration_usage, fan_usage_duration, uv_usage_duration, created_at)
VALUES (1, 1, 38.0, 11.5, 130.0, 1.72, 1.72, 1.05, NOW() - INTERVAL '20 minutes');

INSERT INTO predictions (sensor_log_id, prediction_label, confidence_score, estimated_drying_time, drying_status, created_at)
VALUES (6, 'Wangi', NULL, 0.0, 'Selesai (Sepatu sudah kering optimal)', NOW() - INTERVAL '20 minutes');
