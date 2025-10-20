#!/bin/bash
set -e

echo "=== Setup Topologi K12 ==="

# Create GNS3 router (Sirion)
echo "[*] Creating router Sirion..."
# Assuming GNS3 CLI or API is available
# This would typically be done through GNS3 GUI
gns3 create router --name sirion --template cisco-router

# Create Docker containers for all nodes
echo "[*] Creating Docker containers..."

# DNS Servers
docker run -d --name tirion \
    --hostname tirion.k12.com \
    --network none \
    --cap-add=NET_ADMIN \
    debian:bullseye sleep infinity

docker run -d --name valmar \
    --hostname valmar.k12.com \
    --network none \
    --cap-add=NET_ADMIN \
    debian:bullseye sleep infinity

# Web Servers
docker run -d --name lindon \
    --hostname lindon.k12.com \
    --network none \
    --cap-add=NET_ADMIN \
    debian:bullseye sleep infinity

docker run -d --name vingilot \
    --hostname vingilot.k12.com \
    --network none \
    --cap-add=NET_ADMIN \
    debian:bullseye sleep infinity

# Clients - Subnet 1
docker run -d --name earendil \
    --hostname earendil.k12.com \
    --network none \
    --cap-add=NET_ADMIN \
    debian:bullseye sleep infinity

docker run -d --name elwing \
    --hostname elwing.k12.com \
    --network none \
    --cap-add=NET_ADMIN \
    debian:bullseye sleep infinity

# Clients - Subnet 3
docker run -d --name cirdan \
    --hostname cirdan.k12.com \
    --network none \
    --cap-add=NET_ADMIN \
    debian:bullseye sleep infinity

docker run -d --name elrond \
    --hostname elrond.k12.com \
    --network none \
    --cap-add=NET_ADMIN \
    debian:bullseye sleep infinity

docker run -d --name maglor \
    --hostname maglor.k12.com \
    --network none \
    --cap-add=NET_ADMIN \
    debian:bullseye sleep infinity

echo "[✓] All containers created"

# Setup network interfaces
echo "[*] Setting up network interfaces..."

# Helper function to setup network
setup_network() {
    local container=$1
    local ip=$2
    local gateway=$3
    
    docker exec $container bash -c "
        apt update -qq
        apt install -y iproute2 iputils-ping dnsutils curl nano wget
        ip addr add $ip/24 dev eth0
        ip link set eth0 up
        ip route add default via $gateway
        echo 'nameserver 192.168.122.1' > /etc/resolv.conf
        echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
    "
}

# Setup Subnet 1 (192.217.1.0/24)
echo "  [*] Configuring Subnet 1..."
setup_network earendil 192.217.1.2 192.217.1.1
setup_network elwing 192.217.1.3 192.217.1.1

# Setup Subnet 2 (192.217.2.0/24)
echo "  [*] Configuring Subnet 2..."
setup_network tirion 192.217.2.3 192.217.2.2
setup_network valmar 192.217.2.4 192.217.2.2
setup_network lindon 192.217.2.5 192.217.2.2
setup_network vingilot 192.217.2.6 192.217.2.2

# Setup Subnet 3 (192.217.3.0/24)
echo "  [*] Configuring Subnet 3..."
setup_network cirdan 192.217.3.2 192.217.3.1
setup_network elrond 192.217.3.3 192.217.3.1
setup_network maglor 192.217.3.4 192.217.3.1

echo "[✓] Network interfaces configured"

# Run host-specific setup scripts
echo "[*] Running host-specific configurations..."

# Create host directory if not exists
mkdir -p ./host

exit 1

# Generate and run setup scripts for each host
bash ./host/tirion.sh
bash ./host/valmar.sh
bash ./host/lindon.sh
bash ./host/vingilot.sh
bash ./host/sirion.sh

# ============================================
# Update DNS on all clients
# ============================================

echo "[*] Updating DNS resolvers on all nodes..."

for host in earendil elwing cirdan elrond maglor lindon vingilot sirion; do
    docker exec $host bash -c '
        cat > /etc/resolv.conf << "EOF"
nameserver 192.217.2.3
nameserver 192.217.2.4
nameserver 192.168.122.1
EOF
    '
done

echo "[✓] All host configurations completed!"

echo "[✓] Host-specific configurations completed"
echo ""
echo "=== Setup Complete ==="
echo "Access the nodes with: docker exec -it <hostname> bash"
echo ""
echo "Available hosts:"
echo "  DNS:     tirion, valmar"
echo "  Web:     lindon, vingilot, sirion"
echo "  Clients: earendil, elwing, cirdan, elrond, maglor"

