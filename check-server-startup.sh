#!/bin/bash
# Check if server has started

echo "=== Latest Logs (last 50 lines) ==="
docker logs ent-twenty-crm --tail 50 2>&1 | tail -50

echo ""
echo "=== Looking for server startup messages ==="
docker logs ent-twenty-crm 2>&1 | grep -E "(Nest application|Application is running|listening|Started|ERROR|Error|Failed)" | tail -20

echo ""
echo "=== Check if port 3000 is listening ==="
docker exec ent-twenty-crm ss -tlnp 2>/dev/null | grep 3000 || \
echo "Port 3000 still not listening"

echo ""
echo "=== Check active processes ==="
docker exec ent-twenty-crm ps aux | grep -E "(node|nest|nx)" | grep -v grep | head -10
