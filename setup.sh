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

# ─── Install Caddy for reverse proxy + HTTPS ─────────
echo "📦 Installing Caddy (reverse proxy + auto HTTPS)..."
sudo apt-get update -qq
sudo apt-get install -y -qq debian-keyring debian-archive-keyring apt-transport-https curl > /dev/null 2>&1
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg 2>/dev/null
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list > /dev/null
sudo apt-get update -qq
sudo apt-get install -y -qq caddy > /dev/null 2>&1
echo "✅ Caddy installed: $(caddy version)"
echo ""

echo "============================================"
echo "  ✅ Setup Complete!"
echo ""
echo "  Next steps:"
echo "  1. Copy .env.example to .env"
echo "  2. Fill in your Aiven DB + DuckDNS values"
echo "  3. Run: bash start.sh"
echo "============================================"
