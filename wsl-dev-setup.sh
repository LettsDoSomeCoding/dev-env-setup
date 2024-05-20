#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Git
sudo apt install -y git

# Install OpenSSH Client
sudo apt install -y openssh-client

# Install Docker
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce

# Add the current user to the docker group
sudo usermod -aG docker $USER

# Create code directory in the user's home directory
mkdir -p ~/code

# Print completion message
echo "Git, OpenSSH Client, Docker installed, and code directory created in the home directory."
echo "Please log out and log back in to apply Docker group changes, or restart your WSL instance."
