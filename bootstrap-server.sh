#!/bin/bash
# Bootstrap script to setup SSH key and deploy wosool-ai
# This runs on server startup via DigitalOcean user-data

set -e

SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCy27WnSeaB9WaQpZIOL7/chYO57EqVOZ+EMtk1iQ5dXcvdUoCI8DvQwYc8R5/gJf6XED5WDO2YHgTxGZvSoXqYTUUosAZEXge7xCxy6+js7lB3YlfK19OWOFra9c//QcOziYarkxv0sizHuW8Js707jrpzE2PuV0LVW7OxLQtF6gIm/+ULH3DQvByozP4zY7jM/p+M26CCCp/RerYkqR8P/z38L0AH38DDfDYsVk4ScaoXkeBBLnHfJKoKff7x3tYbfMfVflMoixwa6fmKKoC8P+kfesuVYttdelID5dQVEwlTHVPO55HjAOUgVuQ/iFVO3rWsm47J9meelJP976wXXJsvbK+GMuA3ybhb6GwooyWjaAhOiWDYaJqQkYB+hxsgCZW8JohIRW2OYFj9cNjjHqZhgV9NCNzrQvbVfj3dNrsGCN4YwScqQ0SoVIIUywQf98fpX4plSDRARVgA5CgkGXG86OgW8u7I+kCA6MKDIoppUzuUZNUz+NQw1idpWr8dhspkQ2lIThMkHAPqJepuDhHdh4bgfJ1DPnm5NbZmLpds+uq4SdRSFB1bYrxOkbBUXAZvPMCgFc7X1OtJaAA6m2JQgFDlZ7SVMtSrO6coGYw4ED+MJV9tq57XUKaZnH6zSYzMoZ3hFA8KNI7Zf2DWeT+bafuLalC89xMeRNDMgw== ubuntu@ubuntu-Dell-G16-7630"

# Add SSH key
mkdir -p /root/.ssh
chmod 700 /root/.ssh
if ! grep -q "$SSH_PUBLIC_KEY" /root/.ssh/authorized_keys 2>/dev/null; then
    echo "$SSH_PUBLIC_KEY" >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# Run the setup script
curl -fsSL https://raw.githubusercontent.com/Basheirkh/wosool-ai/master/server-setup-standalone.sh | bash

