#!/bin/bash

# ============================================
# host/vingilot.sh - Dynamic Web Server Setup
# ============================================

echo "[VINGILOT] Setting up Dynamic Web Server..."

docker exec vingilot bash -c '
apt update
apt install -y nginx php-fpm

# Detect PHP version
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.\".\".PHP_MINOR_VERSION;")

# Create web directory
mkdir -p /var/www/html

# Create PHP files
cat > /var/www/html/index.php << "EOF"
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Halaman Utama</title>
</head>
<body>
    <h1>Selamat Datang di app.k12.com</h1>
    <p>Ini adalah halaman utama yang disajikan oleh PHP-FPM.</p>
    <p>Waktu server saat ini: <?php echo date("Y-m-d H:i:s"); ?></p>
    <a href="/about">Tentang Kami</a>
</body>
</html>
EOF

cat > /var/www/html/about.php << "EOF"
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Tentang Kami</title>
</head>
<body>
    <h1>Halaman About Aplikasi Ini</h1>
    <p>Ini adalah halaman About yang dibuat untuk menunjukkan rewrite URL.</p>
    <a href="/">Kembali ke Halaman Utama</a>
</body>
</html>
EOF

# Configure nginx
cat > /etc/nginx/sites-available/vingilot.conf << EOF
server {
    listen 80;
    server_name app.k12.com vingilot.k12.com;

    root /var/www/html;
    index index.php index.html;

    # Custom log format for real IP
    log_format realip "\$remote_addr - \$remote_user [\$time_local] "
                      "\"\$request\" \$status \$body_bytes_sent "
                      "\"\$http_referer\" \"\$http_user_agent\" \"\$http_x_real_ip\"";

    access_log /var/log/nginx/access_realip.log realip;

    # Real IP from Sirion proxy
    real_ip_header X-Real-IP;
    set_real_ip_from 192.217.2.2;

    location / {
        try_files \$uri \$uri/ \$uri.php?\$query_string;
    }

    location /about {
        rewrite ^/about$ /about.php last;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/vingilot.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Start services
systemctl enable php${PHP_VERSION}-fpm
systemctl enable nginx
systemctl restart php${PHP_VERSION}-fpm
systemctl restart nginx
'

echo "[VINGILOT] Dynamic Web Server configured ✓"