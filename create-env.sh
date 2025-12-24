#!/bin/bash
# Create .env file with generated secrets

cd /root/wosool-ai

echo "Creating .env file..."

POSTGRES_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
JWT_SEC=$(openssl rand -base64 32)
ADMIN_KEY=$(openssl rand -base64 32)
WEBHOOK_SEC=$(openssl rand -base64 32)

cat > .env << EOF
# Database Configuration
POSTGRES_ADMIN_USER=postgres
POSTGRES_PASSWORD=${POSTGRES_PASS}

# Application URLs
APP_URL=http://167.99.20.94
CRM_BASE_URL=api.wosool.ai

# Security Secrets
JWT_SECRET=${JWT_SEC}
SUPER_ADMIN_KEY=${ADMIN_KEY}
SALLA_WEBHOOK_SECRET=${WEBHOOK_SEC}

# Salla Integration
SALLA_CLIENT_ID=47ef1a57-b66c-4c73-9a79-a6bd8ee60a43
SALLA_CLIENT_SECRET=2bb37d799e6fd88ebb14a77708e9263c7769e860c9d10bfc738a6835f3ead153

# Clerk Integration
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_ZW1lcmdpbmctc2tpbmstNzUuY2xlcmsuYWNjb3VudHMuZGV2JA
CLERK_SECRET_KEY=sk_test_kIRXGCc7WeA4MMaAkh6L3d17NbGRB6QkRodqsYHqrm
CLERK_WEBHOOK_SECRET=

# Grafana
GRAFANA_ADMIN_PASSWORD=admin

# PgAdmin
PGADMIN_EMAIL=admin@example.com
PGADMIN_PASSWORD=admin

# Twenty CRM
DISABLE_DB_MIGRATIONS=false
DISABLE_CRON_JOBS_REGISTRATION=false
TWENTY_ADMIN_TOKEN=
BOOTSTRAP_SECRET=
TWENTY_BASE_URL=http://localhost:3000
TWENTY_API_KEY=
EOF

echo "✅ .env file created successfully!"
echo ""
echo "⚠️  NOTE: CLERK_WEBHOOK_SECRET is empty - add it from Clerk dashboard if needed"
echo ""
echo "Next steps:"
echo "  docker-compose build --no-cache"
echo "  docker-compose up -d"

