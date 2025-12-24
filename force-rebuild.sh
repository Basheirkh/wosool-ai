#!/bin/bash
# Force Rebuild Script for Wosool AI
# Ensures all containers are stopped, removed, and rebuilt from scratch

set -e

echo "🚀 Starting Force Rebuild..."

# 1. Stop and remove all containers, networks, and images for this project
echo "🛑 Stopping and removing existing containers..."
docker-compose down --remove-orphans || true

# 2. Remove the specific images to force a clean rebuild
echo "🧹 Removing project images..."
docker rmi wosool-ai-twenty-crm wosool-ai-tenant-manager wosool-ai-salla-orchestrator 2>/dev/null || true

# 3. Build with no cache
echo "🏗️ Building services (no-cache)..."
docker-compose build --no-cache

# 4. Start services
echo "🆙 Starting services..."
docker-compose up -d

# 5. Wait and check logs
echo "⏳ Waiting for services to initialize..."
sleep 10

echo "📋 Checking Twenty CRM logs..."
docker logs ent-twenty-crm --tail 20 || echo "⚠️ Twenty CRM not started yet"

echo ""
echo "📋 Checking Salla Orchestrator logs..."
docker logs ent-salla-orchestrator --tail 20 || echo "⚠️ Salla Orchestrator not started yet"

echo ""
echo "✅ Force Rebuild Complete!"
echo ""
echo "Check service status:"
echo "  docker-compose ps"
echo ""
echo "View logs:"
echo "  docker-compose logs -f"

