#!/bin/bash
# ─────────────────────────────────────────────────────
#  Cloudflare Tunnel Setup for n8n
#  Creates a tunnel from Codespace → Cloudflare → Internet
#  Makes n8n accessible via DuckDNS or trycloudflare.com
# ─────────────────────────────────────────────────────
set -e

echo "============================================"
echo "  🔧 Setting up Cloudflare Tunnel"
echo "============================================"
echo ""

# ─── Check if cloudflared is installed ────────────────
if ! command -v cloudflared &> /dev/null; then
  echo "📦 Installing cloudflared..."
  curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /tmp/cloudflared
  chmod +x /tmp/cloudflared
  sudo mv /tmp/cloudflared /usr/local/bin/cloudflared
  echo "✅ cloudflared installed: $(cloudflared --version)"
else
  echo "✅ cloudflared already installed: $(cloudflared --version)"
fi

echo ""
echo "============================================"
echo "  ✅ Cloudflare Tunnel Ready!"
echo ""
echo "  Quick tunnel (temporary URL):"
echo "    cloudflared tunnel --url http://localhost:5678"
echo ""
echo "  For permanent setup with your domain:"
echo "    cloudflared tunnel login"
echo "    (follow browser auth flow)"
echo "============================================"
