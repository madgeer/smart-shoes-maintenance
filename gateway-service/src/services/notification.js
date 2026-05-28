/**
 * =========================================================================
 * SMART SHOES MAINTENANCE - TELEGRAM NOTIFICATION SERVICE
 * =========================================================================
 * Layanan untuk mengirimkan notifikasi asinkron realtime ke Bot Telegram.
 * Menggunakan Axios untuk memanggil REST API Telegram secara non-blocking.
 * Desain fail-safe menjamin server tidak crash jika konfigurasi tidak diset.
 * =========================================================================
 */

const axios = require('axios');

const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const TELEGRAM_CHAT_ID = process.env.TELEGRAM_CHAT_ID;

/**
 * Mengirimkan pesan teks ke Bot Telegram
 * @param {string} text - Isi pesan yang akan dikirim (mendukung Markdown)
 * @returns {Promise<boolean>} - Mengembalikan true jika sukses, false jika gagal/diabaikan
 */
const sendTelegramNotification = async (text) => {
  // A. Proteksi Fail-safe: Lewati jika konfigurasi Telegram tidak diset/dummy
  if (
    !TELEGRAM_BOT_TOKEN || 
    !TELEGRAM_CHAT_ID || 
    TELEGRAM_BOT_TOKEN === 'your_telegram_bot_token_here' || 
    TELEGRAM_CHAT_ID === 'your_telegram_chat_id_here' ||
    TELEGRAM_BOT_TOKEN.trim() === '' || 
    TELEGRAM_CHAT_ID.trim() === ''
  ) {
    console.log('[TELEGRAM-NOTIF] [LOG] Konfigurasi Bot Telegram kosong atau dummy. Pengiriman pesan dilewati.');
    return false;
  }

  const url = `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`;

  try {
    const response = await axios.post(url, {
      chat_id: TELEGRAM_CHAT_ID,
      text: text,
      parse_mode: 'Markdown'
    }, {
      timeout: 5000 // Batasan waktu respon 5 detik agar asinkron tidak menggantung
    });

    if (response.data && response.data.ok) {
      console.log('[TELEGRAM-NOTIF] [SUKSES] Pesan berhasil terkirim ke Telegram.');
      return true;
    } else {
      console.warn('[TELEGRAM-NOTIF] [GAGAL] Respon Telegram API menunjukkan kegagalan:', response.data);
      return false;
    }
  } catch (error) {
    // Penanganan anggun kesalahan jaringan / timeout tanpa memecahkan server utama
    console.error('[TELEGRAM-NOTIF] [ERROR] Gagal mengirim pesan ke Telegram API:', error.message);
    return false;
  }
};

module.exports = {
  sendTelegramNotification
};
