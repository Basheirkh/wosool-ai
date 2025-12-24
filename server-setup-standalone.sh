#!/bin/bash
# Standalone Cloud Server Setup Script for wosool-ai
# Run this script directly on the server: bash server-setup-standalone.sh

set -e

echo "🚀 Starting Wosool AI Server Setup"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Repository URL
REPO_URL="https://github.com/Basheirkh/wosool-ai.git"
PROJECT_DIR="/root/wosool-ai"

# Step 1: Install required packages
echo -e "${YELLOW}[1/6] Installing required packages...${NC}"
apt-get update -qq
apt-get install -y git curl openssl

# Step 2: Install Docker
echo -e "${YELLOW}[2/6] Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}✓ Docker installed${NC}"
else
    echo -e "${GREEN}✓ Docker is already installed${NC}"
fi

# Step 3: Install Docker Compose
echo -e "${YELLOW}[3/6] Installing Docker Compose...${NC}"
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✓ Docker Compose is already installed${NC}"
fi

# Step 4: Clone repository
echo -e "${YELLOW}[4/6] Cloning repository...${NC}"
if [ -d "$PROJECT_DIR" ]; then
    echo "Removing existing project directory..."
    rm -rf "$PROJECT_DIR"
fi

git clone "$REPO_URL" "$PROJECT_DIR"
cd "$PROJECT_DIR"
echo -e "${GREEN}✓ Repository cloned${NC}"

# Step 5: Create .env file if it doesn't exist
echo -e "${YELLOW}[5/6] Setting up environment...${NC}"
if [ ! -f .env ]; then
    echo "Creating .env file..."
    POSTGRES_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    JWT_SEC=$(openssl rand -base64 32)
    ADMIN_KEY=$(openssl rand -base64 32)
    WEBHOOK_SEC=$(openssl rand -base64 32)
    
    cat > .env << EOF
# Database Configuration
POSTGRES_ADMIN_USER=postgres
POSTGRES_PASSWORD=${POSTGRES_PASS}

# Application URLs
APP_URL=http://167.99.20.94
CRM_BASE_URL=api.wosool.ai

# Security Secrets
JWT_SECRET=${JWT_SEC}
SUPER_ADMIN_KEY=${ADMIN_KEY}
SALLA_WEBHOOK_SECRET=${WEBHOOK_SEC}

# Salla Integration (Update with your credentials)
SALLA_CLIENT_ID=your_salla_client_id
SALLA_CLIENT_SECRET=your_salla_client_secret

# Clerk Integration (Update with your credentials)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
CLERK_SECRET_KEY=your_clerk_secret_key
CLERK_WEBHOOK_SECRET=your_clerk_webhook_secret

# Grafana
GRAFANA_ADMIN_PASSWORD=admin

# PgAdmin
PGADMIN_EMAIL=admin@example.com
PGADMIN_PASSWORD=admin

# Twenty CRM
DISABLE_DB_MIGRATIONS=false
DISABLE_CRON_JOBS_REGISTRATION=false
TWENTY_ADMIN_TOKEN=
BOOTSTRAP_SECRET=
TWENTY_BASE_URL=http://localhost:3000
TWENTY_API_KEY=
EOF
    echo -e "${GREEN}✓ .env file created${NC}"
    echo -e "${YELLOW}⚠️  IMPORTANT: Update Salla and Clerk credentials in .env${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Step 6: Deploy application
echo -e "${YELLOW}[6/6] Deploying application...${NC}"
chmod +x deploy-server.sh
./deploy-server.sh

echo ""
echo -e "${GREEN}============================================"
echo "✓ Server Setup Complete!"
echo "============================================${NC}"
echo ""
echo "Repository: $PROJECT_DIR"
echo "Services are starting up. Access points:"
echo "  - Main Application: http://167.99.20.94"
echo "  - Grafana: http://167.99.20.94:3002"
echo "  - Prometheus: http://167.99.20.94:9092"
echo "  - PgAdmin: http://167.99.20.94:5050"
echo ""
echo "To check service status:"
echo "  cd $PROJECT_DIR && docker compose ps"
echo ""
echo "To view logs:"
echo "  cd $PROJECT_DIR && docker compose logs -f"
echo ""

