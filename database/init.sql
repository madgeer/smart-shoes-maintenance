-- =========================================================================
-- SMART SHOES MAINTENANCE - DATABASE INITIALIZATION SCHEMA
-- =========================================================================

-- 1. Table for Users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Table for Devices
CREATE TABLE IF NOT EXISTS devices (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    device_name VARCHAR(100) NOT NULL,
    device_code VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    control_mode VARCHAR(20) NOT NULL DEFAULT 'auto' CHECK (control_mode IN ('auto', 'manual')),
    heater_state VARCHAR(10) NOT NULL DEFAULT 'OFF' CHECK (heater_state IN ('ON', 'OFF')),
    uv_light_state VARCHAR(10) NOT NULL DEFAULT 'OFF' CHECK (uv_light_state IN ('ON', 'OFF')),
    fan_state VARCHAR(10) NOT NULL DEFAULT 'OFF' CHECK (fan_state IN ('ON', 'OFF')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Table for Shoes
CREATE TABLE IF NOT EXISTS shoes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    shoe_name VARCHAR(100) NOT NULL,
    shoe_type VARCHAR(50) NOT NULL, -- e.g., Sneaker, Running, Boot
    shoe_material VARCHAR(20) NOT NULL CHECK (shoe_material IN ('Kanvas', 'Kulit', 'Mesh')), -- Digunakan untuk ML Regression Input
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Table for Sensor Logs (DHT22 and MQ-135 logs with usage metrics)
CREATE TABLE IF NOT EXISTS sensor_logs (
    id SERIAL PRIMARY KEY,
    shoe_id INTEGER REFERENCES shoes(id) ON DELETE SET NULL,
    device_id INTEGER REFERENCES devices(id) ON DELETE SET NULL,
    temperature FLOAT NOT NULL,
    humidity FLOAT NOT NULL,
    gas_level FLOAT NOT NULL,
    duration_usage FLOAT DEFAULT 0.0,      -- Durasi penggunaan total (jam) dari MQTT
    fan_usage_duration FLOAT DEFAULT 0.0,  -- Durasi aktif kipas (jam) dari MQTT
    uv_usage_duration FLOAT DEFAULT 0.0,   -- Durasi aktif UV (jam) dari MQTT
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Table for Machine Learning Predictions (Supports smell and drying predictions)
CREATE TABLE IF NOT EXISTS predictions (
    id SERIAL PRIMARY KEY,
    sensor_log_id INTEGER REFERENCES sensor_logs(id) ON DELETE CASCADE,
    
    -- Hasil Model 1: Detektor Bau (K-Means)
    prediction_label VARCHAR(50) NOT NULL, -- Kategori Bau: 'Wangi', 'Normal', 'Bau'
    confidence_score FLOAT,                -- NULLABLE karena K-Means tidak menghasilkan probabilitas
    
    -- Hasil Model 2: Estimasi Pengeringan (Regression)
    estimated_drying_time FLOAT,           -- Sisa waktu pengeringan dalam menit (sisa_waktu_menit dari ML)
    drying_status VARCHAR(100),            -- Status kondisi pengeringan dari ML (status dari ML)
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Table for Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(20) DEFAULT 'INFO', -- e.g., INFO, WARNING, DANGER untuk pembeda warna di UI
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Table for Maintenance Logs (Log pemeliharaan perangkat fisik)
CREATE TABLE IF NOT EXISTS maintenance_logs (
    id SERIAL PRIMARY KEY,
    device_id INTEGER REFERENCES devices(id) ON DELETE SET NULL,
    component_name VARCHAR(100),
    issue TEXT,
    action_taken VARCHAR(255) NOT NULL,
    maintenance_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
