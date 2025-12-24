#!/bin/bash
# Validation script for Twenty CRM production fix
# This script validates all changes before deployment

set -e

echo "========================================================================"
echo "Twenty CRM Production Fix - Validation Script"
echo "========================================================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success() {
  echo -e "${GREEN}✅ $1${NC}"
}

error() {
  echo -e "${RED}❌ $1${NC}"
}

warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
  echo -e "ℹ️  $1"
}

# Track validation status
VALIDATION_FAILED=0

# ============================================================================
# 1. File Existence Checks
# ============================================================================

echo "1. Checking file existence..."

if [ -f "services/twenty-crm/scripts/docker-entrypoint.sh" ]; then
  success "Entrypoint script exists"
else
  error "Entrypoint script not found"
  VALIDATION_FAILED=1
fi

if [ -f "services/twenty-crm/Dockerfile" ]; then
  success "Dockerfile exists"
else
  error "Dockerfile not found"
  VALIDATION_FAILED=1
fi

if [ -f "docker-compose.yml" ]; then
  success "docker-compose.yml exists"
else
  error "docker-compose.yml not found"
  VALIDATION_FAILED=1
fi

echo ""

# ============================================================================
# 2. Script Syntax Validation
# ============================================================================

echo "2. Validating script syntax..."

if bash -n services/twenty-crm/scripts/docker-entrypoint.sh 2>/dev/null; then
  success "Entrypoint script syntax is valid"
else
  error "Entrypoint script has syntax errors"
  bash -n services/twenty-crm/scripts/docker-entrypoint.sh
  VALIDATION_FAILED=1
fi

echo ""

# ============================================================================
# 3. Permissions Check
# ============================================================================

echo "3. Checking file permissions..."

if [ -x "services/twenty-crm/scripts/docker-entrypoint.sh" ]; then
  success "Entrypoint script is executable"
else
  error "Entrypoint script is not executable"
  info "Run: chmod +x services/twenty-crm/scripts/docker-entrypoint.sh"
  VALIDATION_FAILED=1
fi

echo ""

# ============================================================================
# 4. Content Validation
# ============================================================================

echo "4. Validating script content..."

# Check for bash shebang
if head -1 services/twenty-crm/scripts/docker-entrypoint.sh | grep -q "#!/bin/bash"; then
  success "Correct shebang (#!/bin/bash)"
else
  error "Incorrect or missing shebang"
  VALIDATION_FAILED=1
fi

# Check for set -euo pipefail
if grep -q "set -euo pipefail" services/twenty-crm/scripts/docker-entrypoint.sh; then
  success "Strict error handling enabled (set -euo pipefail)"
else
  error "Missing strict error handling"
  VALIDATION_FAILED=1
fi

# Check for MONOREPO_ROOT
if grep -q 'MONOREPO_ROOT="/app"' services/twenty-crm/scripts/docker-entrypoint.sh; then
  success "MONOREPO_ROOT is defined"
else
  error "MONOREPO_ROOT not properly defined"
  VALIDATION_FAILED=1
fi

# Check for exec in start_application
if grep -q "exec yarn start" services/twenty-crm/scripts/docker-entrypoint.sh; then
  success "Application starts with exec (proper PID 1)"
else
  warning "Application might not use exec (check manually)"
fi

# Check working directory is set to /app before starting
if grep -B5 "exec yarn start" services/twenty-crm/scripts/docker-entrypoint.sh | grep -q 'cd "${MONOREPO_ROOT}"'; then
  success "Working directory set to monorepo root before starting"
else
  error "Working directory not set correctly before starting app"
  VALIDATION_FAILED=1
fi

echo ""

# ============================================================================
# 5. Dockerfile Validation
# ============================================================================

echo "5. Validating Dockerfile..."

# Check for bash installation
if grep -q "bash" services/twenty-crm/Dockerfile; then
  success "Bash is installed in Dockerfile"
else
  error "Bash not installed in Dockerfile"
  VALIDATION_FAILED=1
fi

# Check WORKDIR is set to /app
if grep -q "WORKDIR /app" services/twenty-crm/Dockerfile; then
  success "WORKDIR set to /app"
else
  error "WORKDIR not set to /app"
  VALIDATION_FAILED=1
fi

# Check HEALTHCHECK exists
if grep -q "HEALTHCHECK" services/twenty-crm/Dockerfile; then
  success "HEALTHCHECK defined"
else
  warning "HEALTHCHECK not defined (recommended)"
fi

# Check entrypoint is set
if grep -q "ENTRYPOINT.*docker-entrypoint-custom.sh" services/twenty-crm/Dockerfile; then
  success "ENTRYPOINT correctly set"
else
  error "ENTRYPOINT not correctly set"
  VALIDATION_FAILED=1
fi

echo ""

# ============================================================================
# 6. Docker Compose Validation
# ============================================================================

echo "6. Validating docker-compose.yml..."

# Check if docker-compose syntax is valid
if docker-compose config > /dev/null 2>&1; then
  success "docker-compose.yml syntax is valid"
else
  error "docker-compose.yml has syntax errors"
  docker-compose config
  VALIDATION_FAILED=1
fi

# Check twenty-crm service exists
if grep -q "twenty-crm:" docker-compose.yml; then
  success "twenty-crm service defined"
else
  error "twenty-crm service not found"
  VALIDATION_FAILED=1
fi

# Check PORT environment variable
if grep -A20 "twenty-crm:" docker-compose.yml | grep -q "PORT=3000"; then
  success "PORT=3000 is set"
else
  warning "PORT=3000 not explicitly set (might use default)"
fi

# Check healthcheck exists
if grep -A30 "twenty-crm:" docker-compose.yml | grep -q "healthcheck:"; then
  success "Healthcheck defined for twenty-crm"
else
  warning "Healthcheck not defined (recommended)"
fi

# Check start_period is reasonable
if grep -A35 "twenty-crm:" docker-compose.yml | grep -q "start_period.*90s"; then
  success "Healthcheck start_period is 90s (appropriate for initialization)"
else
  warning "Healthcheck start_period might be too short"
fi

# Check Grafana port is not 3000
if grep -A10 "grafana:" docker-compose.yml | grep -q "3002:3000"; then
  success "Grafana port changed to 3002 (no conflict)"
else
  warning "Grafana might conflict with Twenty CRM on port 3000"
fi

echo ""

# ============================================================================
# 7. Environment Variables Check
# ============================================================================

echo "7. Checking environment configuration..."

if [ -f ".env" ]; then
  success ".env file exists"
  
  # Check for required variables
  if grep -q "POSTGRES_PASSWORD=" .env; then
    success "POSTGRES_PASSWORD is set"
  else
    error "POSTGRES_PASSWORD not set in .env"
    VALIDATION_FAILED=1
  fi
  
  if grep -q "JWT_SECRET=" .env; then
    success "JWT_SECRET is set"
  else
    error "JWT_SECRET not set in .env"
    VALIDATION_FAILED=1
  fi
else
  warning ".env file not found (might be provided at runtime)"
fi

echo ""

# ============================================================================
# 8. Documentation Check
# ============================================================================

echo "8. Checking documentation..."

if [ -f "PRODUCTION-FIX-DOCUMENTATION.md" ]; then
  success "Production fix documentation exists"
else
  warning "Production fix documentation not found"
fi

if [ -f "QUICK-DEPLOY.md" ]; then
  success "Quick deploy guide exists"
else
  warning "Quick deploy guide not found"
fi

echo ""

# ============================================================================
# Final Summary
# ============================================================================

echo "========================================================================"
if [ $VALIDATION_FAILED -eq 0 ]; then
  success "All validations passed! Ready for deployment."
  echo ""
  info "Next steps:"
  echo "  1. Review PRODUCTION-FIX-DOCUMENTATION.md"
  echo "  2. Follow QUICK-DEPLOY.md for deployment"
  echo "  3. Monitor logs after deployment"
  exit 0
else
  error "Validation failed! Please fix the issues above before deploying."
  echo ""
  info "Common fixes:"
  echo "  - chmod +x services/twenty-crm/scripts/docker-entrypoint.sh"
  echo "  - Ensure all required files are present"
  echo "  - Check .env file has required variables"
  exit 1
fi
