# Environment Variables Reference

This document lists all environment variables supported by Docmost and this buildpack.

## Required Variables

### Application Configuration

| Variable | Description | Example | Notes |
|----------|-------------|---------|-------|
| `APP_URL` | Public URL of your application | `https://docmost.example.com` | Must be the full public URL |
| `APP_SECRET` | Secret key for encryption | `openssl rand -hex 32` | **Required**, minimum 32 characters |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/dbname` | Auto-mapped from `SCALINGO_POSTGRESQL_URL` |
| `REDIS_URL` | Redis connection string | `redis://host:6379` | Auto-mapped from `SCALINGO_REDIS_URL` |

## Optional: Docmost Configuration

### Server Settings

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `PORT` | Server port number | `3000` | `8080` |
| `JWT_TOKEN_EXPIRES_IN` | JWT authentication token lifetime | `30d` | `7d`, `24h`, `30d` |
| `FILE_UPLOAD_SIZE_LIMIT` | Maximum upload file size | `50mb` | `100mb`, `1gb` |

### Storage Configuration

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `STORAGE_DRIVER` | File storage backend | `local` | `local` or `s3` |

#### S3 Storage (Optional)

When `STORAGE_DRIVER=s3`, the following variables are required:

| Variable | Description | Example | Notes |
|----------|-------------|---------|-------|
| `AWS_S3_ACCESS_KEY_ID` | S3 access key | `AKIAIOSFODNN7EXAMPLE` | Required for S3 |
| `AWS_S3_SECRET_ACCESS_KEY` | S3 secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` | Required for S3 |
| `AWS_S3_REGION` | AWS region | `us-east-1` | Required for S3 |
| `AWS_S3_BUCKET` | S3 bucket name | `my-docmost-bucket` | Required for S3 |
| `AWS_S3_ENDPOINT` | Custom S3 endpoint | `https://s3.fr-par.scw.cloud` | For non-AWS S3 (Scaleway, MinIO, etc.) |
| `AWS_S3_FORCE_PATH_STYLE` | Force path-style URLs | `true` | Set to `true` for non-AWS S3 |

**Example S3 configuration (Scaleway):**
```sh
scalingo env-set \
  STORAGE_DRIVER=s3 \
  AWS_S3_ACCESS_KEY_ID=YOUR_ACCESS_KEY \
  AWS_S3_SECRET_ACCESS_KEY=YOUR_SECRET_KEY \
  AWS_S3_REGION=fr-par \
  AWS_S3_BUCKET=my-docmost-bucket \
  AWS_S3_ENDPOINT=https://s3.fr-par.scw.cloud \
  AWS_S3_FORCE_PATH_STYLE=true
```

### Email Configuration

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `MAIL_DRIVER` | Email service provider | `smtp` | `smtp` or `postmark` |
| `MAIL_FROM_ADDRESS` | Sender email address | - | `noreply@example.com` |
| `MAIL_FROM_NAME` | Sender display name | `Docmost` | `My Company Wiki` |

#### SMTP Configuration

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `SMTP_HOST` | SMTP server hostname | - | `smtp-relay.brevo.com` |
| `SMTP_PORT` | SMTP server port | `587` | `587`, `465`, `25` |
| `SMTP_USERNAME` | SMTP authentication user | - | `your-username` |
| `SMTP_PASSWORD` | SMTP authentication password | - | `your-password` |
| `SMTP_SECURE` | Enable TLS/SSL | `false` | `true` for port 465 |
| `SMTP_IGNORETLS` | Bypass TLS verification | `false` | `true` (not recommended) |

**Example SMTP configuration (Brevo):**
```sh
scalingo env-set \
  MAIL_DRIVER=smtp \
  SMTP_HOST=smtp-relay.brevo.com \
  SMTP_PORT=587 \
  SMTP_USERNAME=your-brevo-login \
  SMTP_PASSWORD=your-brevo-api-key \
  MAIL_FROM_ADDRESS="noreply@yourdomain.com" \
  SMTP_SECURE=false
```

#### Postmark Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `POSTMARK_TOKEN` | Postmark API token | `your-postmark-token` |

### Application Features

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `DRAWIO_URL` | Custom diagrams.net server | - | `https://drawio.example.com` |
| `DISABLE_TELEMETRY` | Disable anonymous usage analytics | `false` | `true` |
| `DEBUG_MODE` | Enable debug logging | `false` | `true` (not recommended in production) |

## Buildpack-Specific Variables

These variables control the buildpack behavior:

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `DOCMOST_VERSION` | Docmost version to deploy | Latest stable | `v0.23.2` |
| `DOCMOST_NODE_VERSION` | Pin `engines.node` (semver range) when Docmost declares none | Current LTS | `26.x` |
| `DOCMOST_WEB_CMD` | Override web process command | Auto-detected | `pnpm --filter ./apps/server run start:prod` |
| `DOCMOST_DEBUG_SIZE` | Enable size analysis during build | `false` | `true` |

### DOCMOST_VERSION

Specifies which version of Docmost to download and deploy.

```sh
# Deploy a specific version
scalingo env-set DOCMOST_VERSION=v0.23.2

# Deploy latest (auto-detected)
scalingo env-unset DOCMOST_VERSION
```

### DOCMOST_WEB_CMD

Override the automatically detected web process command. The buildpack tries to detect the correct command by looking for `main.js` in various locations. Use this if auto-detection fails.

```sh
scalingo env-set DOCMOST_WEB_CMD="node apps/server/dist/main.js"
```

### DOCMOST_DEBUG_SIZE

Enable detailed size analysis during the build phase. Outputs information about directory sizes, node_modules packages, and what files are being removed.

```sh
# Enable debug mode
scalingo env-set DOCMOST_DEBUG_SIZE=true

# Disable debug mode
scalingo env-unset DOCMOST_DEBUG_SIZE
```

**Note**: This runs before the nodejs-buildpack builds, so it shows source size only. See [slug-size-optimization.md](slug-size-optimization.md#important-note-analysis-timing) for details.

## Scalingo Auto-Mapped Variables

The buildpack automatically maps Scalingo add-on variables to Docmost variables:

| Scalingo Variable | Mapped To | Notes |
|-------------------|-----------|-------|
| `SCALINGO_POSTGRESQL_URL` | `DATABASE_URL` | If `DATABASE_URL` not set |
| `SCALINGO_REDIS_URL` | `REDIS_URL` | If `REDIS_URL` not set |

You can override these mappings by setting `DATABASE_URL` or `REDIS_URL` explicitly.

## Complete Example

Here's a complete example configuration for a production deployment:

```sh
# Required
scalingo env-set \
  APP_URL=https://wiki.mycompany.com \
  APP_SECRET=$(openssl rand -hex 32) \
  DOCMOST_VERSION=v0.23.2

# Optional: S3 Storage
scalingo env-set \
  STORAGE_DRIVER=s3 \
  AWS_S3_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
  AWS_S3_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
  AWS_S3_REGION=eu-west-1 \
  AWS_S3_BUCKET=mycompany-docmost

# Optional: SMTP Email
scalingo env-set \
  MAIL_DRIVER=smtp \
  SMTP_HOST=smtp.example.com \
  SMTP_PORT=587 \
  SMTP_USERNAME=noreply@mycompany.com \
  SMTP_PASSWORD=secret-password \
  MAIL_FROM_ADDRESS=noreply@mycompany.com \
  MAIL_FROM_NAME="Company Wiki"

# Optional: Customization
scalingo env-set \
  FILE_UPLOAD_SIZE_LIMIT=100mb \
  JWT_TOKEN_EXPIRES_IN=7d \
  DISABLE_TELEMETRY=true
```

## Troubleshooting

See [troubleshooting.md](troubleshooting.md) for common configuration issues and solutions.
