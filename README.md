# Docmost Buildpack for Scalingo

This repository provides a production-grade Heroku-style buildpack for deploying [Docmost](https://github.com/docmost/docmost) on Scalingo. It automates installation, configuration, and deployment, leveraging Scalingo's PostgreSQL and Redis add-ons, with optional S3 storage and SMTP support. The buildpack fetches official Docmost release tarballs, infers the correct entrypoint, automatically optimizes slug size, and runs post-deploy migrations automatically.

## Quickstart

1. **Create your Scalingo app and add-ons:**
   ```sh
   scalingo --region osc-fr1 create my-docmost
   scalingo --region osc-fr1 addons-add postgresql postgresql-starter-1024
   scalingo --region osc-fr1 addons-add redis redis-starter-512
   ```
2. **Set required environment variables:**
   ```sh
   scalingo --region osc-fr1 env-set \
     APP_URL=https://docmost.example.com \
     APP_SECRET=$(openssl rand -hex 32) \
     DOCMOST_VERSION=<latest-release>
   # Optional S3 config:
   # scalingo env-set STORAGE_DRIVER=s3 AWS_S3_ACCESS_KEY_ID=... AWS_S3_SECRET_ACCESS_KEY=... \
   #   AWS_S3_REGION=eu-west-1 AWS_S3_BUCKET=my-docmost \
   #   AWS_S3_ENDPOINT=https://s3.fr-par.scw.cloud AWS_S3_FORCE_PATH_STYLE=true
   ```
3. **Deploy:**
   ```sh
   git push scalingo main
   ```
4. **Post-deploy migrations run automatically.**

## Features

- 🚀 **Automatic source download** from official Docmost releases
- 📦 **Intelligent slug size optimization** (achieves ~1420MB, under 1500MB limit)
- 🔧 **Auto-configuration** of database, Redis, and storage
- 🔍 **Debug mode** for troubleshooting size issues
- 📝 **Automatic migrations** on deployment

## Slug Size Optimization

This buildpack automatically optimizes the slug size to stay under Scalingo's 1500MB limit:

- **Removes dev dependencies**: TypeScript compiler, test frameworks, linters (~150-250MB)
- **Cleans build artifacts**: Source maps, build caches, source files (~100-150MB)
- **Removes unused locales**: Keeps only English locale files (~20-40MB)
- **Strips metadata**: Build configs, documentation (~10-20MB)

**Result**: ~250MB reduction (from 1670MB to 1420MB)

For detailed information, see [docs/slug-size-optimization.md](docs/slug-size-optimization.md).

## Configuration

### Required Environment Variables

```sh
scalingo env-set \
  APP_URL=https://docmost.example.com \
  APP_SECRET=$(openssl rand -hex 32) \
  DOCMOST_VERSION=v0.23.2
```

### Optional Configuration

- **S3 Storage**: Configure AWS S3 or compatible object storage
- **SMTP Email**: Set up email notifications
- **Custom settings**: Upload limits, JWT expiration, etc.

For a complete list of environment variables, see [docs/environment-variables.md](docs/environment-variables.md).

## Documentation

- [Installation Guide](docs/installation.md)
- [Environment Variables Reference](docs/environment-variables.md)
- [Configuration Guide](docs/configuration.md)
- [Slug Size Optimization](docs/slug-size-optimization.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Upgrade Guide](docs/upgrades.md)
- [Scalingo CLI Cheatsheet](docs/scalingo-cli-cheatsheet.md)
