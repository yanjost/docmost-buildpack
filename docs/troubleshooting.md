# Troubleshooting

## Common Issues

### Missing/Invalid DATABASE_URL or REDIS_URL
- Ensure Scalingo add-ons are provisioned
- Check env mapping: `SCALINGO_POSTGRESQL_URL` → `DATABASE_URL`, `SCALINGO_REDIS_URL` → `REDIS_URL`

### Migration Failures
- View logs: `scalingo -a <app> logs -f`
- Re-run migrations: `scalingo run -a <app> -- pnpm nx run server:migration:latest`

### S3 Incomplete Config
- If `STORAGE_DRIVER=s3`, all required AWS S3 envs must be set
- Error message will specify missing env

### Entrypoint Inference Failed
- Review candidates printed in build logs
- Override with `DOCMOST_WEB_CMD` env if needed
