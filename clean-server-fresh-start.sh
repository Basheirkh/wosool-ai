#!/bin/bash
# Complete server cleanup and fresh start with proper service mapping
# This script will clean everything and set up the server from scratch

set -e

cd /root/wosool-ai

echo "========================================="
echo "Complete Server Cleanup & Fresh Start"
echo "========================================="
echo ""
echo "⚠️  WARNING: This will delete ALL containers, volumes, and images!"
echo "Press Ctrl+C within 5 seconds to cancel..."
sleep 5

echo ""
echo "Step 1: Stopping all containers..."
docker-compose down -v 2>/dev/null || true

echo ""
echo "Step 2: Removing all containers..."
docker ps -aq | xargs -r docker rm -f 2>/dev/null || true

echo ""
echo "Step 3: Removing all volumes..."
docker volume ls -q | grep -E "wosool|ent-" | xargs -r docker volume rm 2>/dev/null || true
docker volume ls -q | xargs -r docker volume rm 2>/dev/null || true

echo ""
echo "Step 4: Removing project images..."
docker images | grep -E "wosool-ai" | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true

echo ""
echo "Step 5: Cleaning up unused Docker resources..."
docker system prune -af --volumes

echo ""
echo "Step 6: Pulling latest code from GitHub..."
git pull

echo ""
echo "Step 7: Verifying .env file exists and has APP_SECRET..."
if [ ! -f .env ]; then
    echo "⚠️  .env file not found! Creating it..."
    bash create-env.sh
else
    # Check if APP_SECRET exists
    if ! grep -q "^APP_SECRET=" .env; then
        echo "⚠️  APP_SECRET not found in .env, adding it..."
        if grep -q "^JWT_SECRET=" .env; then
            JWT_VAL=$(grep "^JWT_SECRET=" .env | cut -d'=' -f2)
            echo "APP_SECRET=${JWT_VAL}" >> .env
        else
            APP_SEC=$(openssl rand -base64 32)
            echo "APP_SECRET=${APP_SEC}" >> .env
        fi
    fi
    echo "✓ .env file is ready"
fi

echo ""
echo "Step 8: Building images from scratch (this will take time)..."
docker-compose build --no-cache

echo ""
echo "Step 9: Starting services..."
docker-compose up -d

echo ""
echo "Step 10: Waiting for services to be healthy..."
sleep 10

echo ""
echo "========================================="
echo "Clean reset complete!"
echo "========================================="
echo ""
echo "Service Mapping:"
echo "  Frontend:        api.wosool.ai/ → Twenty CRM (port 3000)"
echo "  Backend API:     api.wosool.ai/api/* → Tenant Manager (port 3001)"
echo "  Salla API:       api.wosool.ai/api/salla/* → Salla Orchestrator (port 8000)"
echo "  GraphQL:         api.wosool.ai/graphql → Twenty CRM (port 3000)"
echo "  REST API:        api.wosool.ai/rest/* → Twenty CRM (port 3000)"
echo "  Admin/Grafana:   api.wosool.ai/admin/grafana/* → Grafana (port 3002)"
echo "  Admin/Prometheus: api.wosool.ai/admin/prometheus/* → Prometheus (port 9090)"
echo "  Admin/PgAdmin:   api.wosool.ai/admin/pgadmin/* → PgAdmin (port 80)"
echo "  Admin/Redis:     api.wosool.ai/admin/redis/* → Redis Commander (port 8081)"
echo ""
echo "Monitor progress with:"
echo "  docker logs -f ent-twenty-crm"
echo "  docker logs -f ent-tenant-manager"
echo "  docker logs -f ent-nginx"
echo ""
echo "Check status with:"
echo "  docker-compose ps"
echo "  curl http://api.wosool.ai/health"
echo ""

