#!/bin/bash
# ─────────────────────────────────────────────────────
#  Start Cloudflare Tunnel for n8n
#  Exposes localhost:5678 to the internet
#  Updates DuckDNS with the tunnel URL info
# ─────────────────────────────────────────────────────
set -e

# Load env vars
if [ -f .env.local ]; then
  set -a && source .env.local && set +a
elif [ -f .env ]; then
  set -a && source .env && set +a
fi

# Check cloudflared
if ! command -v cloudflared &> /dev/null; then
  echo "❌ cloudflared not installed. Run: bash setup-tunnel.sh"
  exit 1
fi

echo "============================================"
echo "  🚇 Starting Cloudflare Tunnel"
echo "============================================"
echo ""
echo "  n8n must be running on port 5678"
echo "  A free *.trycloudflare.com URL will be assigned"
echo ""
echo "  💡 To use your DuckDNS domain instead:"
echo "     1. Run: cloudflared tunnel login"
echo "     2. Run: cloudflared tunnel create n8n"
echo "     3. Add CNAME in Cloudflare DNS:"
echo "        vikashcloud.duckdns.org → <tunnel-id>.cfargotunnel.com"
echo ""
echo "  Starting tunnel now..."
echo "============================================"
echo ""

# Start the tunnel — this will print the assigned URL
cloudflared tunnel --url http://localhost:5678 \
  --no-autoupdate \
  2>&1 | while IFS= read -r line; do
    echo "$line"
    # Extract and display the tunnel URL when it appears
    if echo "$line" | grep -q "trycloudflare.com"; then
      TUNNEL_URL=$(echo "$line" | grep -oP 'https://[a-z0-9-]+\.trycloudflare\.com')
      if [ -n "$TUNNEL_URL" ]; then
        echo ""
        echo "============================================"
        echo "  🎉 TUNNEL IS LIVE!"
        echo ""
        echo "  Access n8n at:"
        echo "  → $TUNNEL_URL"
        echo ""
        echo "  Set this as WEBHOOK_URL in n8n settings"
        echo "  if using webhook-triggered workflows."
        echo "============================================"
        echo ""
      fi
    fi
  done
