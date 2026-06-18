# Capstone Connection

How to connect the capstone app (`capstone-team-1`) to this team Canvas instance.

## Canvas URL

Set `canvasUrl` to the **public droplet URL** with **no trailing slash**:

| Deployment | Example |
|------------|---------|
| IP only | `http://203.0.113.42` |
| With domain | `https://canvas.yourteam.test` |

Do **not** use `localhost` or `http://localhost:8080` when the capstone stack runs in Docker — containers cannot reach the host's localhost. Use the droplet's public IP or domain instead.

## API token

After seeding, open `seed/output/credentials.json` (gitignored) on the droplet or copy it locally:

```json
{
  "canvas_url": "http://<droplet-ip>",
  "teachers": [
    {
      "email": "fob@team1.test",
      "password": "Team1fob!",
      "api_token": "..."
    }
  ]
}
```

Use a teacher's `api_token` in the capstone **canvas-service** configuration.

### Recommended test account

**`fob@team1.test`** — teaches three courses (COSC315, COSC304, COSC111) and is the best choice for multi-course dashboard testing.

Other teachers:

| Teacher | Courses | Use case |
|---------|---------|----------|
| `belize@team1.test` | COSC499 | Capstone course testing |
| `laris@team1.test` | COSC320, COSC310 | Smaller course loads |

## Capstone environment variables

In the capstone repo, configure the canvas-service (or equivalent) with:

```env
CANVAS_URL=http://<droplet-ip-or-domain>
CANVAS_API_TOKEN=<token from credentials.json>
```

Exact variable names may differ — follow the capstone repo's canvas integration docs.

## Related documentation

The capstone local Canvas guide follows the same connection pattern for a machine-local instance:

- [capstone-team-1: docs/canvas/LOCAL_CANVAS.md](https://github.com/UBCO-COSC499-S2026/capstone-team-1/blob/main/docs/canvas/LOCAL_CANVAS.md) — local Docker setup and API token workflow

Replace `localhost:8080` with this droplet's public URL when pointing the capstone Docker stack at the team instance.

## Quick verification

From any machine with network access to the droplet:

```bash
curl -H "Authorization: Bearer <api_token>" \
  "http://<droplet-ip>/api/v1/courses"
```

A JSON list of courses confirms the connection is working.
