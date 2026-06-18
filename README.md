# 499 Group 1 Canvas

Team-shared Canvas LMS deployment wrapper for capstone testing.

## Documentation

- [Deployment guide](docs/DEPLOY.md)
- [Team access](docs/TEAM_ACCESS.md)
- [Capstone connection](docs/CAPSTONE_CONNECTION.md)

## Branding and course cards

After deploy, apply Team 1 branding and dashboard card images:

```bash
./scripts/apply_branding.sh
./scripts/apply_course_card_images.sh
```

Course card images live in `assets/course-cards/` and rotate across courses (5 images). The branding script publishes them to `/group1/course-cards/` and loads dashboard overrides on every page.

