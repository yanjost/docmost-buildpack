# Docmost Buildpack for Scalingo

This repository provides a production-grade Heroku-style buildpack for deploying [Docmost](https://github.com/docmost/docmost) on Scalingo. It automates installation, configuration, and deployment, leveraging Scalingo's PostgreSQL and Redis add-ons, with optional S3 storage and SMTP support. The buildpack fetches official Docmost release tarballs, infers the correct entrypoint, and runs post-deploy migrations automatically.

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

See `/docs/` for full installation, configuration, upgrade, and troubleshooting guides.
