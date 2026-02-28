#!/bin/bash
# =========================================
# FALSE OVERLAY TOOL LAUNCHER - Linux Version
# Pengganti FALSEMLBBOVELAYFIX.bat untuk Linux
# =========================================

echo ""
echo "===================================================================="
echo "      INITIALIZING NODE.JS SERVER / MELAKUKAN INISIALISASI SERVER"
echo "===================================================================="
echo ""

# -----------------------------------------------------------------------
# STEP 1: Mencari alamat IPv4 aktif (mengabaikan adapter virtual)
# -----------------------------------------------------------------------
echo "[STEP 1] Finding active IPv4 address (Filtering Virtual Adapters)..."
echo "[LANGKAH 1] Mencari alamat IPv4 (Mengabaikan VirtualBox/VMware)..."

IP_ADDRESS=""

# Cari interface yang aktif dan punya gateway (bukan lo/virtual/docker/vbox)
# Urutkan prioritas: wlan (WiFi) dulu, lalu eth (LAN)
for iface in $(ip -o link show up | awk -F': ' '{print $2}' | grep -vE '^lo$|^vbox|^vmnet|^docker|^br-|^virbr|^tun|^tap'); do
    CANDIDATE=$(ip -4 addr show "$iface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
    if [ -n "$CANDIDATE" ]; then
        IP_ADDRESS="$CANDIDATE"
        echo "[INFO] Interface ditemukan: $iface -> $CANDIDATE"
        break
    fi
done

# Jika tidak ditemukan lewat cara di atas, fallback ke route default
if [ -z "$IP_ADDRESS" ]; then
    IP_ADDRESS=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K[\d.]+')
fi

# Cek apakah IP berhasil didapatkan
if [ -z "$IP_ADDRESS" ]; then
    echo ""
    echo "[FAILED] No suitable active connection found."
    echo "[GAGAL]  Tidak ditemukan koneksi Wi-Fi/LAN utama."
    echo ""
    echo "Penyebab umum:"
    echo "1. Anda tidak terhubung ke internet/router."
    echo "2. Semua interface difilter sebagai virtual."
    echo ""
    echo "Solusi Darurat:"
    echo "Ketik IP manual anda di 'public/serverip.txt' lalu jalankan:"
    echo "  node server.js"
    echo ""
    read -p "Tekan ENTER untuk keluar..."
    exit 1
fi

echo "[SUCCESS] Main Adapter IP found: $IP_ADDRESS"
echo ""

# -----------------------------------------------------------------------
# STEP 2: Menyimpan IP ke file public/serverip.txt
# -----------------------------------------------------------------------
echo "[STEP 2] Saving IP address to public/serverip.txt..."
echo "$IP_ADDRESS" > public/serverip.txt

# -----------------------------------------------------------------------
# STEP 3: Persiapan Server
# -----------------------------------------------------------------------
echo "[STEP 3] Starting Server..."
sleep 2

# Buka Browser (coba berbagai browser yang umum di Linux)
{
  sleep 2
  if command -v xdg-open &>/dev/null; then
    xdg-open "http://$IP_ADDRESS:3000/hub.html" &
  elif command -v firefox &>/dev/null; then
    firefox "http://$IP_ADDRESS:3000/hub.html" &
  elif command -v google-chrome &>/dev/null; then
    google-chrome "http://$IP_ADDRESS:3000/hub.html" &
  elif command -v chromium-browser &>/dev/null; then
    chromium-browser "http://$IP_ADDRESS:3000/hub.html" &
  else
    echo "[INFO] Tidak bisa membuka browser otomatis. Buka manual: http://$IP_ADDRESS:3000/hub.html"
  fi
} &

clear

echo "========================================="
echo "===========FALSE OVERLAY TOOL============"
echo "========================================="
echo ""
echo "IP DETECTION - LINUX VERSION"
echo ""
echo "========================================="
echo "Server is running on Port 3000..."
echo "Local Access: http://localhost:3000"
echo "LAN Access  : http://$IP_ADDRESS:3000"
echo ""
echo "Do not close this terminal!"
echo "Jangan tutup terminal ini!"
echo "========================================="
echo ""

# Jalankan Node.js server
node server.js

# Cek jika server gagal start
if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] Server failed to start."
    read -p "Tekan ENTER untuk keluar..."
fi
