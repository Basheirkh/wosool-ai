#!/bin/bash
# Server setup script for DigitalOcean
# Run this script on the server via DigitalOcean console or SSH

set -e

echo "=== Setting up server ==="

# Add SSH key to authorized_keys (replace with your actual public key)
SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCy27WnSeaB9WaQpZIOL7/chYO57EqVOZ+EMtk1iQ5dXcvdUoCI8DvQwYc8R5/gJf6XED5WDO2YHgTxGZvSoXqYTUUosAZEXge7xCxy6+js7lB3YlfK19OWOFra9c//QcOziYarkxv0sizHuW8Js707jrpzE2PuV0LVW7OxLQtF6gIm/+ULH3DQvByozP4zY7jM/p+M26CCCp/RerYkqR8P/z38L0AH38DDfDYsVk4ScaoXkeBBLnHfJKoKff7x3tYbfMfVflMoixwa6fmKKoC8P+kfesuVYttdelID5dQVEwlTHVPO55HjAOUgVuQ/iFVO3rWsm47J9meelJP976wXXJsvbK+GMuA3ybhb6GwooyWjaAhOiWDYaJqQkYB+hxsgCZW8JohIRW2OYFj9cNjjHqZhgV9NCNzrQvbVfj3dNrsGCN4YwScqQ0SoVIIUywQf98fpX4plSDRARVgA5CgkGXG86OgW8u7I+kCA6MKDIoppUzuUZNUz+NQw1idpWr8dhspkQ2lIThMkHAPqJepuDhHdh4bgfJ1DPnm5NbZmLpds+uq4SdRSFB1bYrxOkbBUXAZvPMCgFc7X1OtJaAA6m2JQgFDlZ7SVMtSrO6coGYw4ED+MJV9tq57XUKaZnH6zSYzMoZ3hFA8KNI7Zf2DWeT+bafuLalC89xMeRNDMgw== ubuntu@ubuntu-Dell-G16-7630"

# Ensure .ssh directory exists
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Add key to authorized_keys if not already present
if ! grep -q "$SSH_PUBLIC_KEY" /root/.ssh/authorized_keys 2>/dev/null; then
    echo "$SSH_PUBLIC_KEY" >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo "✓ SSH key added to authorized_keys"
else
    echo "✓ SSH key already in authorized_keys"
fi

# Clean up any existing project files
cd /root
if [ -d "twenty-crm-enterprise-v1" ]; then
    echo "Removing existing project directory..."
    rm -rf twenty-crm-enterprise-v1
fi

# Install git if not already installed
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    apt-get update -qq
    apt-get install -y git
fi

# Clone the repository
echo "Cloning repository..."
git clone https://github.com/Basheirkh/twenty-crm-enterprise-v1.git
cd twenty-crm-enterprise-v1

echo "=== Setup complete ==="
echo "Repository cloned to: /root/twenty-crm-enterprise-v1"
echo "You can now SSH to the server and access the project."

