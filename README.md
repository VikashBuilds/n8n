# n8n Server — GitHub Codespaces + Aiven DB + DuckDNS

Self-hosted n8n workflow automation server designed to run on **GitHub Codespaces** (or any VPS/VM), backed by **Aiven PostgreSQL** for persistent storage and **DuckDNS** for free dynamic DNS.

## 🏗️ Architecture

```
┌──────────────────────────────────┐
│  GitHub Codespace / VPS / VM     │
│                                  │
│  ┌──────────┐    ┌────────────┐  │
│  │  Caddy   │───▶│   n8n      │  │
│  │ (HTTPS)  │    │ (:5678)    │  │
│  └──────────┘    └─────┬──────┘  │
│       ▲                │         │
└───────┼────────────────┼─────────┘
        │                │
   DuckDNS          Aiven PostgreSQL
  (free DNS)        (managed DB)
```

## 🚀 Quick Start

### 1. Clone & Launch Codespace
```bash
# Push this repo to GitHub, then:
# Code → Codespaces → Create codespace on main
```

### 2. Configure Environment
```bash
cp .env.example .env
nano .env   # Fill in your Aiven DB + DuckDNS values
```

### 3. Start n8n
```bash
bash start.sh
```

### 4. (Optional) Keep Codespace Alive
```bash
# In a second terminal:
bash keep-alive.sh
```

## 📁 Files

| File | Purpose |
|---|---|
| `.devcontainer/devcontainer.json` | Codespace config (Node 20, port 5678) |
| `.env.example` | Template for all required env vars |
| `setup.sh` | Post-create: installs n8n + Caddy |
| `start.sh` | Main launcher: DuckDNS + Caddy + n8n |
| `update-duckdns.sh` | Standalone DuckDNS IP updater |
| `keep-alive.sh` | Prevents Codespace auto-shutdown |
| `Caddyfile.template` | Caddy HTTPS reverse proxy template |

## 🔑 Required Environment Variables

| Variable | Where to Get It |
|---|---|
| `DB_POSTGRESDB_HOST` | Aiven Console → PostgreSQL → Overview |
| `DB_POSTGRESDB_PORT` | Aiven Console → PostgreSQL → Overview |
| `DB_POSTGRESDB_USER` | Aiven Console → Users |
| `DB_POSTGRESDB_PASSWORD` | Aiven Console → Users |
| `N8N_ENCRYPTION_KEY` | **Same key from your AWS setup** |
| `DUCKDNS_DOMAIN` | Your subdomain (without `.duckdns.org`) |
| `DUCKDNS_TOKEN` | DuckDNS dashboard → Token |

## ⚠️ Important Notes

- **`N8N_ENCRYPTION_KEY` MUST match your AWS setup** — otherwise n8n cannot decrypt your saved credentials
- **DuckDNS HTTPS** works on VPS/VM with real IPs (Caddy handles cert via DNS challenge)
- **In Codespaces**, use the GitHub-provided URL; DuckDNS IP-based DNS won't resolve to Codespaces
- **Codespace auto-stop**: Use `keep-alive.sh` to prevent 30-min idle shutdown
