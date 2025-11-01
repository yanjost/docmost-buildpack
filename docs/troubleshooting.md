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

## Slug Size Exceeds 1500MB

The most common issue is the slug exceeding Scalingo's 1500MB limit. This buildpack includes aggressive optimizations, but you may need to debug further.

### Enable Size Analysis

```sh
scalingo --region osc-fr1 env-set DOCMOST_DEBUG_SIZE=true
git push scalingo main
```

This outputs detailed size information during build.

### What to Look For

1. **Dev dependencies still present**: Check if packages like `@types/*`, `@nestjs/cli`, `typescript`, `eslint`, `prettier` are listed
   - If found: The `pnpm prune --prod` might not be working correctly
   - Solution: Report the issue with the debug output

2. **Large production dependencies**: Some packages are legitimately large
   - `@aws-sdk`: 200-300MB (needed for S3)
   - `@nestjs/*`: 100-200MB (needed for backend)
   - `@tiptap/*`: 50-100MB (needed for editor)
   - These cannot be removed if you use the features

3. **Source files still present**: Check for `apps/*/src/` directories
   - If found: The `.slugignore` patterns aren't matching
   - Solution: Verify `.slugignore` file content in debug output

4. **Locale files**: Check `apps/client/dist/assets/` for non-English locales
   - Files like `*-fr-*.js`, `*-de-*.js` should be removed
   - Only `*-en-*.js` should remain

### Common Solutions

**If dev dependencies are still present:**
```sh
# Check if NODE_ENV is set correctly
scalingo env | grep NODE_ENV
# Should be 'production' or unset
```

**If specific packages are too large:**
Add them to your own `.slugignore` file in your app repo (not the buildpack):
```
node_modules/some-large-package/
```

**If still over the limit:**
Consider using Scalingo's L instances which have higher limits, or contact Scalingo support to discuss your specific case.

### Disable Debug Mode

After debugging:
```sh
scalingo --region osc-fr1 env-unset DOCMOST_DEBUG_SIZE
```

### Advanced: Analyzing Post-Build Size

**Note**: The current size analysis runs **before** the nodejs-buildpack builds the application, so it only shows source code size. To analyze the size **after** the build completes (but before .slugignore processing), you can add the buildpack twice:

```
# .buildpacks
https://github.com/yanjost/docmost-buildpack  # 1. Downloads & configures
https://github.com/Scalingo/nodejs-buildpack   # 2. Builds with pnpm
https://github.com/yanjost/docmost-buildpack  # 3. Analyzes final size
```

This advanced setup is only needed if you want to see exactly what's in node_modules after pnpm prune but before .slugignore removes files. Since the current optimizations achieved 1420MB (under the 1500MB limit), this is typically not necessary.
