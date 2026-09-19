# AeroSlate deployment guide

AeroSlate is packaged as a static web bundle inside an Nginx container. The
repository is deployed to Coolify at `https://air.uxi.asia`.

## Local build

Run from this directory:

```bash
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build web --release --base-href=/ --no-source-maps
```

## Container build

Build and run the production container locally:

```bash
docker build --tag aeroslate-web:local .
docker run --rm --publish 127.0.0.1:8080:80 aeroslate-web:local
```

The container listens on port `80`. Nginx serves static files directly and
falls back to `index.html` for application routes. The `assets/` and `pdfrx/`
directories are never rewritten.

## Runtime behavior

The bundle contains both demo PDFs and opens the AeroSlate publication viewer without authentication or API configuration. The browser only requests files from the generated static bundle during startup and document loading.

## Coolify deployment

The Coolify application uses the public GitHub repository, the `main` branch,
the repository Dockerfile, and container port `80`. The public domain is
`https://air.uxi.asia`; no application environment variables or public host
port bindings are required.

GitHub Actions runs analysis, tests, the release build, and a Docker smoke test
before triggering Coolify on successful pushes to `main`. The deployment
credentials are stored as the GitHub Actions `production` environment secrets
`COOLIFY_WEBHOOK` and `COOLIFY_TOKEN`.
