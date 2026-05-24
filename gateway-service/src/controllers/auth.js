const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/db');
require('dotenv').config();

const SECRET_KEY = process.env.SECRET_KEY || 'super_secret_session_key_for_smart_shoes';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

// 1. Controller untuk Register User Baru
const register = async (req, res) => {
  const { name, email, password } = req.body;

  // Validasi Input Sederhana
  if (!name || !email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Parameter name, email, dan password wajib diisi.'
    });
  }

  try {
    // Periksa apakah email sudah terdaftar
    const checkEmail = await db.query('SELECT id FROM users WHERE email = $1', [email]);
    if (checkEmail.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Email sudah terdaftar. Gunakan email lain.'
      });
    }

    // Enkripsi Password menggunakan Bcrypt
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Simpan ke database
    const insertQuery = `
      INSERT INTO users (name, email, password)
      VALUES ($1, $2, $3)
      RETURNING id, name, email, created_at
    `;
    const newUser = await db.query(insertQuery, [name, email, hashedPassword]);

    return res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: newUser.rows[0]
    });
  } catch (error) {
    console.error('[AUTH-CTRL] Error Register:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan sistem saat mendaftarkan akun.'
    });
  }
};

// 2. Controller untuk Login User
const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Parameter email dan password wajib diisi.'
    });
  }

  try {
    // Cari user berdasarkan email
    const result = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Autentikasi gagal. Email atau password salah.'
      });
    }

    const user = result.rows[0];

    // Bandingkan password terenkripsi
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Autentikasi gagal. Email atau password salah.'
      });
    }

    // Tanda tangani token JWT
    const tokenPayload = {
      id: user.id,
      email: user.email,
      name: user.name
    };

    const token = jwt.sign(tokenPayload, SECRET_KEY, { expiresIn: JWT_EXPIRES_IN });

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      token: token,
      data: {
        id: user.id,
        name: user.name,
        email: user.email
      }
    });
  } catch (error) {
    console.error('[AUTH-CTRL] Error Login:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan sistem saat masuk.'
    });
  }
};

module.exports = {
  register,
  login
};
