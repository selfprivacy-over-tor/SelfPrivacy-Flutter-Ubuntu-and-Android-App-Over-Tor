# SelfPrivacy App (Tor-Modified)

SelfPrivacy is a platform on your cloud hosting that allows you to deploy your own private services and control them using a mobile/desktop application. This fork adds Tor hidden service (.onion) support.

This app is managed by the parent project: [Manager-Ubuntu-SelfPrivacy-Over-Tor](../../README.md).

## Quick Start

From the manager repo root:

```bash
# Install dependencies
./scripts/requirements.sh --app-linux     # for Linux desktop
./scripts/requirements.sh --app-android   # for Android

# Run
cd backend
./build-and-run.sh --app-linux            # build & launch on Linux
./build-and-run.sh --app-android          # build & deploy to Android device
```

## Build Flavors

- `production` — Production release (recommended for Tor builds)
- `fdroid` — F-Droid release (different application ID)
- `nightly` — Development builds

## Tor Proxy

The app connects to `.onion` addresses through a SOCKS5 proxy on `127.0.0.1:9050`.

- **Linux**: `sudo systemctl start tor` (installed by `requirements.sh`)
- **Android emulator**: `adb reverse tcp:9050 tcp:9050` (forwards host Tor to emulator)
- **Android device**: Install [Orbot](https://play.google.com/store/apps/details?id=org.torproject.android)

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Connection timeout | Ensure Tor is running: `ss -tlnp \| grep 9050` |
| Copy/paste broken (Linux) | Known Flutter bug [#125975](https://github.com/flutter/flutter/issues/125975) — type manually |
| GraphQL errors | Check backend: `curl --socks5-hostname 127.0.0.1:9050 http://ONION.onion/api/version` |

## Translations

[![Translation status](http://weblate.selfprivacy.org/widgets/selfprivacy/-/selfprivacy-app/multi-auto.svg)](http://weblate.selfprivacy.org/engage/selfprivacy/)

Translations are stored in `assets/translations/*.json` and can be edited on <https://weblate.selfprivacy.org/projects/selfprivacy/selfprivacy-app/>.
