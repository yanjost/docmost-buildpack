# Slug Size Optimization

This buildpack automatically creates/appends to `.slugignore` to reduce the final slug size and stay under Scalingo's 1500MB limit.

## How It Works

The buildpack uses a multi-layered optimization approach inspired by Docmost's Docker multi-stage build strategy:

1. **Source Code Removal**: TypeScript source files, src/ directories, and build configs
2. **Development Tool Removal**: Build tools like Nx, Vite, TypeScript compiler, ESLint, Prettier
3. **Dev Dependency Removal**: `@types/*`, `@nestjs/cli`, `@nestjs/testing`, and other dev packages
4. **Build Artifact Cleanup**: Source maps, test files, build caches
5. **Locale Optimization**: Removes non-English mermaid diagram locales

**Expected reduction**: 200-500MB depending on dependency versions

## What Gets Removed

### Development Tools (~150-250MB)
- `node_modules/.pnpm/nx@*/`, `node_modules/.pnpm/@nx+*/`
- `node_modules/.pnpm/vite@*/`, `node_modules/.pnpm/typescript@*/`
- `node_modules/.pnpm/eslint@*/`
- `node_modules/.pnpm/@nestjs+cli@*/`, `node_modules/.pnpm/@nestjs+testing@*/`
- `node_modules/.pnpm/@types+*/` (TypeScript type definitions)
- `node_modules/.pnpm/@swc+*/`, `node_modules/.pnpm/esbuild@*/`
- `node_modules/.pnpm/@vitejs+*/`, `node_modules/.pnpm/@rollup+*/`
- `node_modules/.pnpm/webpack@*/`, `node_modules/.pnpm/@babel+*/`
- `node_modules/.pnpm/@parcel+*/`, `node_modules/.pnpm/terser@*/`
- `node_modules/.pnpm/@typescript-eslint+*/`, `node_modules/.pnpm/ts-node@*/`
- `node_modules/.pnpm/tsx@*/`

### Source Files (~50-100MB)
- `apps/*/src/`, `packages/*/src/`
- `*.ts`, `*.tsx` (except `.d.ts` files needed at runtime)
- `tsconfig.json`, `tsconfig.*.json`

### Build Artifacts (~50-100MB)
- `dist/**/*.map`, `apps/*/dist/**/*.map` (source maps)
- `.nx/`, `dist/.nx/` (Nx build cache)
- `.cache/`, `node_modules/.cache/`, `node_modules/.vite/`

### Documentation & Config (~10-20MB)
- `*.md`, `docs/`, `README*`, `LICENSE*`
- `.git/`, `.github/`, `.vscode/`
- `test/`, `tests/`, `**/*.test.js`, `**/*.spec.ts`

### Localization (~20-40MB)
Removes non-English locale files from `apps/client/dist/assets/`:
- ar, de, es, fr, it, ja, ko, pl, pt, ru, zh, nl, sv, tr, cs, da, fi, nb, uk

Keeps only English (`en-*.js`) locale files.

### Additional Optimizations
- `pnpm-lock.yaml`, `nx.json`, `crowdin.yml` (build metadata, ~1MB)
- `patches/` directory (pnpm patches, may not be needed at runtime)
- `node_modules/.modules.yaml` (pnpm metadata)

## Technical Note: Dependency Pruning

The nodejs-buildpack automatically runs `pnpm prune --prod` after building, which removes devDependencies. However, since Scalingo's `.slugignore` is processed AFTER buildpack completion, we use aggressive patterns to ensure any remaining dev tools are excluded from the final slug.

The optimizations are automatically added to `.slugignore` with a marker:
```
.gitignore
.env.example
docker-compose*.yml
Dockerfile*
.dockerignore
LICENSE*
apps/client/src/
apps/server/src/
packages/*/src/
node_modules/.pnpm/nx@*/
...
DOCMOST_BUILDPACK_OPTIMIZATIONS
```

**Note**: Unlike `.gitignore`, `.slugignore` doesn't support comments or negation (!) patterns, so the buildpack only includes file patterns.

You can add additional entries to `.slugignore` in your app repository - the buildpack will append its optimizations without duplicating.

## Debugging Slug Size Issues

If your deployment still exceeds the 1500MB limit, enable detailed size analysis:

```sh
scalingo --region osc-fr1 env-set DOCMOST_DEBUG_SIZE=true
git push scalingo main
```

This will output a comprehensive breakdown during build:
- Total build directory size
- Top 20 largest directories
- node_modules breakdown by package
- .pnpm virtual store analysis
- Detection of files that should have been removed
- TypeScript source file count
- Source map analysis
- Current .slugignore content

The analysis helps identify:
- Which packages are taking the most space
- Whether dev dependencies were properly pruned
- If source files are still present
- What .slugignore patterns are actually working

**Example output:**
```
>>> Top 20 largest packages in node_modules:
245M    node_modules/@aws-sdk
189M    node_modules/@nestjs
156M    node_modules/.pnpm
...
```

After identifying the issue, disable the debug mode:
```sh
scalingo --region osc-fr1 env-unset DOCMOST_DEBUG_SIZE
```

### Important Note: Analysis Timing

The size analysis currently runs **before** the nodejs-buildpack builds the application, so it shows the source code size, not the final built slug size. To analyze the **final** slug size (after build, after pnpm prune, but before .slugignore), you would need to add this buildpack twice:

```
# .buildpacks
https://github.com/yanjost/docmost-buildpack  # Downloads & configures
https://github.com/Scalingo/nodejs-buildpack   # Builds with pnpm
https://github.com/yanjost/docmost-buildpack  # Analyzes final size
```

However, since the current approach achieved the desired result (1420MB < 1500MB limit), this advanced configuration is not necessary unless you need to debug further.

## Results

With these optimizations, Docmost deployments achieve:
- **Original size**: ~1670 MB
- **Optimized size**: ~1420 MB
- **Reduction**: 250 MB (15%)
- **Status**: ✅ Under Scalingo's 1500MB limit
