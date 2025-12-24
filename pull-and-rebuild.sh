#!/bin/bash
# Pull latest changes and run force rebuild

set -e

cd /root/wosool-ai

echo "📥 Pulling latest changes..."

# Discard any local changes to docker-compose.yml and pull
git checkout -- docker-compose.yml 2>/dev/null || true
git pull

echo "✅ Pulled latest changes"

# Make force-rebuild executable and run it
if [ -f "force-rebuild.sh" ]; then
    chmod +x force-rebuild.sh
    echo "🚀 Running force rebuild..."
    ./force-rebuild.sh
else
    echo "❌ Error: force-rebuild.sh not found after pull"
    echo "📋 Listing files:"
    ls -la | grep -E "force|rebuild"
    exit 1
fi

