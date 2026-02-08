# SelfPrivacy App

## Prerequisites (Ubuntu/Debian)

```bash
# Install build dependencies
sudo apt install ninja-build clang cmake pkg-config git curl \
  libgtk-3-dev libsecret-1-dev libjsoncpp-dev libblkid-dev \
  liblzma-dev xdg-user-dirs gnome-keyring unzip xz-utils zip

# Install Flutter to /opt (NOT snap - snap causes GLib version conflicts)
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.2-stable.tar.xz | sudo tar xJf - -C /opt
echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

# Install Tor daemon (for .onion connectivity)
sudo apt install tor
sudo systemctl enable --now tor

# Verify Tor is running on port 9050
ss -tlnp | grep 9050
```

Then build and run:
```bash
flutter pub get
flutter build linux
./build/linux/x64/release/bundle/selfprivacy
```

## Connecting to a .onion Backend

First, deploy the backend (see `Manager-Ubuntu-SelfPrivacy-Over-Tor/backend/`):
```bash
cd ../Manager-Ubuntu-SelfPrivacy-Over-Tor/backend
./build-and-run.sh
```

Then get your .onion address and recovery key:
```bash
cd SelfPrivacy-Flutter-Ubuntu-and-Android-App-Over-Tor
./get-recovery-key.sh
```

In the app:
1. Choose "I already have a server"
2. Enter your `.onion` address (without `http://`)
3. Select "I have a recovery key"
4. Enter the recovery key mnemonic phrase

## Resetting App Data (Start Fresh Connection)

To clear the app's stored configuration and start a new connection:
```bash
rm -rf ~/.local/share/selfprivacy/*.hive ~/.local/share/selfprivacy/*.lock
```

---

SelfPrivacy — is a platform on your cloud hosting, that allows to deploy your own private services and control them using mobile application.

To use this application, you'll be required to create accounts of different service providers. Please reffer to this manual: https://selfprivacy.org/docs/getting-started/

Application will do the following things for you:

1. Create your personal server
2. Setup NixOS
3. Bring all services to the ready-to-use state. Services include:

* E-mail, ready to use with DeltaChat
* NextCloud - your personal cloud storage
* Bitwarden — secure and private password manager
* Pleroma — your private fediverse space for blogging
* Jitsi — awesome Zoom alternative
* Gitea — your own Git server
* OpenConnect — Personal VPN server

**Project is currently in open beta state**. Feel free to try it. It would be much appreciated if you would provide us with some feedback. 

## Building

Supported platforms are Android, Linux, and Windows. We are looking forward to support iOS and macOS builds.

For Linux builds, make sure you have these packages installed:
|Arch-based|Debian-based|
|----------|------------|
|pacman -S ninja xdg-user-dirs gnome-keyring unzip xz-utils zip|apt install ninja-build xdg-user-dirs gnome-keyring unzip xz-utils zip|

Install [Flutter](https://docs.flutter.dev/get-started/install/linux) and [Android SDK tools](https://developer.android.com/studio/command-line/sdkmanager), then try your setup:

```
flutter pub get

# Build .APK for Android
flutter build apk --flavor production
# Build nightly .APK for Android
flutter build apk --flavor nightly
# Build AAB bundle for Google Play
flutter build aab --flavor production
# Build Linux binaries
flutter build linux
# Build Windows binaries
flutter build windows

# Package AppImage
appimage-builder --recipe appimage.yml
# Package Flatpak
flatpak-builder --force-clean --repo=flatpak-repo flatpak-build flatpak.yml
flatpak build-bundle flatpak-repo org.selfprivacy.app.flatpak org.selfprivacy.app
```

## Translations

[![Translation status](http://weblate.selfprivacy.org/widgets/selfprivacy/-/selfprivacy-app/multi-auto.svg)](http://weblate.selfprivacy.org/engage/selfprivacy/)

Translations are stored in `assets/translations/*.json` and can be edited on <https://weblate.selfprivacy.org/projects/selfprivacy/selfprivacy-app/>.
