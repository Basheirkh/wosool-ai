#!/bin/bash
# Fresh Clone and Deploy Script
# Removes existing directory and clones fresh from GitHub

set -e

echo "🧹 Removing existing wosool-ai directory..."
cd /root
rm -rf wosool-ai

echo "📥 Cloning fresh repository from GitHub..."
git clone https://github.com/Basheirkh/wosool-ai.git
cd wosool-ai

echo "✅ Repository cloned successfully"

echo "🚀 Running force rebuild..."
chmod +x force-rebuild.sh
./force-rebuild.sh

echo ""
echo "✅ Fresh deployment complete!"
echo ""
echo "Check service status:"
echo "  cd /root/wosool-ai && docker-compose ps"
echo ""
echo "View logs:"
echo "  cd /root/wosool-ai && docker-compose logs -f"

