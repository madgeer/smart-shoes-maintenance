/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - DATABASE MIGRATION SCRIPT
 * =========================================================================
 * File: migrate.js
 * Deskripsi: Menambahkan kolom-kolom baru ke tabel `devices` secara instan
 *            pada PostgreSQL aktif agar skema up-to-date.
 * =========================================================================
 */

const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'smartshoe_db',
  connectionTimeoutMillis: 5000,
});

async function runMigration() {
  console.log('[MIGRATION] Menghubungkan ke database PostgreSQL...');
  const client = await pool.connect();
  
  try {
    console.log('[MIGRATION] Memulai transaksi migrasi...');
    await client.query('BEGIN');

    // 1. Tambah kolom control_mode jika belum ada
    console.log('[MIGRATION] Menambahkan kolom `control_mode`...');
    await client.query(`
      ALTER TABLE devices 
      ADD COLUMN IF NOT EXISTS control_mode VARCHAR(20) NOT NULL DEFAULT 'auto'
    `);

    // 2. Tambah kolom heater_state jika belum ada
    console.log('[MIGRATION] Menambahkan kolom `heater_state`...');
    await client.query(`
      ALTER TABLE devices 
      ADD COLUMN IF NOT EXISTS heater_state VARCHAR(10) NOT NULL DEFAULT 'OFF'
    `);

    // 3. Tambah kolom uv_light_state jika belum ada
    console.log('[MIGRATION] Menambahkan kolom `uv_light_state`...');
    await client.query(`
      ALTER TABLE devices 
      ADD COLUMN IF NOT EXISTS uv_light_state VARCHAR(10) NOT NULL DEFAULT 'OFF'
    `);

    // 4. Tambah kolom fan_state jika belum ada
    console.log('[MIGRATION] Menambahkan kolom `fan_state`...');
    await client.query(`
      ALTER TABLE devices 
      ADD COLUMN IF NOT EXISTS fan_state VARCHAR(10) NOT NULL DEFAULT 'OFF'
    `);

    // 5. Tambah CONSTRAINT check untuk kolom-kolom tersebut agar aman
    console.log('[MIGRATION] Menambahkan check constraints...');
    
    // Hapus constraint lama jika ada untuk menghindari konflik penamaan
    await client.query('ALTER TABLE devices DROP CONSTRAINT IF EXISTS chk_control_mode');
    await client.query('ALTER TABLE devices DROP CONSTRAINT IF EXISTS chk_heater_state');
    await client.query('ALTER TABLE devices DROP CONSTRAINT IF EXISTS chk_uv_light_state');
    await client.query('ALTER TABLE devices DROP CONSTRAINT IF EXISTS chk_fan_state');

    // Tambah constraint baru
    await client.query("ALTER TABLE devices ADD CONSTRAINT chk_control_mode CHECK (control_mode IN ('auto', 'manual'))");
    await client.query("ALTER TABLE devices ADD CONSTRAINT chk_heater_state CHECK (heater_state IN ('ON', 'OFF'))");
    await client.query("ALTER TABLE devices ADD CONSTRAINT chk_uv_light_state CHECK (uv_light_state IN ('ON', 'OFF'))");
    await client.query("ALTER TABLE devices ADD CONSTRAINT chk_fan_state CHECK (fan_state IN ('ON', 'OFF'))");

    await client.query('COMMIT');
    console.log('[MIGRATION] Migrasi database SUKSES dan berhasil di-commit!');
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('[MIGRATION] ERROR: Gagal mengeksekusi migrasi database:', error.message);
  } finally {
    client.release();
    await pool.end();
    console.log('[MIGRATION] Koneksi ke database ditutup.');
  }
}

runMigration();
