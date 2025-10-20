# ============================================
# host/sirion.sh - Reverse Proxy Setup
# ============================================

echo "[SIRION] Setting up Reverse Proxy..."

docker exec sirion bash -c '
apt update
apt install -y nginx apache2-utils

# Create htpasswd for admin area
htpasswd -cb /etc/nginx/.htpasswd admin rahasia123

# Configure canonical hostname redirect
cat > /etc/nginx/sites-available/redirect.conf << "EOF"
server {
    listen 80;
    server_name sirion.k12.com 192.217.2.2;

    return 301 http://www.k12.com\$request_uri;
}
EOF

# Configure main reverse proxy
cat > /etc/nginx/sites-available/sirion.conf << "EOF"
server {
    listen 80;
    server_name www.k12.com;

    location /static/ {
        proxy_pass http://192.217.2.5/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /app/ {
        proxy_pass http://192.217.2.6/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /admin {
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://192.217.2.6/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location / {
        return 301 /static/;
    }
}
EOF

# Enable sites
ln -sf /etc/nginx/sites-available/redirect.conf /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/sirion.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Start nginx
systemctl enable nginx
systemctl restart nginx
'

echo "[SIRION] Reverse Proxy configured ✓"