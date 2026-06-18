# Deployment Guide

Deploy the team-shared Canvas LMS instance on a DigitalOcean Droplet.

## Droplet requirements

| Setting | Value |
|---------|-------|
| OS | Ubuntu 22.04 LTS |
| RAM | 8 GB |
| Disk | 160 GB SSD |
| Open ports | 22 (SSH), 80 (HTTP), 443 (HTTPS) |

Canvas dev Docker is resource-heavy. The provision script adds a 4 GB swap file if none exists, but 8 GB RAM and ~150 GB free disk are still required for a successful first build.

## First-time setup

### 1. Create the droplet

Create a DigitalOcean Droplet with the specs above. Note the public IP address.

### 2. SSH and clone

```bash
ssh root@<droplet-ip>

git clone https://github.com/KitheK/499-Group-1-Canvas.git
cd 499-Group-1-Canvas
```

### 3. Configure environment

```bash
cp .env.example .env
```

Edit `.env`:

| Variable | Value |
|----------|-------|
| `CANVAS_URL` | `http://<droplet-ip>` (or `https://<your-domain>` after HTTPS setup) |
| `ADMIN_TOKEN` | Admin API token — create after Canvas is running (see below) |
| `DOMAIN` | Optional — set for Caddy HTTPS |

**Getting `ADMIN_TOKEN`:** After Canvas starts, log in as the root admin (`admin@example.com` in the dev stack), go to **Account → Settings → New Access Token**, and paste the token into `.env`.

### 4. Provision the server

```bash
sudo ./scripts/provision_droplet.sh
```

Installs Docker, Docker Compose, and configures UFW (ports 22, 80, 443).

### 5. Deploy Canvas

```bash
./scripts/deploy.sh
```

Clones [canvas-lms](https://github.com/instructure/canvas-lms), applies port overrides, runs `docker_dev_setup.sh` on first run, and starts the stack. Canvas listens on port 80.

**First deploy takes 1–2 hours** (image builds, database migrations, asset compilation).

### 6. Seed test data

```bash
pip install -r requirements.txt
python scripts/seed_data.py
```

Creates teachers, TAs, team members, courses, synthetic students, and writes API tokens to `seed/output/credentials.json`. See [TEAM_ACCESS.md](TEAM_ACCESS.md) for login details.

## Optional: domain and HTTPS

1. Point an A record at the droplet IP.
2. Set `DOMAIN=your.domain.com` in `.env`.
3. The `docker-compose.override.yml` includes Caddy for automatic HTTPS on port 443.
4. Update `CANVAS_URL` to `https://your.domain.com` and re-run seed if needed.

Without a domain, use `http://<droplet-ip>` directly.

## Troubleshooting

### Build failures with BuildKit

`deploy.sh` sets `DOCKER_BUILDKIT=0` and `COMPOSE_DOCKER_CLI_BUILD=0` because the Canvas dev stack can fail under BuildKit. If you run Docker commands manually, export these before building:

```bash
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0
```

### Out of disk or memory

- Ensure at least **160 GB SSD** and **8 GB RAM**.
- Check disk: `df -h`
- Check memory/swap: `free -h`
- The provision script creates a 4 GB swap file; if builds still OOM, stop other services or resize the droplet.

### Canvas not reachable

- Confirm containers are up: `docker compose ps` (from `~/canvas-lms`)
- Confirm UFW allows 80/443: `sudo ufw status`
- Check DigitalOcean cloud firewall rules match (22, 80, 443).

### Re-running seed

`seed_data.py` is idempotent — safe to re-run. It skips existing users and courses by login or SIS ID.
