#!/bin/bash
# ─────────────────────────────────────────────────────
#  n8n Server Starter (GitHub Codespaces)
#  1. Loads environment variables
#  2. Validates required vars
#  3. Starts n8n
# ─────────────────────────────────────────────────────
set -e

echo "============================================"
echo "  🚀 Starting n8n Server"
echo "============================================"
echo ""

# ─── Step 1: Load env vars ───────────────────────────
ENV_FILE=""
if [ -f .env.local ]; then
  ENV_FILE=".env.local"
elif [ -f .env ]; then
  ENV_FILE=".env"
else
  echo "❌ No .env or .env.local file found!"
  echo "   Copy .env.example to .env.local and fill in your values:"
  echo "   cp .env.example .env.local"
  exit 1
fi

set -a && source "$ENV_FILE" && set +a
echo "✅ Environment variables loaded from $ENV_FILE"

# ─── Step 2: Validate required vars ──────────────────
MISSING=""
[ -z "$DB_POSTGRESDB_HOST" ] && MISSING="$MISSING DB_POSTGRESDB_HOST"
[ -z "$DB_POSTGRESDB_PASSWORD" ] && MISSING="$MISSING DB_POSTGRESDB_PASSWORD"
[ -z "$N8N_ENCRYPTION_KEY" ] && MISSING="$MISSING N8N_ENCRYPTION_KEY"

if [ -n "$MISSING" ]; then
  echo "❌ Missing required environment variables:"
  for var in $MISSING; do
    echo "   - $var"
  done
  exit 1
fi

# ─── Step 3: Set Codespace webhook URL ────────────────
if [ -n "$CODESPACES" ]; then
  CODESPACE_URL="https://${CODESPACE_NAME}-5678.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
  export WEBHOOK_URL="${CODESPACE_URL}/"
  export N8N_HOST="0.0.0.0"

  echo ""
  echo "📍 GitHub Codespaces detected"
  echo "🔗 n8n URL: ${CODESPACE_URL}"
  echo ""
  echo "⚠️  IMPORTANT: Make port 5678 PUBLIC in the PORTS tab!"
fi

# ─── Step 4: Start n8n ────────────────────────────────
echo ""
echo "🚀 Starting n8n on port 5678..."
echo "============================================"
n8n start
