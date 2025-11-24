#!/bin/bash
# User Data Script for Frontend Server (Uptime Kuma)
# This runs automatically when the server first starts

LOGFILE="/var/log/user-data.log"
exec > >(tee -a ${LOGFILE}) 2>&1

echo "===== Frontend Server Setup Started at $(date) ====="

# Wait for dpkg lock to be released
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "Waiting for dpkg lock..."
  sleep 5
done

# Update system
echo "Updating system..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y || { echo "apt-get update failed, retrying..."; sleep 10; apt-get update -y; }

# Install basic dependencies
echo "Installing basic packages..."
apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https

# Add Docker GPG key
echo "Adding Docker repository..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg || echo "GPG key download failed"

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
echo "Installing Docker..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker
echo "Starting Docker..."
systemctl enable docker
systemctl start docker
sleep 5

# Deploy Uptime Kuma
echo "Deploying Uptime Kuma..."
mkdir -p /opt/uptime-kuma

cat > /opt/uptime-kuma/docker-compose.yml <<'EOF'
version: '3.8'

services:
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptime-kuma
    restart: always
    ports:
      - "80:3001"
    volumes:
      - uptime-kuma-data:/app/data

volumes:
  uptime-kuma-data:
EOF

# Start Uptime Kuma
cd /opt/uptime-kuma
docker compose up -d || docker-compose up -d

echo "===== Frontend Server Setup Completed at $(date) ====="
docker ps
