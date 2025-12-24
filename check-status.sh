#!/bin/bash
# Quick status check script

cd /root/wosool-ai

echo "=== Container Status ==="
docker-compose ps

echo ""
echo "=== Twenty CRM Logs (last 30 lines) ==="
docker logs ent-twenty-crm --tail 30 2>&1

echo ""
echo "=== Tenant Manager Logs (last 20 lines) ==="
docker logs ent-tenant-manager --tail 20 2>&1

echo ""
echo "=== Nginx Status ==="
docker logs ent-nginx --tail 10 2>&1

echo ""
echo "=== Test Endpoints ==="
echo "Testing localhost:3001/health..."
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:3001/health || echo "Failed"

echo ""
echo "Testing localhost/ (nginx)..."
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost/ || echo "Failed"

echo ""
echo "=== Check Ports ==="
echo "Port 3000 (Twenty CRM):"
docker exec ent-twenty-crm ss -tlnp 2>/dev/null | grep 3000 || echo "Not listening"

echo "Port 3001 (Tenant Manager):"
docker exec ent-tenant-manager ss -tlnp 2>/dev/null | grep 3001 || echo "Not listening"

