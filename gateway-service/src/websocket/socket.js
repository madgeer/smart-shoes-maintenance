const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const SECRET_KEY = process.env.SECRET_KEY || 'super_secret_session_key_for_smart_shoes';

let io = null;

// Menginisialisasi Server Socket.io
const initSocket = (server) => {
  io = new Server(server, {
    cors: {
      origin: '*', // Izinkan akses dashboard dari mana pun
      methods: ['GET', 'POST'],
    },
    path: '/realtime', // Sesuai dokumentasi ws://localhost:3000/realtime
  });

  // Middleware Autentikasi JWT pada Handshake Awal Socket.io
  io.use((socket, next) => {
    const token = socket.handshake.query.token;

    if (!token) {
      console.warn('[WEBSOCKET] Handshake gagal: Token tidak ditemukan.');
      return next(new Error('Autentikasi gagal: Token wajib disertakan.'));
    }

    try {
      const decoded = jwt.verify(token, SECRET_KEY);
      socket.user = decoded; // Pasang data user di objek socket
      console.log(`[WEBSOCKET] Handshake sukses: User ${decoded.name} (${decoded.email}) terhubung.`);
      next();
    } catch (err) {
      console.error('[WEBSOCKET] Handshake gagal: Token tidak valid.');
      return next(new Error('Autentikasi gagal: Token tidak valid atau kedaluwarsa.'));
    }
  });

  // Penanganan Koneksi Client
  io.on('connection', (socket) => {
    console.log(`[WEBSOCKET] Client terhubung. Socket ID: ${socket.id}, User ID: ${socket.user.id}`);

    // 1. Event 'subscribe:device' untuk bergabung ke ruang sensor perangkat tertentu
    socket.on('subscribe:device', (payload) => {
      const { device_code } = payload;
      if (!device_code) return;

      socket.join(device_code); // Masuk ke room berbasis kode perangkat
      console.log(`[WEBSOCKET] Client ${socket.user.name} berlangganan perangkat: ${device_code}`);
    });

    // 2. Event 'unsubscribe:device' untuk keluar dari ruang sensor perangkat
    socket.on('unsubscribe:device', (payload) => {
      const { device_code } = payload;
      if (!device_code) return;

      socket.leave(device_code);
      console.log(`[WEBSOCKET] Client ${socket.user.name} berhenti berlangganan perangkat: ${device_code}`);
    });

    // Penanganan pemutusan koneksi
    socket.on('disconnect', () => {
      console.log(`[WEBSOCKET] Client terputus. Socket ID: ${socket.id}`);
    });
  });

  return io;
};

// Fungsi Utilitas untuk menyiarkan data ke ruang perangkat tertentu
const broadcastToDevice = (deviceCode, eventName, data) => {
  if (!io) {
    console.warn('[WEBSOCKET] Server socket belum diinisialisasi.');
    return;
  }
  // Siarkan hanya ke client yang terhubung ke room 'deviceCode'
  io.to(deviceCode).emit(eventName, data);
  console.log(`[WEBSOCKET-PUSH] Emit '${eventName}' ke ruang '${deviceCode}'`);
};

// Fungsi Utilitas untuk mengirimkan Alert/Notifikasi Khusus ke User tertentu
const sendAlertToUser = (userId, eventName, alertData) => {
  if (!io) return;
  // Cari semua socket milik user dengan ID tersebut lalu pancarkan alert
  io.sockets.sockets.forEach((socket) => {
    if (socket.user && socket.user.id === parseInt(userId)) {
      socket.emit(eventName, alertData);
      console.log(`[WEBSOCKET-ALERT] Mengirim notifikasi realtime ke User ID: ${userId}`);
    }
  });
};

module.exports = {
  initSocket,
  broadcastToDevice,
  sendAlertToUser,
};
