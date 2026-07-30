#!/bin/bash
set -e

echo "============================================"
echo "  🚀 n8n Server Setup for GitHub Codespaces"
echo "============================================"
echo ""

# ─── Install n8n globally ────────────────────────────
echo "📦 Installing n8n globally..."
npm install -g n8n
echo "✅ n8n installed: $(n8n --version)"
echo ""

# ─── Install cloudflared (Cloudflare Tunnel) ─────────
echo "📦 Installing cloudflared (Cloudflare Tunnel)..."
curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /tmp/cloudflared
chmod +x /tmp/cloudflared
sudo mv /tmp/cloudflared /usr/local/bin/cloudflared
echo "✅ cloudflared installed: $(cloudflared --version)"
echo ""

echo "============================================"
echo "  ✅ Setup Complete!"
echo ""
echo "  Next steps:"
echo "  1. Copy .env.example to .env.local"
echo "  2. Fill in your Aiven DB + DuckDNS values"
echo "  3. Terminal 1: bash start.sh"
echo "  4. Terminal 2: bash start-tunnel.sh"
echo "  5. Terminal 3: bash keep-alive.sh"
echo "============================================"
