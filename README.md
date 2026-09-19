# AeroSlate document viewer

This directory contains the web-only Flutter application and its bundled demo
technical publications.

Run the local checks with:

```bash
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build web --release --base-href=/ --no-source-maps
```

The application opens the bundled AeroSlate demo publication directly. See
[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for Docker and Coolify deployment
notes.
