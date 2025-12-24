#!/bin/bash
# Quick check script for deployment status

cd /root/wosool-ai

echo "=== Container Status ==="
docker-compose ps | grep -E "NAME|ent-"

echo ""
echo "=== Twenty CRM Logs (last 40 lines) ==="
docker logs ent-twenty-crm --tail 40 2>&1

echo ""
echo "=== Testing Endpoints ==="
echo -n "Tenant Manager: "
curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/health && echo "" || echo "FAILED"

echo -n "Twenty CRM: "
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health 2>&1 && echo "" || echo "NOT READY"

echo -n "Nginx: "
curl -s -o /dev/null -w "%{http_code}" http://localhost/ && echo "" || echo "FAILED"

echo ""
echo "=== Port Status ==="
docker exec ent-twenty-crm ss -tlnp 2>/dev/null | grep 3000 || echo "Port 3000 not listening"
docker exec ent-tenant-manager ss -tlnp 2>/dev/null | grep 3001 || echo "Port 3001 not listening"

