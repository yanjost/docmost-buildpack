# Upgrades & Rollbacks

## Upgrading Docmost
- Change `DOCMOST_VERSION` to a new release tag
- Redeploy: `git push scalingo main`
- Migrations run automatically post-deploy

## Rollback Guidance
- Always backup your database before major upgrades:
  ```sh
  scalingo -a <app> run pg_dump > backup.sql
  ```
- To rollback, set `DOCMOST_VERSION` to a previous tag and redeploy
