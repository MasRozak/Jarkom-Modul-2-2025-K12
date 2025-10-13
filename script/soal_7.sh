#Di Tirion (Master)
#!/bin/bash

cat > /etc/bind/k12/k12.com << 'EOF'
$TTL    604800          ; Waktu cache default (detik)
@       IN      SOA     k12.com. root.k12.com. (
                        2025100412 ; Serial (format YYYYMMDDXX)
                        604800     ; Refresh (1 minggu)
                        86400      ; Retry (1 hari)
                        2419200    ; Expire (4 minggu)
                        604800 )   ; Negative Cache TTL
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

www      IN      CNAME  sirion
static   IN      CNAME  lindon
app      IN      CNAME  vingilot

EOF

# Dari Elwing dan Elrond    
host www.k12.com 
host static.k12.com
host app.k12.com

#Atau
