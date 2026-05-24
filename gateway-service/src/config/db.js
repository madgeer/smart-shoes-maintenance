const { Pool } = require('pg');
require('dotenv').config();

// Membuat pool koneksi ke PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'smartshoe_db',
  max: 20, // Batas maksimal koneksi paralel dalam pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Menangani event koneksi berhasil/gagal
pool.on('connect', () => {
  console.log('[DATABASE] PostgreSQL Pool berhasil terhubung.');
});

pool.on('error', (err) => {
  console.error('[DATABASE] Error tak terduga pada PostgreSQL Pool:', err);
  process.exit(-1);
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool
};
