#!/bin/bash
# Comprehensive diagnosis script

cd /root/wosool-ai

echo "=== Container Status ==="
docker ps -a | grep ent-twenty-crm

echo ""
echo "=== Health Check ==="
docker inspect ent-twenty-crm --format='{{json .State.Health}}' 2>/dev/null | python3 -m json.tool || docker inspect ent-twenty-crm --format='{{.State.Status}}'

echo ""
echo "=== Recent Logs (last 100 lines) ==="
docker logs ent-twenty-crm --tail 100 2>&1

echo ""
echo "=== Check Port 3000 ==="
docker exec ent-twenty-crm ss -tlnp 2>/dev/null | grep 3000 || \
docker exec ent-twenty-crm netstat -tlnp 2>/dev/null | grep 3000 || \
echo "Port 3000 NOT listening"

echo ""
echo "=== Check Processes ==="
docker exec ent-twenty-crm ps aux | grep -E "(node|yarn|nx)" | head -5

echo ""
echo "=== Test from inside container ==="
docker exec ent-twenty-crm curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:3000/health 2>&1 || echo "Not accessible from inside"

echo ""
echo "=== Test from host ==="
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:3000/health 2>&1 || echo "Not accessible from host"

echo ""
echo "=== Nginx Status ==="
docker ps | grep ent-nginx
docker logs ent-nginx --tail 20 2>&1 | grep -E "(error|upstream|connect)" | tail -5

echo ""
echo "=== Test via Nginx ==="
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost/ 2>&1

