# Installation Guide: Docmost on Scalingo

## Prerequisites
- Scalingo CLI installed
- Region: osc-fr1

## Create App & Add-ons
```sh
scalingo --region osc-fr1 create my-docmost
scalingo --region osc-fr1 addons-add postgresql:postgresql-starter-1024
scalingo --region osc-fr1 addons-add redis:redis-starter-512
```

## Set Environment Variables
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

## Deploy
```sh
git push scalingo main
```

## Post-deploy Migrations
Migrations run automatically via postdeploy:
```
postdeploy: pnpm nx run server:migration:latest
```

## First Login & Health Check
- Visit `$APP_URL` in your browser
- Check logs: `scalingo -a <app> logs -f`
