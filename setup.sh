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

echo "============================================"
echo "  ✅ Setup Complete!"
echo ""
echo "  Next steps:"
echo "  1. Copy .env.example to .env.local"
echo "  2. Fill in your Aiven DB values"
echo "  3. Run: bash start.sh"
echo "  4. Make port 5678 PUBLIC in PORTS tab"
echo "============================================"
