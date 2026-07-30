#!/bin/bash
# ─────────────────────────────────────────────────────
#  Keep-Alive Script for GitHub Codespaces
#  Prevents Codespace from auto-stopping due to inactivity
#  Run in a separate terminal: bash keep-alive.sh
# ─────────────────────────────────────────────────────

echo "🔄 Keep-alive started. Codespace will stay active."
echo "   Press Ctrl+C to stop."
echo ""

while true; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') — ♥ ping (keeping codespace alive)"
  
  # Update DuckDNS every 5 minutes (keeps DNS fresh)
  if [ -f .env ]; then
    set -a && source .env && set +a
    if [ -n "$DUCKDNS_TOKEN" ] && [ -n "$DUCKDNS_DOMAIN" ]; then
      curl -s "https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}" > /dev/null 2>&1
    fi
  fi
  
  sleep 300  # Every 5 minutes
done
