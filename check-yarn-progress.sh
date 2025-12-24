#!/bin/bash
# Check Yarn installation progress

echo "=== Yarn Process Status ==="
docker exec ent-twenty-crm ps aux | grep -E "(yarn|node)" | grep -v "ps aux" | head -5

echo ""
echo "=== Latest Logs (last 5 lines) ==="
docker logs ent-twenty-crm --tail 5 2>&1

echo ""
echo "=== Check if installation completed ==="
if docker exec ent-twenty-crm test -d /app/node_modules/.bin/nx 2>/dev/null; then
  echo "✓ Dependencies installed!"
  echo "Checking if server started..."
  sleep 2
  docker exec ent-twenty-crm ss -tlnp 2>/dev/null | grep 3000 || echo "Server not started yet"
else
  echo "⏳ Still installing dependencies..."
  echo "This can take 10-15 minutes on a 2GB server"
fi
