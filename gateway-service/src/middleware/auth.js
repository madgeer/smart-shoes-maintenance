const jwt = require('jsonwebtoken');
require('dotenv').config();

const SECRET_KEY = process.env.SECRET_KEY || 'super_secret_session_key_for_smart_shoes';

// Middleware untuk memverifikasi token JWT pada rute REST API
const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  
  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: 'Akses ditolak. Token autentikasi tidak ditemukan.'
    });
  }

  // Token berformat: "Bearer <JWT_TOKEN>"
  const tokenParts = authHeader.split(' ');
  if (tokenParts.length !== 2 || tokenParts[0] !== 'Bearer') {
    return res.status(401).json({
      success: false,
      message: 'Format token salah. Harus berformat "Bearer <token>".'
    });
  }

  const token = tokenParts[1];

  try {
    const decoded = jwt.verify(token, SECRET_KEY);
    req.user = decoded; // Menyimpan data user terdekode (id, email, name) di objek request
    next();
  } catch (error) {
    console.error('[AUTH] Token tidak valid:', error.message);
    return res.status(403).json({
      success: false,
      message: 'Token kedaluwarsa atau tidak valid.'
    });
  }
};

module.exports = {
  verifyToken
};
