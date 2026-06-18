# Team Access

Login credentials for the shared team Canvas instance. All accounts use the `@team1.test` domain.

## Password convention

**Pattern:** `Team1{email-prefix}!` where `{email-prefix}` is the part before `@` (lowercase).

| Email | Password |
|-------|----------|
| `fob@team1.test` | `Team1fob!` |
| `belize@team1.test` | `Team1belize!` |
| `ta1@team1.test` | `Team1ta1!` |
| `james@team1.test` | `Team1james!` |
| `al-ameen@team1.test` | `Team1al-ameen!` |

## Teachers

| Login | Display name | Password | Courses |
|-------|--------------|----------|---------|
| `fob@team1.test` | Fob | `Team1fob!` | COSC315, COSC304, COSC111 |
| `belize@team1.test` | Belize | `Team1belize!` | COSC499 |
| `laris@team1.test` | Laris | `Team1laris!` | COSC320, COSC310 |

## Teaching assistants

| Login | Display name | Password | Course |
|-------|--------------|----------|--------|
| `ta1@team1.test` | TA 1 | `Team1ta1!` | COSC315 |
| `ta2@team1.test` | TA 2 | `Team1ta2!` | COSC304 |
| `ta3@team1.test` | TA 3 | `Team1ta3!` | COSC499 |
| `ta4@team1.test` | TA 4 | `Team1ta4!` | COSC111 |

## Team members (capstone group)

Named student accounts enrolled in COSC499 by default.

| Login | Display name | Password |
|-------|--------------|----------|
| `james@team1.test` | James Birnie | `Team1james!` |
| `carson@team1.test` | Carson Bennett | `Team1carson!` |
| `al-ameen@team1.test` | Al-Ameen Oludare | `Team1al-ameen!` |
| `armaan@team1.test` | Armaan Cheema | `Team1armaan!` |
| `hakim@team1.test` | Hakim Rashid | `Team1hakim!` |
| `kithe@team1.test` | Kithe Kisia | `Team1kithe!` |

## Synthetic students

Bulk test accounts for realistic enrollment sizes:

| Login range | Password |
|-------------|----------|
| `student001@team1.test` … `student749@team1.test` | `Team1student!` (shared) |

Student numbering and course assignment:

| Course | Code | Teacher | Students (`studentNNN`) | Count |
|--------|------|---------|---------------------------|-------|
| Introduction to Operating Systems | COSC315 | fob | 001–300 | 300 |
| Introduction to Databases | COSC304 | fob | 301–600 | 300 |
| Computer Programming I | COSC111 | fob | 601–625 | 25 |
| Software Engineering Capstone | COSC499 | belize | 626–699 | 74 |
| Analysis of Algorithms | COSC320 | laris | 700–724 | 25 |
| Software Engineering | COSC310 | laris | 725–749 | 25 |

COSC499 also includes the six named team members above (not counted in the synthetic ranges).

**Totals:** 6 courses, 749 synthetic students + 6 team members, 3 teachers, 4 TAs.

## API tokens

After running `scripts/seed_data.py`, per-teacher API tokens are written to:

```
seed/output/credentials.json
```

This file is **gitignored**. Use it to connect the capstone app — see [CAPSTONE_CONNECTION.md](CAPSTONE_CONNECTION.md).
