# Scalingo CLI Cheatsheet

- View logs: `scalingo -a <app> logs -f`
- Get/set env: `scalingo env-get|env-set`
- Run command: `scalingo run -a <app> -- <cmd>`
- Add-on backups:
  - Postgres: `scalingo -a <app> run pg_dump > backup.sql`
  - Redis: Use caution, backup via CLI or dashboard
