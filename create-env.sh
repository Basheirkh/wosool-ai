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

# Salla Integration (Update with your credentials)
SALLA_CLIENT_ID=your_salla_client_id
SALLA_CLIENT_SECRET=your_salla_client_secret

# Clerk Integration (Update with your credentials)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
CLERK_SECRET_KEY=your_clerk_secret_key
CLERK_WEBHOOK_SECRET=your_clerk_webhook_secret

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
echo "⚠️  IMPORTANT: Update Salla and Clerk credentials in .env if you have them"
echo ""
echo "Next steps:"
echo "  docker-compose build --no-cache"
echo "  docker-compose up -d"

