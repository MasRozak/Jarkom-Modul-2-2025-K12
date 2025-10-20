#!/bin/bash

#Di Lindon (Static Web)

apt update
apt install nginx -y

mkdir -p /var/www/static.k12.com

cat > /etc/nginx/sites-available/static.k12.com << 'EOF'
server {
    listen 80;
    listen [::]:80;

    root /var/www/static.k12.com;

    index index.html index.htm;

    server_name static.k12.com;

    location / {
        try_files $uri $uri/ =404;
        autoindex on; 
    }
}
EOF
mkdir /var/www/static.k12.com/annals
echo "Arsip Dari Zaman Dahulu" > /var/www/static.k12.com/annals/arsip1.txt
echo "Arsip Dari Zaman Pertengahan" > /var/www/static.k12.com/annals/arsip2.txt
echo "Arsip Dari Zaman Modern" > /var/www/static.k12.com/annals/arsip3.txt
echo "<h1>Selamat Datang di Static.k12.com</h1>" > /var/www/static.k12.com/index.html

ln -s /etc/nginx/sites-available/static.k12.com /etc/nginx/sites-enabled/
service nginx restart

#Di Client 
apt update
apt install -y lynx
lynx static.k12.com