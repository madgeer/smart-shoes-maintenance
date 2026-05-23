const db = require('../config/db');

// 1. Menambahkan pasang sepatu baru untuk dipantau
const addShoe = async (req, res) => {
  const { shoe_name, shoe_type, shoe_material } = req.body;
  const userId = req.user.id; // Diambil dari token JWT

  if (!shoe_name || !shoe_type || !shoe_material) {
    return res.status(400).json({
      success: false,
      message: 'Parameter shoe_name, shoe_type, dan shoe_material wajib diisi.'
    });
  }

  // Validasi bahan sepatu sesuai batasan database CHECK constraint
  const validMaterials = ['Kanvas', 'Kulit', 'Mesh'];
  if (!validMaterials.includes(shoe_material)) {
    return res.status(400).json({
      success: false,
      message: `Bahan sepatu (shoe_material) tidak valid. Harus salah satu dari: ${validMaterials.join(', ')}`
    });
  }

  try {
    // Masukkan data sepatu ke database
    const insertQuery = `
      INSERT INTO shoes (user_id, shoe_name, shoe_type, shoe_material)
      VALUES ($1, $2, $3, $4)
      RETURNING id, user_id, shoe_name, shoe_type, shoe_material, created_at
    `;
    const newShoe = await db.query(insertQuery, [userId, shoe_name, shoe_type, shoe_material]);

    return res.status(201).json({
      success: true,
      message: 'Shoe added successfully',
      data: newShoe.rows[0]
    });
  } catch (error) {
    console.error('[SHOE-CTRL] Error Add Shoe:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan sistem saat mendaftarkan data sepatu.'
    });
  }
};

// 2. Mengambil semua daftar sepatu milik pengguna yang sedang login
const getShoes = async (req, res) => {
  const userId = req.user.id;

  try {
    const shoes = await db.query(
      'SELECT id, shoe_name, shoe_type, shoe_material, created_at FROM shoes WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );

    return res.status(200).json({
      success: true,
      data: shoes.rows
    });
  } catch (error) {
    console.error('[SHOE-CTRL] Error Get Shoes:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan sistem saat mengambil data sepatu.'
    });
  }
};

module.exports = {
  addShoe,
  getShoes
};
