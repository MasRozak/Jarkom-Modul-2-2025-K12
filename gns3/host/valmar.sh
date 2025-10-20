#!/bin/bash

# ============================================
# host/valmar.sh - DNS Slave Server Setup
# ============================================

echo "[VALMAR] Setting up DNS Slave..."

docker exec valmar bash -c '
apt update
apt install -y bind9 bind9utils bind9-doc

# Configure named.conf.local
cat > /etc/bind/named.conf.local << "EOF"
zone "k12.com" {
    type slave;
    file "/etc/bind/slave/k12.com";
    masters { 192.217.2.3; };
};

zone "2.217.192.in-addr.arpa" {
    type slave;
    file "/etc/bind/slave/2.217.192.in-addr.arpa";
    masters { 192.217.2.3; };
};
EOF

# Configure named.conf.options
cat > /etc/bind/named.conf.options << "EOF"
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
        8.8.8.8;
    };
    dnssec-validation no;
    allow-query { any; };
    auth-nxdomain no;
    listen-on-v6 { any; };
};
EOF

# Create slave directory
mkdir -p /etc/bind/slave
chown bind:bind /etc/bind/slave

# Start and enable bind9
systemctl enable bind9
systemctl restart bind9
'

echo "[VALMAR] DNS Slave configured ✓"