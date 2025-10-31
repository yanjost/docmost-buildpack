# Configuration Reference

## Required Environment Variables
- `APP_URL`: Public URL (e.g., https://docmost.example.com)
- `APP_SECRET`: 64-char hex, generate with `openssl rand -hex 32`
- `DOCMOST_VERSION`: Docmost release tag (e.g., 1.9.0)
- `DATABASE_URL`: Auto-mapped from `SCALINGO_POSTGRESQL_URL` if empty
- `REDIS_URL`: Auto-mapped from `SCALINGO_REDIS_URL` if empty

## Optional S3 Storage
- `STORAGE_DRIVER=s3` enables S3
- Required if enabled: `AWS_S3_ACCESS_KEY_ID`, `AWS_S3_SECRET_ACCESS_KEY`, `AWS_S3_REGION`, `AWS_S3_BUCKET`
- Optional: `AWS_S3_ENDPOINT` (for S3-compatible providers), `AWS_S3_FORCE_PATH_STYLE=true|false`

## SMTP (Brevo Example)
- `SMTP_HOST=smtp-relay.brevo.com`
- `SMTP_PORT=587`
- `SMTP_USER=<brevo-login>`
- `SMTP_PASSWORD=<brevo-api-key>`
- `SMTP_FROM="Docmost <noreply@yourdomain.com>"`
- `SMTP_SECURE=false` (set to true for TLS)

## Entrypoint Override
- If entrypoint inference fails, set `DOCMOST_WEB_CMD` to your desired start command.
