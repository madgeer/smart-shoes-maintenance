# Gunakan image Node.js yang ringan sebagai base image
FROM node:18-alpine

# Tentukan working directory di dalam container
WORKDIR /usr/src/app

# Salin package.json dan package-lock.json terlebih dahulu untuk memanfaatkan caching Docker layer
COPY package*.json ./

# Instal dependensi produksi saja untuk memperkecil ukuran image
RUN npm ci --only=production

# Salin seluruh kode sumber aplikasi gateway
COPY . .

# Ekspos port 3000 sesuai konfigurasi server
EXPOSE 3000

# Set variabel lingkungan untuk produksi
ENV NODE_ENV=production

# Perintah untuk menjalankan aplikasi
CMD ["npm", "start"]
