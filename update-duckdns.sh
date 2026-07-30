#!/bin/bash
# ─────────────────────────────────────────────────────
#  DuckDNS Dynamic DNS Updater
#  Updates your DuckDNS subdomain to the current IP
# ─────────────────────────────────────────────────────
set -e

# Load env vars
if [ -f .env ]; then
  set -a && source .env && set +a
fi

if [ -z "$DUCKDNS_TOKEN" ] || [ -z "$DUCKDNS_DOMAIN" ]; then
  echo "❌ Error: DUCKDNS_TOKEN and DUCKDNS_DOMAIN must be set in .env"
  exit 1
fi

echo "🦆 Updating DuckDNS domain: ${DUCKDNS_DOMAIN}.duckdns.org ..."

# Update DuckDNS — passing no IP lets DuckDNS auto-detect the public IP
RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}&verbose=true")

echo "$RESPONSE"

if echo "$RESPONSE" | head -1 | grep -q "OK"; then
  CURRENT_IP=$(echo "$RESPONSE" | sed -n '2p')
  echo ""
  echo "✅ DuckDNS updated successfully!"
  echo "   Domain: ${DUCKDNS_DOMAIN}.duckdns.org"
  echo "   IP:     ${CURRENT_IP}"
else
  echo ""
  echo "❌ DuckDNS update FAILED. Check your token and domain."
  exit 1
fi
