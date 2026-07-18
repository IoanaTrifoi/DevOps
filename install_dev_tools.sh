#!/bin/bash
set -e

echo "=== Updating package index ==="
sudo apt-get update -y

echo "=== Checking and installing Docker ==="
if ! command -v docker >/dev/null 2>&1; then
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  echo "Docker installed"
else
  echo "Docker is already installed"
fi

echo "=== Checking and installing Docker Compose ==="
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  echo "Docker Compose (v2) is already installed"
elif command -v docker-compose >/dev/null 2>&1; then
  echo "Docker Compose (v1) is already installed"
else
  sudo apt-get install -y docker-compose-plugin || sudo apt-get install -y docker-compose
  echo "Docker Compose installed"
fi

echo "=== Checking and installing Python ==="
if ! command -v python3 >/dev/null 2>&1; then
  sudo apt-get install -y python3 python3-pip
  echo "Python installed"
else
  echo "Python is already installed: $(python3 -V)"
  command -v pip3 >/dev/null 2>&1 || sudo apt-get install -y python3-pip
fi

echo "=== Checking and installing Django ==="
if ! python3 -m django --version >/dev/null 2>&1; then
  # install for the current user; if the script is run via sudo,
  # perform the installation as the real user
  RUN_AS="${SUDO_USER:-$USER}"
  sudo -u "$RUN_AS" pip3 install --user --break-system-packages "Django>=4"
  sudo -u "$RUN_AS" python3 -m django --version
  echo "Django installed (user-site)"
else
  echo "Django is already installed: $(python3 -m django --version)"
fi

echo "=== All tools are ready! ==="
