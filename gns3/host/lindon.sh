#!/bin/bash

# ============================================
# host/lindon.sh - Static Web Server Setup
# ============================================

echo "[LINDON] Setting up Static Web Server..."

docker exec lindon bash -c '
apt update
apt install -y nginx

# Create web directory structure
mkdir -p /var/www/html/annals

# Create content
echo "<h1>Selamat Datang di Static.k12.com</h1>" > /var/www/html/index.html
echo "Arsip Dari Zaman Dahulu" > /var/www/html/annals/arsip1.txt
echo "Arsip Dari Zaman Pertengahan" > /var/www/html/annals/arsip2.txt
echo "Arsip Dari Zaman Modern" > /var/www/html/annals/arsip3.txt
echo "Arsip Lindon tersedia" > /var/www/html/annals/readme.txt

# Configure nginx
cat > /etc/nginx/sites-available/lindon.conf << "EOF"
server {
    listen 80;
    server_name static.k12.com lindon.k12.com;

    root /var/www/html;
    index index.html;

    location /annals/ {
        autoindex on;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/lindon.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Start nginx
systemctl enable nginx
systemctl restart nginx
'

echo "[LINDON] Static Web Server configured ✓"
