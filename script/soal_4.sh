#!/bin/bash

#Di Tirion (NS1)
apt-get update
apt-get install bind9 -y

ln -s /etc/init.d/named /etc/init.d/bind9 

cat > /etc/bind/named.conf.local << 'EOF'
zone "k12.com" {
        type master;
        file "/etc/bind/k12/k12.com";
        notify yes;
        also-notify { 192.217.2.4; };
        allow-transfer {192.217.2.4;};
    }; 
    
EOF

cat > /etc/bind/named.conf.options << 'EOF'
options {
        directory "/var/cache/bind";
        forwarders {
        192.168.122.1;
    };
        dnssec-validation no;
        allow-query{any;};
        auth-nxdomain no;
        listen-on-v6 { any; };
};
EOF

mkdir /etc/bind/k12 &&

cat > /etc/bind/zone.template << 'EOF'
$TTL    604800          ; Waktu cache default (detik)
@       IN      SOA     localhost. root.localhost. (
                        2025100401 ; Serial (format YYYYMMDDXX)
                        604800     ; Refresh (1 minggu)
                        86400      ; Retry (1 hari)
                        2419200    ; Expire (4 minggu)
                        604800 )   ; Negative Cache TTL
;

@       IN      NS      localhost.
@       IN      A       127.0.0.1
EOF

cp /etc/bind/zone.template /etc/bind/k12/k12.com

cat > /etc/bind/k12/k12.com << 'EOF'
$TTL    604800          ; Waktu cache default (detik)
@       IN      SOA     k12.com. root.k12.com. (
                        2025100401 ; Serial (format YYYYMMDDXX)
                        604800     ; Refresh (1 minggu)
                        86400      ; Retry (1 hari)
                        2419200    ; Expire (4 minggu)
                        604800 )   ; Negative Cache TTL
;

@       IN      NS      ns1.k12.com.
@       IN      NS      ns2.k12.com.

ns1      IN      A       192.217.2.3
ns2      IN      A       192.217.2.4

@       IN      A       192.217.2.2
EOF

service bind9 restart

#Di Valmor (NS2)
apt-get update
apt-get install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9

    

cat > /etc/bind/named.conf.local << 'EOF'
zone "k12.com" {
        type slave;
        file "/etc/bind/k12/k12.com";
        masters {192.217.2.3;};
}; 
EOF
service bind9 restart

#Di Client Non-Router
cat > /etc/resolv.conf << 'EOF'
nameserver 192.217.2.3
nameserver 192.217.2.4
nameserver 192.168.122.1
EOF
