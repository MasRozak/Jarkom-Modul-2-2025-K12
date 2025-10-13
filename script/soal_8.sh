#!/bin/bash

#Di Tirion (NS1)
cat >> /etc/bind/named.conf.local << 'EOF'
zone "2.217.192.in-addr.arpa" {
        type master;
        file "/etc/bind/k12/2.217.192.in-addr.arpa";
        notify yes;
        also-notify { 192.217.2.4; };
        allow-transfer { 192.217.2.4; };
    };
    
EOF



cat > /etc/bind/k12/2.217.192.in-addr.arpa << 'EOF'
$TTL    604800          ; Waktu cache default (detik)
@       IN      SOA     k12.com. root.k12.com. (
                        2025100406 ; Serial (format YYYYMMDDXX)
                        604800     ; Refresh (1 minggu)
                        86400      ; Retry (1 hari)
                        2419200    ; Expire (4 minggu)
                        604800 )   ; Negative Cache TTL
;

@       IN      NS      ns1.k12.com.
@       IN      NS      ns2.k12.com.

3      IN      PTR     ns1.k12.com.
4      IN      PTR     ns2.k12.com.
2      IN      PTR     sirion.k12.com.
5      IN      PTR     lindon.k12.com.
6      IN      PTR     vingilot.k12.com.

EOF

service bind9 restart
#Di Valmar (slave)
cat >> /etc/bind/named.conf.local << 'EOF'
zone "2.217.192.in-addr.arpa" {
        type slave;
        file "/etc/bind/slave/2.217.192.in-addr.arpa";
        masters { 192.217.2.3; };
    };
EOF

service bind9 restart