# Stage 1: Build React app
FROM node:20-alpine AS build

# Tentukan working directory di dalam container
WORKDIR /usr/src/app

# Salin package.json dan package-lock.json
COPY package*.json ./

# Instal semua dependensi (termasuk devDependencies untuk build Vite)
RUN npm ci

# Salin seluruh kode sumber dashboard
COPY . .

# Build aplikasi React + Vite
RUN npm run build

# Stage 2: Sajikan menggunakan Nginx
FROM nginx:alpine

# Salin hasil build dari stage sebelumnya ke folder html Nginx
COPY --from=build /usr/src/app/dist /usr/share/nginx/html

# Ekspos port 80 untuk lalu lintas web
EXPOSE 80

# Jalankan Nginx di latar depan (foreground)
CMD ["nginx", "-g", "daemon off;"]
