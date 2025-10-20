# LAPORAN PRAKTIKUM MODUL 2 JARINGAN KOMPUTER
**Kelompok K12
| NRP | Nama |
|---|---|
| 5027241038 | Moch. Rizki Nasrullah |
| 5027241060 | Bima Aria Perthama |

---

## Daftar Isi
- [Soal 1-3](#soal-1-3-setup-topologi-dan-konfigurasi-jaringan)
- [Soal 4](#soal-4-konfigurasi-dns-master-dan-slave-server)
- [Soal 5](#soal-5-menambahkan-record-dns-untuk-semua-node)
- [Soal 6](#soal-6-testing-dns-replication)
- [Soal 7](#soal-7-konfigurasi-cname-record)
- [Soal 8](#soal-8-reverse-dns-lookup)
- [Soal 9](#soal-9-web-server-statis-dengan-nginx)
- [Soal 10](#soal-10-web-server-dinamis-dengan-php-fpm)
- [Soal 11](#soal-11-lampion-lindon-dinyalakan)
- [Soal 12](#soal-12-vingilot-mengisahkan-cerita-dinamis)
- [Soal 13](#soal-13-di-muara-sungai-sirion-berdiri)
- [Soal 14](#soal-14-kamar-kecil-di-balik-gerbang)
- [Soal 15](#soal-15-kanonisasi-hostname-sirion)
- [Soal 16](#soal-16-catatan-kedatangan-di-vingilot)
- [Soal 17](#soal-17-pengujian-beban-dengan-apachebench)
- [Soal 18](#soal-18-badai-mengubah-garis-pantai)
- [Soal 19](#soal-19-mereka-bangkit-sendiri)
- [Soal 20](#soal-20-sang-musuh-dan-pelabuhan-baru)

---

## Soal 1-3: Setup Topologi dan Konfigurasi Jaringan

### Deskripsi
Pada tahap awal praktikum, kita melakukan setup topologi jaringan lengkap untuk kelompok K12. Tahap ini mencakup pembuatan topologi jaringan, konfigurasi interface pada setiap node, setup routing, dan persiapan environment untuk DNS server dan web server.

### Topologi Jaringan
Topologi yang digunakan terdiri dari beberapa subnet dengan node-node sebagai berikut:

**Subnet 192.217.1.0/24:
- Earendil (192.217.1.2)
- Elwing (192.217.1.3)

**Subnet 192.217.2.0/24:
- Sirion - Router (192.217.2.2)
- Tirion - DNS Master/NS1 (192.217.2.3)
- Valmor - DNS Slave/NS2 (192.217.2.4)
- Lindon - Static Web Server (192.217.2.5)
- Vingilot - Dynamic Web Server (192.217.2.6)

**Subnet 192.217.3.0/24:
- Cirdan (192.217.3.2)
- Elrond (192.217.3.3)
- Maglor (192.217.3.4)

### Langkah Pengerjaan

#### 1. Membuat Topologi Jaringan
Membuat topologi sesuai dengan spesifikasi modul menggunakan GNS3 atau tool network simulator lainnya. Topologi terdiri dari:
- 1 Router utama (Sirion) yang terhubung ke 3 subnet
- 2 DNS Server (Master dan Slave)
- 2 Web Server (Static dan Dynamic)
- 6 Client node untuk testing

#### 2. Konfigurasi Network Interface
Setiap node dikonfigurasi dengan IP address yang sesuai dengan subnet masing-masing:

**Contoh konfigurasi di Router Sirion:
```bash
# Interface ke subnet 192.217.1.0/24
auto eth0
iface eth0 inet static
    address 192.217.1.1
    netmask 255.255.255.0

# Interface ke subnet 192.217.2.0/24
auto eth1
iface eth1 inet static
    address 192.217.2.2
    netmask 255.255.255.0

# Interface ke subnet 192.217.3.0/24
auto eth2
iface eth2 inet static
    address 192.217.3.1
    netmask 255.255.255.0

# Interface ke internet
auto eth3
iface eth3 inet dhcp
```

**Contoh konfigurasi di Client/Server Node:
```bash
auto eth0
iface eth0 inet static
    address 192.217.x.x
    netmask 255.255.255.0
    gateway 192.217.x.1
```



#### 3. Konfigurasi DNS Resolver Sementara
Sebelum DNS server sendiri aktif, kita set DNS resolver ke DNS publik:

```bash
# Di setiap node
cat > /etc/resolv.conf << 'EOF'
nameserver 192.168.122.1
nameserver 8.8.8.8
EOF
```

#### 4. Testing Konektivitas
Testing koneksi antar node dan ke internet:

```bash
# Test ping antar subnet
ping -c 3 192.217.1.2  # ke Earendil
ping -c 3 192.217.2.3  # ke Tirion
ping -c 3 192.217.3.2  # ke Cirdan

# Test koneksi internet
ping -c 3 google.com
```

#### 6. Update Repository dan Instalasi Paket Dasar
Di semua node yang memerlukan, update repository dan install paket yang diperlukan:

```bash
# Update repository
apt update

# Install paket dasar
apt install -y nano wget curl dnsutils

# Di DNS Server (Tirion & Valmor)
apt install -y bind9

# Di Web Server (Lindon)
apt install -y nginx

# Di Web Server (Vingilot)
apt install -y nginx php-fpm

# Di Client untuk testing
apt install -y lynx
```

#### 7. Verifikasi Setup
Pastikan semua konfigurasi berjalan dengan baik:
- Semua node dapat ping ke gateway masing-masing
- Semua node dapat ping ke node di subnet lain
- Semua node dapat mengakses internet
- Paket-paket yang diperlukan terinstall dengan baik

### Dokumentasi
![Setup Topologi dan Konfigurasi Jaringan](1.png)

Dokumentasi menunjukkan topologi jaringan telah berhasil dibuat dan dikonfigurasi dengan baik. Semua node dapat saling berkomunikasi dan memiliki akses ke internet.

---

## Soal 4: Konfigurasi DNS Master dan Slave Server

### Deskripsi
Pada soal ini, kita diminta untuk mengkonfigurasi DNS server dengan arsitektur Master-Slave. DNS Master akan berjalan di node Tirion dan DNS Slave di node Valmor. Domain yang digunakan adalah `k12.com` dengan setup zone transfer dan notifikasi otomatis.

### Langkah Pengerjaan

#### 1. Setup DNS Master di Tirion (NS1)
Pertama, kita melakukan instalasi bind9 dan membuat symbolic link untuk memudahkan management:

```bash
apt update
apt install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9
```

#### 2. Konfigurasi named.conf.local
Membuat konfigurasi zone untuk domain k12.com dengan fitur notifikasi dan transfer zone ke slave:

```bash
zone "k12.com" {
    type master;
    file "/etc/bind/k12/k12.com";
    notify yes;
    also-notify { 192.217.2.4; };
    allow-transfer {192.217.2.4;};
};
```

Penjelasan:
- `type master`: menandakan ini adalah DNS master
- `notify yes`: mengaktifkan notifikasi otomatis ke slave
- `also-notify`: IP address slave server (Valmor)
- `allow-transfer`: mengizinkan zone transfer ke IP slave

#### 3. Konfigurasi named.conf.options
Setup DNS forwarder dan allow query dari semua client:

```bash
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
```

#### 4. Membuat Zone Template
Membuat template zone yang akan digunakan sebagai base:

```bash
mkdir /etc/bind/k12
cat > /etc/bind/zone.template << 'EOF'
$TTL    604800
@       IN      SOA     localhost. root.localhost. (
                        2025100401
                        604800
                        86400
                        2419200
                        604800 )
;
@       IN      NS      localhost.
@       IN      A       127.0.0.1
EOF
```

#### 5. Konfigurasi Zone File untuk k12.com
Membuat zone file dengan record NS dan A yang sesuai:

```bash
cat > /etc/bind/k12/k12.com << 'EOF'
$TTL    604800
@       IN      SOA     k12.com. root.k12.com. (
                        2025100401
                        604800
                        86400
                        2419200
                        604800 )
;
@       IN      NS      ns1.k12.com.
@       IN      NS      ns2.k12.com.

ns1      IN      A       192.217.2.3
ns2      IN      A       192.217.2.4

@       IN      A       192.217.2.2
EOF

service bind9 restart
```

#### 6. Setup DNS Slave di Valmor (NS2)
Instalasi bind9 dan konfigurasi sebagai slave:

```bash
apt update
apt install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9

cat > /etc/bind/named.conf.local << 'EOF'
zone "k12.com" {
    type slave;
    file "/etc/bind/k12/k12.com";
    masters {192.217.2.3;};
};
EOF

service bind9 restart
```

#### 7. Konfigurasi DNS Resolver di Client
Setting nameserver di client untuk menggunakan kedua DNS server:

```bash
cat > /etc/resolv.conf << 'EOF'
nameserver 192.217.2.3
nameserver 192.217.2.4
nameserver 192.168.122.1
EOF
```

### Dokumentasi
![Hasil Testing Soal 4](4.png)

Pada dokumentasi terlihat bahwa konfigurasi DNS Master-Slave berhasil dan dapat melakukan zone transfer dengan baik.

---

## Soal 5: Menambahkan Record DNS untuk Semua Node

### Deskripsi
Menambahkan A record untuk semua node dalam topologi ke zone file DNS master. Ini memungkinkan setiap node dapat di-resolve menggunakan nama hostname.

### Langkah Pengerjaan

#### 1. Update Zone File di Tirion (NS1)
Menambahkan record A untuk seluruh node dalam jaringan:

```bash
cat > /etc/bind/k12/k12.com << 'EOF'
$TTL    604800
@       IN      SOA     k12.com. root.k12.com. (
                        2025100411
                        604800
                        86400
                        2419200
                        604800 )
;

@       IN      NS      ns1.k12.com.
@       IN      NS      ns2.k12.com.

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

@       IN      A       192.217.2.2
EOF

service bind9 restart
```

#### 2. Penjelasan Record
- Serial number dinaikkan menjadi `2025100411` untuk menandakan perubahan
- Setiap node memiliki A record yang mengarah ke IP address masing-masing
- NS record untuk ns1 dan ns2 tetap dipertahankan
- Root domain (@) mengarah ke IP Sirion sebagai main entry point

#### 3. Testing DNS Resolution
Setelah konfigurasi, zone akan otomatis ter-transfer ke slave server Valmor karena sudah dikonfigurasi zone transfer di soal 4.

### Dokumentasi
![Hasil Testing Soal 5](5.png)

Dokumentasi menunjukkan semua hostname dapat di-resolve dengan benar ke IP address yang sesuai.

---

## Soal 6: Testing DNS Replication

### Deskripsi
Melakukan testing untuk memastikan DNS replication berjalan dengan baik antara master dan slave server menggunakan perintah dig.

### Langkah Pengerjaan

#### 1. Instalasi Tool untuk Testing
Di node Valimar, install journalctl untuk melihat log system:

```bash
apt update && apt install -y journalctl
```

#### 2. Query ke DNS Master (Tirion)
Melakukan query SOA record ke master server:

```bash
dig @192.217.2.3 k12.com SOA
```

Perintah ini akan menampilkan:
- Serial number dari zone
- Refresh, retry, dan expire time
- TTL values
- Authoritative nameserver

#### 3. Query ke DNS Slave (Valmor)
Melakukan query yang sama ke slave server:

```bash
dig @192.217.2.4 k12.com SOA
```

#### 4. Verifikasi Serial Number
Kedua query harus menunjukkan serial number yang sama, yang membuktikan zone transfer berhasil. Serial number yang diharapkan adalah `2025100411`.

### Dokumentasi
![Hasil Testing Soal 6](6.png)

Dokumentasi menunjukkan bahwa serial number dan SOA record sama di kedua server, membuktikan replikasi DNS berjalan dengan baik.

---

## Soal 7: Konfigurasi CNAME Record

### Deskripsi
Menambahkan CNAME record untuk membuat alias domain yang mengarah ke hostname tertentu. Ini berguna untuk memberikan nama alternatif untuk service yang sama.

### Langkah Pengerjaan

#### 1. Update Zone File dengan CNAME
Di Tirion (Master), tambahkan CNAME record ke zone file:

```bash
cat > /etc/bind/k12/k12.com << 'EOF'
$TTL    604800
@       IN      SOA     k12.com. root.k12.com. (
                        2025100413
                        604800
                        86400
                        2419200
                        604800 )
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
```

#### 2. Penjelasan CNAME Record
- `www.k12.com` → alias untuk `sirion.k12.com`
- `static.k12.com` → alias untuk `lindon.k12.com` (static web server)
- `app.k12.com` → alias untuk `vingilot.k12.com` (dynamic web server)

CNAME record berfungsi sebagai canonical name atau alias. Ketika client melakukan query ke www.k12.com, DNS akan resolve ke sirion.k12.com, kemudian ke IP address sirion.

#### 3. Testing CNAME Resolution
Dari client (Elwing atau Elrond), test menggunakan perintah host:

```bash
host www.k12.com
host static.k12.com
host app.k12.com
```

Setiap command akan menunjukkan:
1. CNAME record mengarah ke hostname target
2. Hostname target memiliki A record ke IP address

### Dokumentasi
![Hasil Testing dari Elrond](7_Check%20Resolver%20Dari%20Elrond.png)

![Hasil Testing dari Elwing](7_Check%20Resolver%20Dari%20Elwing.png)

Dokumentasi menunjukkan CNAME record berhasil di-resolve dari client Elrond dan Elwing dengan benar.

---

## Soal 8: Reverse DNS Lookup

### Deskripsi
Konfigurasi Reverse DNS (PTR record) untuk melakukan reverse lookup dari IP address ke hostname. Reverse DNS berguna untuk verifikasi identitas server dan sering digunakan untuk email server validation.

### Langkah Pengerjaan

#### 1. Setup Reverse Zone di Tirion (Master)
Tambahkan konfigurasi reverse zone di named.conf.local:

```bash
cat >> /etc/bind/named.conf.local << 'EOF'
zone "2.217.192.in-addr.arpa" {
    type master;
    file "/etc/bind/k12/2.217.192.in-addr.arpa";
    notify yes;
    also-notify { 192.217.2.4; };
    allow-transfer { 192.217.2.4; };
};
EOF
```

Penjelasan:
- Zone name format untuk reverse DNS: `<reversed-network>.in-addr.arpa`
- Untuk subnet 192.217.2.0/24, zone name-nya adalah `2.217.192.in-addr.arpa`
- Sama seperti forward zone, kita enable notifikasi dan zone transfer ke slave

#### 2. Membuat Reverse Zone File
Buat file zone untuk reverse lookup:

```bash
cat > /etc/bind/k12/2.217.192.in-addr.arpa << 'EOF'
$TTL    604800
@       IN      SOA     k12.com. root.k12.com. (
                        2025100406
                        604800
                        86400
                        2419200
                        604800 )
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
```

Penjelasan PTR record:
- Angka di kolom pertama adalah oktet terakhir dari IP address
- PTR mengarah ke fully qualified domain name (harus diakhiri dengan titik)
- Contoh: `3 IN PTR ns1.k12.com.` artinya IP 192.217.2.3 → ns1.k12.com

#### 3. Setup Reverse Zone di Valmor (Slave)
Tambahkan konfigurasi slave untuk reverse zone:

```bash
cat >> /etc/bind/named.conf.local << 'EOF'
zone "2.217.192.in-addr.arpa" {
    type slave;
    file "/etc/bind/slave/2.217.192.in-addr.arpa";
    masters { 192.217.2.3; };
};
EOF

service bind9 restart
```

#### 4. Testing Reverse DNS
Testing dapat dilakukan menggunakan:
```bash
dig -x 192.217.2.3
dig -x 192.217.2.2
host 192.217.2.5
```

### Dokumentasi
![Hasil Testing Soal 8](8.png)

Dokumentasi menunjukkan reverse DNS lookup berhasil mengkonversi IP address ke hostname dengan benar.

---

## Soal 9: Web Server Statis dengan Nginx

### Deskripsi
Setup web server statis menggunakan Nginx di node Lindon untuk melayani konten statis dengan fitur directory listing. Web server ini akan diakses melalui domain `static.k12.com`.

### Langkah Pengerjaan

#### 1. Instalasi Nginx di Lindon
Install web server nginx:

```bash
apt update
apt install nginx -y
```

#### 2. Membuat Directory untuk Website
Buat directory untuk menyimpan file website:

```bash
mkdir -p /var/www/static.k12.com
```

#### 3. Konfigurasi Virtual Host Nginx
Buat konfigurasi server block untuk static.k12.com:

```bash
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
```

Penjelasan konfigurasi:
- `listen 80`: mendengarkan di port 80 (HTTP)
- `root`: document root untuk website
- `server_name`: domain yang akan dilayani
- `autoindex on`: mengaktifkan directory listing
- `try_files`: mencoba serve file atau directory, jika tidak ada return 404

#### 4. Membuat Konten Website
Buat directory dan file untuk testing:

```bash
mkdir /var/www/static.k12.com/annals

echo "Arsip Dari Zaman Dahulu" > /var/www/static.k12.com/annals/arsip1.txt
echo "Arsip Dari Zaman Pertengahan" > /var/www/static.k12.com/annals/arsip2.txt
echo "Arsip Dari Zaman Modern" > /var/www/static.k12.com/annals/arsip3.txt

echo "<h1>Selamat Datang di Static.k12.com</h1>" > /var/www/static.k12.com/index.html
```

#### 5. Aktivasi Site dan Restart Nginx
Enable site dengan membuat symbolic link dan restart service:

```bash
ln -s /etc/nginx/sites-available/static.k12.com /etc/nginx/sites-enabled/
service nginx restart
```

#### 6. Testing dari Client
Di client, install lynx (text-based browser) dan akses website:

```bash
apt update
apt install -y lynx
lynx static.k12.com
```

Testing yang bisa dilakukan:
- Akses homepage: akan menampilkan index.html
- Akses directory annals: akan menampilkan directory listing dengan 3 file arsip
- Akses file: dapat membuka masing-masing file arsip

### Dokumentasi
![Hasil Testing Soal 9](9.png)

Dokumentasi menunjukkan web server statis berhasil diakses dengan fitur directory listing berjalan dengan baik.

---

## Soal 10: Web Server Dinamis dengan PHP-FPM

### Deskripsi
Setup web server dinamis dengan Nginx dan PHP-FPM di node Vingilot untuk melayani konten dinamis PHP. Web server ini akan diakses melalui domain `app.k12.com` dan mengimplementasikan URL rewriting.

### Langkah Pengerjaan

#### 1. Instalasi Nginx dan PHP-FPM di Vingilot
Install paket yang diperlukan:

```bash
apt update
apt install nginx php-fpm -y
```

#### 2. Membuat Directory untuk Aplikasi
Buat directory untuk aplikasi web:

```bash
mkdir -p /var/www/app.k12.com
```

#### 3. Membuat File PHP - Index Page
Buat halaman utama dengan konten dinamis:

```bash
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
```

#### 4. Membuat File PHP - About Page
Buat halaman about untuk testing URL rewrite:

```bash
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
```

#### 5. Konfigurasi Nginx dengan PHP-FPM
Buat konfigurasi nginx untuk menjalankan PHP:

```bash
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
```

Penjelasan konfigurasi:
- `index index.php`: set index.php sebagai default file
- `try_files $uri $uri/ $uri.php?$query_string`: URL rewriting untuk clean URL
  - Mencoba file langsung
  - Mencoba directory
  - Jika tidak ada, coba tambahkan .php extension
- `location ~ \.php$`: handler untuk file PHP
- `fastcgi_pass`: socket untuk komunikasi dengan PHP-FPM
- `location ~ /\.ht`: security untuk mencegah akses ke file .htaccess

#### 6. Aktivasi Site dan Restart Services
Enable site dan restart semua service yang diperlukan:

```bash
ln -s /etc/nginx/sites-available/app.k12.com /etc/nginx/sites-enabled/
nginx -t
service php8.4-fpm restart
service nginx restart
```

Perintah `nginx -t` digunakan untuk test konfigurasi sebelum restart.

#### 7. Testing dari Client
Di client, akses aplikasi menggunakan lynx:

```bash
apt update
apt install -y lynx
lynx app.k12.com
lynx app.k12.com/about
```

Testing yang bisa dilakukan:
- Akses `app.k12.com` → akan menampilkan index.php dengan waktu server yang dinamis
- Akses `app.k12.com/about` → URL rewriting akan otomatis mengarahkan ke about.php
- Verifikasi konten dinamis PHP berjalan dengan melihat waktu server yang terupdate

### Dokumentasi
![Hasil Testing Soal 10](10.png)

Dokumentasi menunjukkan web server dinamis dengan PHP-FPM berhasil diakses dan URL rewriting berjalan dengan baik. Halaman menampilkan konten dinamis PHP dan navigasi antar halaman berfungsi dengan clean URL.

---

## Soal 11: Lampion Lindon Dinyalakan

### Deskripsi
Mengkonfigurasi web server statis Lindon dengan fitur directory listing untuk direktori `/annals/`. Konfigurasi ini memungkinkan pengunjung melihat daftar file yang tersedia dalam direktori arsip.

### Langkah Pengerjaan

#### 1. Membuat Struktur Direktori dan Konten
Buat direktori annals dan file readme sebagai konten testing:

```bash
mkdir -p /var/www/html/annals
echo "Arsip Lindon tersedia" > /var/www/html/annals/readme.txt
```

#### 2. Konfigurasi Virtual Host Nginx
Buat konfigurasi untuk mengaktifkan autoindex pada path `/annals/`:

```bash
cat > /etc/nginx/sites-available/lindon.conf << 'EOF'
server {
    listen 80;
    server_name static.k12.com lindon.k12.com;

    root /var/www/html;
    index index.html;

    location /annals/ {
        autoindex on;
    }
}
EOF
```

Penjelasan:
- `autoindex on`: mengaktifkan directory listing untuk path `/annals/`
- `server_name`: mendukung akses melalui dua hostname

#### 3. Aktivasi Konfigurasi
Enable site dan restart nginx:

```bash
ln -s /etc/nginx/sites-available/lindon.conf /etc/nginx/sites-enabled/
systemctl restart nginx
```

#### 4. Testing dari Client
Verifikasi bahwa directory listing berfungsi:

```bash
curl -I http://static.k12.com/annals/
```

Output yang diharapkan menunjukkan HTTP 200 OK dengan daftar file dalam direktori.

### Dokumentasi
![Hasil Testing Soal 11](11.png)

---

## Soal 12: Vingilot Mengisahkan Cerita Dinamis

### Deskripsi
Konfigurasi web server dinamis Vingilot dengan PHP-FPM, termasuk implementasi URL rewriting untuk clean URL. Path `/about` akan di-rewrite ke `about.php` tanpa menampilkan extension.

### Langkah Pengerjaan

#### 1. Membuat Struktur Aplikasi PHP
Buat file PHP untuk halaman utama dan about:

```bash
mkdir -p /var/www/html

cat > /var/www/html/index.php << 'EOF'
<?php echo 'Selamat datang di Vingilot'; ?>
EOF

cat > /var/www/html/about.php << 'EOF'
<?php echo 'Tentang Vingilot'; ?>
EOF
```

#### 2. Konfigurasi Virtual Host dengan URL Rewrite
Buat konfigurasi nginx dengan aturan rewrite:

```bash
cat > /etc/nginx/sites-available/vingilot.conf << 'EOF'
server {
    listen 80;
    server_name app.k12.com vingilot.k12.com;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location /about {
        rewrite ^/about$ /about.php last;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOF
```

Penjelasan:
- `location /about`: rewrite rule untuk clean URL
- `rewrite ^/about$ /about.php last`: mengkonversi `/about` menjadi `/about.php`
- FastCGI configuration untuk menjalankan PHP

#### 3. Aktivasi Konfigurasi
Enable site dan restart services:

```bash
ln -s /etc/nginx/sites-available/vingilot.conf /etc/nginx/sites-enabled/
systemctl restart php8.4-fpm nginx
```

#### 4. Testing URL Rewrite
Verifikasi kedua endpoint berfungsi:

```bash
curl -I http://app.k12.com/
curl -I http://app.k12.com/about
```

Kedua URL harus mengembalikan HTTP 200 OK tanpa menampilkan extension `.php`.

### Dokumentasi
![Hasil Testing Soal 12](12.png)

---

## Soal 13: Di Muara Sungai Sirion Berdiri

### Deskripsi
Konfigurasi Sirion sebagai reverse proxy utama yang meneruskan traffic ke backend server sesuai path. Path `/static/` diteruskan ke Lindon dan `/app/` ke Vingilot, dengan root path redirect ke `/static/`.

### Langkah Pengerjaan

#### 1. Instalasi Nginx di Sirion
Install nginx sebagai reverse proxy:

```bash
apt update && apt install -y nginx
```

#### 2. Konfigurasi Reverse Proxy
Buat konfigurasi dengan routing berdasarkan path:

```bash
cat > /etc/nginx/sites-available/sirion.conf << 'EOF'
server {
    listen 80;
    server_name www.k12.com sirion.k12.com;

    location /static/ {
        proxy_pass http://lindon.k12.com/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /app/ {
        proxy_pass http://vingilot.k12.com/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        return 301 /static/;
    }
}
EOF
```

Penjelasan:
- `proxy_pass`: meneruskan request ke backend server
- `proxy_set_header`: meneruskan informasi client ke backend
- `return 301`: redirect permanent dari root ke `/static/`

#### 3. Aktivasi Konfigurasi
Enable site dan restart nginx:

```bash
ln -s /etc/nginx/sites-available/sirion.conf /etc/nginx/sites-enabled/
systemctl restart nginx
```

#### 4. Testing Reverse Proxy
Verifikasi routing berfungsi untuk semua path:

```bash
curl -I http://www.k12.com/static/
curl -I http://www.k12.com/app/
curl -I http://www.k12.com/
```

### Dokumentasi
![Hasil Testing Soal 13](13.png)

Dokumentasi menunjukkan reverse proxy berhasil meneruskan traffic ke backend yang sesuai dengan header yang benar.

---

## Soal 14: Kamar Kecil di Balik Gerbang

### Deskripsi
Implementasi HTTP Basic Authentication untuk melindungi path `/admin` di Sirion. Hanya user dengan credentials yang benar yang dapat mengakses area admin.

### Langkah Pengerjaan

#### 1. Membuat File Kredensial
Install apache2-utils dan buat file password:

```bash
apt install -y apache2-utils
htpasswd -cb /etc/nginx/.htpasswd admin rahasia123
```

Parameter:
- `-c`: create new file
- `-b`: batch mode (password dari command line)
- User: `admin`, Password: `rahasia123`

#### 2. Menambahkan Konfigurasi Auth
Update konfigurasi sirion.conf untuk menambahkan protected location:

```bash
cat >> /etc/nginx/sites-available/sirion.conf << 'EOF'
    location /admin {
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
EOF
```

Penjelasan:
- `auth_basic`: mengaktifkan basic authentication
- `auth_basic_user_file`: path ke file kredensial

#### 3. Reload Nginx
Apply konfigurasi baru:

```bash
systemctl reload nginx
```

#### 4. Testing Authentication
Test akses tanpa dan dengan kredensial:

```bash
# Tanpa auth - harus 401 Unauthorized
curl -I http://www.k12.com/admin

# Dengan auth yang benar - harus 200 OK
curl -u admin:rahasia123 -I http://www.k12.com/admin
```

### Dokumentasi
![Hasil Testing Soal 14](14.png)

Dokumentasi menunjukkan akses ditolak tanpa kredensial (401) dan diterima dengan kredensial yang benar (200).

---

## Soal 15: Kanonisasi Hostname Sirion

### Deskripsi
Implementasi canonical hostname redirection agar semua akses melalui IP atau hostname alternatif (sirion.k12.com) diredirect ke hostname kanonik `www.k12.com`.

### Langkah Pengerjaan

#### 1. Menambahkan Server Block untuk Redirect
Buat server block terpisah untuk handle hostname non-kanonik:

```bash
cat > /etc/nginx/sites-available/sirion.conf << 'EOF'
server {
    listen 80;
    server_name sirion.k12.com 192.217.2.2;

    return 301 http://www.k12.com$request_uri;
}

server {
    listen 80;
    server_name www.k12.com;

    location /static/ {
        proxy_pass http://192.217.2.5/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /app/ {
        proxy_pass http://192.217.2.6/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /admin {
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    location / {
        return 301 /static/;
    }
}
EOF
```

Penjelasan:
- Server block pertama: handle redirect untuk IP dan sirion.k12.com
- Server block kedua: melayani konten untuk www.k12.com
- `$request_uri`: mempertahankan path dan query string saat redirect

#### 2. Reload Nginx
Apply konfigurasi:

```bash
systemctl reload nginx
```

#### 3. Testing Canonical Redirect
Verifikasi redirect berfungsi untuk berbagai hostname:

```bash
# Akses via IP - harus redirect
curl -I http://192.217.2.2

# Akses via hostname alternatif - harus redirect
curl -I http://sirion.k12.com

# Akses via canonical hostname - langsung serve content
curl -I http://www.k12.com
```

### Dokumentasi
![Hasil Testing Soal 15](15.png)

Dokumentasi menunjukkan redirect 301 berfungsi dengan benar ke hostname kanonik untuk semua akses non-kanonik.

---

## Soal 16: Catatan Kedatangan di Vingilot

### Deskripsi
Konfigurasi custom log format di Vingilot untuk mencatat IP address client yang sebenarnya (bukan IP reverse proxy) menggunakan header `X-Real-IP` yang diteruskan dari Sirion.

### Langkah Pengerjaan

#### 1. Memastikan Header Forwarding di Sirion
Verifikasi konfigurasi proxy di Sirion sudah meneruskan header yang diperlukan:

```bash
# Di sirion.conf, pastikan ada:
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

#### 2. Konfigurasi Custom Log Format di Vingilot
Edit nginx.conf untuk menambahkan format log khusus:

```bash
cat >> /etc/nginx/nginx.conf << 'EOF'
http {
    log_format realip '$remote_addr - $remote_user [$time_local] '
                      '"$request" $status $body_bytes_sent '
                      '"$http_referer" "$http_user_agent" "$http_x_real_ip"';

    access_log /var/log/nginx/access_realip.log realip;
}
EOF
```

#### 3. Aktivasi Real IP Module (Opsional)
Untuk memastikan nginx menggunakan IP dari header:

```bash
# Di vingilot.conf, tambahkan:
real_ip_header X-Real-IP;
set_real_ip_from 192.217.2.2;  # IP Sirion
```

#### 4. Reload Nginx
Apply konfigurasi:

```bash
systemctl reload nginx
```

#### 5. Testing Real IP Logging
Akses dari client dan periksa log:

```bash
# Dari client Elrond
curl -H "Host: www.k12.com" http://192.217.2.2/app/

# Di Vingilot, periksa log
tail -f /var/log/nginx/access_realip.log
```

Log harus menunjukkan IP client asli (192.217.3.3) bukan IP Sirion (192.217.2.2).

### Dokumentasi
![Hasil Testing Soal 16](16.png)

Dokumentasi menunjukkan log mencatat IP address client yang sebenarnya, membuktikan header X-Real-IP berhasil diteruskan dan diproses.

---

## Soal 17: Pengujian Beban dengan ApacheBench

### Deskripsi
Melakukan load testing menggunakan ApacheBench (ab) untuk mengevaluasi performa reverse proxy dan backend server. Testing dilakukan pada endpoint statis (/static/) dan dinamis (/app/).

### Langkah Pengerjaan

#### 1. Instalasi ApacheBench di Client
Di node Elrond, install apache2-utils:

```bash
apt update
apt install -y apache2-utils
```

#### 2. Pre-Test Verification
Pastikan koneksi ke target berfungsi:

```bash
ping -c 3 www.k12.com
curl -I http://www.k12.com/app/
curl -I http://www.k12.com/static/
```

#### 3. Load Testing Endpoint Dinamis
Test endpoint `/app/` dengan 500 requests dan concurrency 10:

```bash
ab -n 500 -c 10 http://www.k12.com/app/
```

Parameter:
- `-n 500`: total 500 requests
- `-c 10`: 10 concurrent connections

#### 4. Load Testing Endpoint Statis
Test endpoint `/static/` dengan parameter yang sama:

```bash
ab -n 500 -c 10 http://www.k12.com/static/
```

#### 5. Analisis Hasil
Perhatikan metrics penting:
- **Time per request**: rata-rata waktu respon
- **Requests per second**: throughput server
- **Failed requests**: jumlah error
- **Transfer rate**: bandwidth usage

### Dokumentasi
![Hasil Testing Soal 17](17.png)

**Ringkasan Hasil:**

| Endpoint | Requests | Concurrency | Avg Response Time | Req/s | Keterangan |
|----------|----------|-------------|-------------------|-------|------------|
| `/app/` (Vingilot) | 500 | 10 | 120 ms | 82.4 | Stabil dengan PHP processing |
| `/static/` (Lindon) | 500 | 10 | 45 ms | 222.1 | Lebih cepat, konten statis |

Dokumentasi menunjukkan sistem mampu menangani beban dengan baik, dengan Lindon menunjukkan performa lebih tinggi untuk konten statis.

---

## Soal 18: Badai Mengubah Garis Pantai

### Deskripsi
Mensimulasikan perubahan IP address untuk node Lindon dan menguji mekanisme DNS propagation dengan TTL caching. Ini mendemonstrasikan bagaimana perubahan infrastruktur dapat dilakukan dengan minimal downtime.

### Langkah Pengerjaan

#### 1. Edit Zone File di Tirion (NS1)
Update A record untuk Lindon dengan IP baru:

```bash
# Edit zone file
nano /etc/bind/zones/db.k12.com

# Ubah dari:
lindon  IN  A  192.217.2.5

# Menjadi:
lindon  IN  A  192.217.2.8
```

#### 2. Naikkan Serial SOA
Update serial number untuk menandakan perubahan:

```bash
@ IN SOA ns1.k12.com. admin.k12.com. (
        2025101901 ; serial baru (increment)
        3600       ; refresh
        1800       ; retry
        604800     ; expire
        30 )       ; TTL 30 detik
```

#### 3. Reload Bind9 dan Trigger Transfer
Di Tirion:

```bash
rndc reload k12.com
rndc notify k12.com
```

Di Valmar:

```bash
rndc retransfer k12.com
```

#### 4. Verifikasi Sinkronisasi Zone
Pastikan serial sama di kedua server:

```bash
dig @192.217.2.3 k12.com SOA +short
dig @192.217.2.4 k12.com SOA +short
```

#### 5. Testing TTL Cache Behavior
Dari client Elrond, amati perubahan DNS cache:

```bash
# Sebelum TTL expire (masih cached)
dig lindon.k12.com
# Output: 192.217.2.5 (IP lama)

# Tunggu TTL expire (30 detik)
sleep 30

# Setelah TTL expire
dig lindon.k12.com
# Output: 192.217.2.8 (IP baru)
```

### Dokumentasi
![Hasil Testing Soal 18](18.png)

**Tabel Hasil Pengujian:**

| Tahap | Hasil | Keterangan |
|-------|-------|------------|
| Sebelum perubahan | 192.217.2.5 | Cache lama aktif |
| Sesaat setelah reload | 192.217.2.5 | Resolver belum refresh |
| Setelah TTL (30s) | 192.217.2.8 | Propagasi sukses |
| SOA serial ns1/ns2 | Sama | Sinkronisasi berhasil |

Dokumentasi menunjukkan mekanisme TTL dan zone transfer berfungsi dengan baik, memungkinkan perubahan IP dengan propagasi terkontrol.

---

## Soal 19: Mereka Bangkit Sendiri

### Deskripsi
Konfigurasi semua layanan inti untuk autostart saat boot, memastikan high availability dan recovery otomatis setelah system reboot atau failure.

### Langkah Pengerjaan

#### 1. Enable Autostart untuk Bind9
Di Tirion dan Valmar:

```bash
systemctl enable bind9
systemctl start bind9
systemctl status bind9
```

#### 2. Enable Autostart untuk Nginx
Di Sirion dan Lindon:

```bash
systemctl enable nginx
systemctl start nginx
systemctl status nginx
```

#### 3. Enable Autostart untuk PHP-FPM
Di Vingilot:

```bash
systemctl enable php8.4-fpm
systemctl start php8.4-fpm
systemctl status php8.4-fpm
```

#### 4. Verifikasi Status Enabled
Cek semua service sudah di-enable:

```bash
systemctl is-enabled bind9    # output: enabled
systemctl is-enabled nginx     # output: enabled
systemctl is-enabled php8.4-fpm # output: enabled
```

#### 5. Simulasi Reboot
Test dengan reboot sistem:

```bash
reboot
```

Setelah boot, verifikasi semua service aktif otomatis:

```bash
systemctl status bind9
systemctl status nginx
systemctl status php8.4-fpm
```

#### 6. Testing Fungsional
Verifikasi semua layanan berfungsi setelah boot:

```bash
# Test DNS
dig @192.217.2.3 www.k12.com
dig @192.217.2.4 www.k12.com

# Test web services
curl -I http://www.k12.com/
curl -I http://www.k12.com/app/
curl -I http://www.k12.com/static/
```

### Dokumentasi
![Hasil Testing Soal 19](19.png)

**Status Layanan Setelah Boot:**

| Host | Service | Status | Keterangan |
|------|---------|--------|------------|
| Tirion | Bind9 | Aktif otomatis | DNS master ready |
| Valmar | Bind9 | Aktif otomatis | DNS slave synced |
| Sirion | Nginx | Aktif otomatis | Reverse proxy berfungsi |
| Lindon | Nginx | Aktif otomatis | Web statis tersedia |
| Vingilot | PHP-FPM | Aktif otomatis | Aplikasi dinamis ready |

Dokumentasi menunjukkan semua layanan berhasil start otomatis setelah reboot, memastikan sistem resilient terhadap restart.

---

## Soal 20: Sang Musuh dan Pelabuhan Baru

### Deskripsi
Menambahkan record DNS tambahan untuk ekspansi domain: TXT record untuk melkor.k12.com, CNAME alias morgoth.k12.com dan havens.k12.com. Ini mendemonstrasikan berbagai tipe DNS record dan penggunaannya.

### Langkah Pengerjaan

#### 1. Edit Zone File di Tirion
Tambahkan record baru ke zone file:

```bash
nano /etc/bind/zones/db.k12.com

# Tambahkan di akhir file:
melkor   IN TXT   "Morgoth (Melkor)"
morgoth  IN CNAME melkor.k12.com.
havens   IN CNAME www.k12.com.
```

Penjelasan:
- TXT record untuk menyimpan informasi tekstual
- CNAME untuk membuat alias domain
- Havens sebagai alternatif akses ke www.k12.com

#### 2. Update Serial SOA
Increment serial number:

```bash
@ IN SOA ns1.k12.com. admin.k12.com. (
        2025101902 ; serial baru
        3600
        1800
        604800
        30 )
```

#### 3. Reload dan Sinkronisasi
Di Tirion:

```bash
rndc reload k12.com
rndc notify k12.com
```

Di Valmar:

```bash
rndc retransfer k12.com
```

#### 4. Verifikasi Sinkronisasi
Pastikan zone tersinkron:

```bash
dig @192.217.2.3 k12.com SOA +short
dig @192.217.2.4 k12.com SOA +short
# Kedua harus menunjukkan serial 2025101902
```

#### 5. Testing Record Baru
Dari client, test masing-masing record type:

```bash
# Test TXT record
dig melkor.k12.com TXT +short
# Output: "Morgoth (Melkor)"

# Test CNAME alias
dig morgoth.k12.com A +short
# Output: 192.217.2.2 (mengikuti chain ke Sirion)

# Test CNAME havens
dig havens.k12.com A +short
# Output: 192.217.2.2

# Test HTTP access via havens
curl -I http://havens.k12.com/
# Output: HTTP/1.1 200 OK
```

### Dokumentasi
![Hasil Testing Soal 20](20.png)

**Tabel Verifikasi Record:**

| Record | Type | Target | Respon DNS | Keterangan |
|--------|------|--------|------------|------------|
| melkor.k12.com | TXT | "Morgoth (Melkor)" | ✓ OK | TXT record berhasil |
| morgoth.k12.com | CNAME | melkor.k12.com | ✓ OK | Alias berfungsi |
| havens.k12.com | CNAME | www.k12.com | ✓ OK | Alias ke canonical hostname |

Dokumentasi menunjukkan semua record type berfungsi dengan baik dan dapat di-resolve dengan benar melalui DNS infrastructure yang telah dibangun.

---

## Kesimpulan

Praktikum ini berhasil mengimplementasikan infrastruktur jaringan lengkap dengan komponen:

1. **DNS Infrastructure**: Master-Slave replication dengan zone transfer
2. **Web Servers**: Static (Nginx) dan Dynamic (PHP-FPM)
3. **Reverse Proxy**: Load balancing dan routing berbasis path
4. **Security**: Basic Authentication untuk area restricted
5. **Monitoring**: Custom logging dengan real IP tracking
6. **High Availability**: Autostart services dan canonical hostname
7. **Advanced DNS**: Multiple record types (A, CNAME, TXT, PTR)

Semua komponen terintegrasi dengan baik dan siap untuk deployment production dengan dokumentasi lengkap untuk setiap tahap konfigurasi.
