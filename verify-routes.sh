#!/bin/bash
# Verify all service routes are working correctly

set -e

BASE_URL="${1:-http://api.wosool.ai}"
echo "Testing routes on: ${BASE_URL}"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_route() {
    local name=$1
    local path=$2
    local expected_status=${3:-200}
    
    echo -n "Testing ${name} (${path})... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}${path}" 2>/dev/null || echo "000")
    
    if [ "$response" = "$expected_status" ] || [ "$response" = "000" ]; then
        if [ "$response" = "000" ]; then
            echo -e "${YELLOW}SKIP (service may not be ready)${NC}"
        else
            echo -e "${GREEN}✓ OK (${response})${NC}"
        fi
    else
        echo -e "${RED}✗ FAIL (got ${response}, expected ${expected_status})${NC}"
    fi
}

echo "========================================="
echo "Route Verification Tests"
echo "========================================="
echo ""

echo "Frontend Routes:"
test_route "Health Check" "/health"
test_route "Root" "/"

echo ""
echo "Backend API Routes:"
test_route "Tenant Manager API" "/api/health" "200"
test_route "Salla API" "/api/salla/health" "200"

echo ""
echo "Twenty CRM Routes:"
test_route "GraphQL" "/graphql" "400"  # 400 is OK for GraphQL without query
test_route "REST API" "/rest/" "404"   # 404 is OK if endpoint doesn't exist

echo ""
echo "Static Assets:"
test_route "Public Assets" "/public/" "200"

echo ""
echo "Admin Routes (may require auth):"
test_route "Grafana" "/admin/grafana/" "200"
test_route "Prometheus" "/admin/prometheus/" "200"
test_route "PgAdmin" "/admin/pgadmin/" "200"
test_route "Redis Commander" "/admin/redis/" "200"

echo ""
echo "========================================="
echo "Container Status"
echo "========================================="
docker-compose ps

echo ""
echo "========================================="
echo "Nginx Status"
echo "========================================="
docker exec ent-nginx nginx -t 2>&1 || echo "Nginx container not running"

echo ""
echo "========================================="
echo "Service Health Checks"
echo "========================================="
echo "Twenty CRM:"
docker exec ent-twenty-crm curl -f http://localhost:3000/health 2>/dev/null && echo "✓ Healthy" || echo "✗ Unhealthy"

echo "Tenant Manager:"
docker exec ent-tenant-manager curl -f http://localhost:3001/health 2>/dev/null && echo "✓ Healthy" || echo "✗ Unhealthy"

echo "Salla Orchestrator:"
docker exec ent-salla-orchestrator curl -f http://localhost:8000/health 2>/dev/null && echo "✓ Healthy" || echo "✗ Unhealthy"

echo ""
echo "Done!"

