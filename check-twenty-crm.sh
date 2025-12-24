#!/bin/bash
# Check Twenty CRM status

cd /root/wosool-ai

echo "=== Twenty CRM Container Status ==="
docker ps | grep ent-twenty-crm

echo ""
echo "=== Recent Logs (last 50 lines) ==="
docker logs ent-twenty-crm --tail 50 2>&1

echo ""
echo "=== Check if port 3000 is listening ==="
docker exec ent-twenty-crm ss -tlnp 2>/dev/null | grep 3000 || \
docker exec ent-twenty-crm netstat -tlnp 2>/dev/null | grep 3000 || \
echo "Port 3000 not listening yet"

echo ""
echo "=== Test Health Endpoint ==="
curl -s -w "\nHTTP Status: %{http_code}\n" http://localhost:3000/health 2>&1 || echo "Not accessible"

echo ""
echo "=== Check Processes ==="
docker exec ent-twenty-crm ps aux | head -10

