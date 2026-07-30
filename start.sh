#!/bin/bash
# ─────────────────────────────────────────────────────
#  n8n Server Starter
#  1. Loads environment variables
#  2. Updates DuckDNS to point to this machine
#  3. Generates Caddyfile from template
#  4. Starts Caddy (reverse proxy + HTTPS)
#  5. Starts n8n
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
[ -z "$DUCKDNS_TOKEN" ] && MISSING="$MISSING DUCKDNS_TOKEN"
[ -z "$DUCKDNS_DOMAIN" ] && MISSING="$MISSING DUCKDNS_DOMAIN"

if [ -n "$MISSING" ]; then
  echo "❌ Missing required environment variables:"
  for var in $MISSING; do
    echo "   - $var"
  done
  exit 1
fi

# ─── Step 3: Update DuckDNS ──────────────────────────
echo ""
echo "🦆 Updating DuckDNS..."
bash update-duckdns.sh

# ─── Step 4: Set webhook URL to DuckDNS domain ───────
export WEBHOOK_URL="https://${DUCKDNS_DOMAIN}.duckdns.org/"
echo ""
echo "🔗 Webhook URL: ${WEBHOOK_URL}"

# ─── Step 5: Detect environment ──────────────────────
# Check if running in GitHub Codespaces
if [ -n "$CODESPACES" ]; then
  echo ""
  echo "📍 Detected: GitHub Codespaces"
  echo "   Codespace URL: https://${CODESPACE_NAME}-5678.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
  echo ""
  echo "⚠️  NOTE: DuckDNS cannot point to Codespace URLs directly."
  echo "   Your n8n is accessible via the Codespace URL above."
  echo "   For DuckDNS to work, use a VPS/cloud VM with a real IP."
  echo ""
  
  # In Codespaces, just start n8n directly (no Caddy needed)
  echo "🚀 Starting n8n on port 5678..."
  echo "============================================"
  n8n start
else
  # ─── Step 6: Generate Caddyfile ─────────────────────
  echo ""
  echo "📝 Generating Caddyfile for ${DUCKDNS_DOMAIN}.duckdns.org ..."
  
  # Check if caddy-dns/duckdns plugin is available
  if caddy list-modules 2>/dev/null | grep -q "dns.providers.duckdns"; then
    # Use DNS challenge (automatic HTTPS without port 80)
    cat > Caddyfile << EOF
${DUCKDNS_DOMAIN}.duckdns.org {
    reverse_proxy localhost:5678
    tls {
        dns duckdns ${DUCKDNS_TOKEN}
    }
}
EOF
    echo "   Using: DNS-01 challenge (DuckDNS plugin)"
  else
    # Fallback: HTTP challenge (needs port 80 open)
    cat > Caddyfile << EOF
${DUCKDNS_DOMAIN}.duckdns.org {
    reverse_proxy localhost:5678
}
EOF
    echo "   Using: HTTP-01 challenge (port 80 must be open)"
    echo "   💡 For DNS challenge, install caddy-dns/duckdns plugin"
  fi
  
  echo "✅ Caddyfile generated"
  
  # ─── Step 7: Start Caddy in background ──────────────
  echo ""
  echo "🔒 Starting Caddy (HTTPS reverse proxy)..."
  sudo caddy stop 2>/dev/null || true
  sudo caddy start --config Caddyfile
  echo "✅ Caddy running — HTTPS active on ${DUCKDNS_DOMAIN}.duckdns.org"
  
  # ─── Step 8: Start n8n ──────────────────────────────
  echo ""
  echo "🚀 Starting n8n on port 5678..."
  echo "   Access: https://${DUCKDNS_DOMAIN}.duckdns.org"
  echo "============================================"
  n8n start
fi
