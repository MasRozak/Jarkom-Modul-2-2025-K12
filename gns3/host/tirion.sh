#!/bin/bash

# ============================================
# host/tirion.sh - DNS Master Server Setup
# ============================================

echo "[TIRION] Setting up DNS Master..."

docker exec tirion bash -c '
apt update
apt install -y bind9 bind9utils bind9-doc

# Create zone directory
mkdir -p /etc/bind/k12

# Configure named.conf.local
cat > /etc/bind/named.conf.local << "EOF"
zone "k12.com" {
    type master;
    file "/etc/bind/k12/k12.com";
    notify yes;
    also-notify { 192.217.2.4; };
    allow-transfer { 192.217.2.4; };
};

zone "2.217.192.in-addr.arpa" {
    type master;
    file "/etc/bind/k12/2.217.192.in-addr.arpa";
    notify yes;
    also-notify { 192.217.2.4; };
    allow-transfer { 192.217.2.4; };
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

# Create forward zone file
cat > /etc/bind/k12/k12.com << "EOF"
\$TTL    604800
@       IN      SOA     k12.com. root.k12.com. (
                        2025101902
                        604800
                        86400
                        2419200
                        30 )
;
@       IN      NS      ns1.k12.com.
@       IN      NS      ns2.k12.com.

@       IN      A       192.217.2.2

ns1      IN      A       192.217.2.3
ns2      IN      A       192.217.2.4
earendil IN      A       192.217.1.2
elwing   IN      A       192.217.1.3
cirdan   IN      A       192.217.3.2
elrond   IN      A       192.217.3.3
maglor   IN      A       192.217.3.4
lindon   IN      A       192.217.2.5
vingilot IN      A       192.217.2.6
sirion   IN      A       192.217.2.2

www      IN      CNAME   sirion
static   IN      CNAME   lindon
app      IN      CNAME   vingilot
havens   IN      CNAME   www

melkor   IN      TXT     "Morgoth (Melkor)"
morgoth  IN      CNAME   melkor.k12.com.
EOF

# Create reverse zone file
cat > /etc/bind/k12/2.217.192.in-addr.arpa << "EOF"
\$TTL    604800
@       IN      SOA     k12.com. root.k12.com. (
                        2025101902
                        604800
                        86400
                        2419200
                        30 )
;
@       IN      NS      ns1.k12.com.
@       IN      NS      ns2.k12.com.

3       IN      PTR     ns1.k12.com.
4       IN      PTR     ns2.k12.com.
2       IN      PTR     sirion.k12.com.
5       IN      PTR     lindon.k12.com.
6       IN      PTR     vingilot.k12.com.
EOF

# Start and enable bind9
systemctl enable bind9
systemctl restart bind9
'

echo "[TIRION] DNS Master configured ✓"