
#!/bin/bash

#Di Vingilot (Web & PHP)
apt update
apt install nginx php-fpm -y
mkdir -p /var/www/app.k12.com

cat > /var/www/app.k12.com/index.php << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Halaman Utama</title>
</head>
<body>
    <h1>Selamat Datang di app.k12.com</h1>
    <p>Ini adalah halaman utama yang disajikan oleh PHP-FPM.</p>
    <p>Waktu server saat ini: <?php echo date('Y-m-d H:i:s'); ?></p>
    <a href="/about">Tentang Kami</a>
</body>
</html>
EOF

cat > /var/www/app.k12.com/about.php << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Tentang Kami</title>
</head>
<body>
    <h1>Halaman About Aplikasi Ini</h1>
    <p>Ini adalah halaman 'About' yang dibuat untuk menunjukkan rewrite URL.</p>
    <a href="/">Kembali ke Halaman Utama</a>
</body>
</html>
EOF

cat > /etc/nginx/sites-available/app.k12.com << 'EOF'
server {
    listen 80;
    server_name app.k12.com;
    root /var/www/app.k12.com;

    index index.php;

    location / {
        try_files $uri $uri/ $uri.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;

        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock; 
    }

    location ~ /\.ht {
        deny all;
    }
} 
EOF

 ln -s /etc/nginx/sites-available/app.k12.com /etc/nginx/sites-enabled/
 nginx -t
 service php8.4-fpm restart
service nginx restart

#Di Client
apt-get update
apt-get install -y lynx
lynx app.k12.com/about
lynx app.k12.com