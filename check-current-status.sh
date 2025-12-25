#!/bin/bash
# Check current status of Twenty CRM

cd /root/wosool-ai

echo "=== Container Status ==="
docker ps -a | grep ent-twenty-crm

echo ""
echo "=== Health Check Status ==="
docker inspect ent-twenty-crm --format='{{json .State.Health}}' 2>/dev/null | python3 -m json.tool 2>/dev/null || docker inspect ent-twenty-crm --format='{{.State.Status}}'

echo ""
echo "=== Latest Logs (last 30 lines) ==="
docker logs ent-twenty-crm --tail 30 2>&1

echo ""
echo "=== Check Port 3000 ==="
docker exec ent-twenty-crm ss -tlnp 2>/dev/null | grep 3000 || \
docker exec ent-twenty-crm netstat -tlnp 2>/dev/null | grep 3000 || \
echo "Port 3000 NOT listening"

echo ""
echo "=== Check Processes ==="
docker exec ent-twenty-crm ps aux | head -10

echo ""
echo "=== Test from inside container ==="
docker exec ent-twenty-crm curl -s -w "\nHTTP %{http_code}\n" http://localhost:3000/health 2>&1 | head -5 || echo "Not accessible"

echo ""
echo "=== Nginx Upstream Status ==="
docker logs ent-nginx --tail 10 2>&1 | grep -E "(upstream|connect|502)" | tail -5

