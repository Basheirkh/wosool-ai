#!/bin/bash
# Complete clean reset - removes everything and starts fresh

set -e

cd /root/wosool-ai

echo "========================================="
echo "Complete Clean Reset"
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

echo ""
echo "Step 4: Removing project images..."
docker images | grep -E "wosool-ai" | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true

echo ""
echo "Step 5: Cleaning up unused Docker resources..."
docker system prune -f

echo ""
echo "Step 6: Verifying .env file exists..."
if [ ! -f .env ]; then
    echo "⚠️  .env file not found! Creating it..."
    if [ -f create-env.sh ]; then
        bash create-env.sh
    else
        echo "ERROR: create-env.sh not found!"
        exit 1
    fi
else
    echo "✓ .env file exists"
fi

echo ""
echo "Step 7: Pulling latest code..."
git pull

echo ""
echo "Step 8: Building images from scratch (this will take time)..."
docker-compose build --no-cache

echo ""
echo "Step 9: Starting services..."
docker-compose up -d

echo ""
echo "========================================="
echo "Clean reset complete!"
echo "========================================="
echo ""
echo "Monitor progress with:"
echo "  docker logs -f ent-twenty-crm"
echo ""
echo "Check status with:"
echo "  docker-compose ps"

