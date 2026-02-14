# SelfPrivacy App (Tor-Modified)

SelfPrivacy is a platform on your cloud hosting that allows you to deploy your own private services and control them using a mobile/desktop application. This fork adds Tor hidden service (.onion) support.

## Prerequisites (Ubuntu/Debian)

### For Linux Desktop

```bash
# Install build dependencies
sudo apt install ninja-build clang cmake pkg-config git curl \
  libgtk-3-dev libsecret-1-dev libjsoncpp-dev libblkid-dev \
  liblzma-dev xdg-user-dirs gnome-keyring unzip xz-utils zip \
  libstdc++-12-dev

# Install Flutter to /opt (NOT snap - snap causes GLib version conflicts)
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.2-stable.tar.xz | sudo tar xJf - -C /opt
echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

# Install and start Tor SOCKS proxy
sudo apt install tor
sudo systemctl enable --now tor

# Verify Tor is running on port 9050
ss -tlnp | grep 9050
```

### For Android

```bash
# Install Android SDK
# Option A: Install Android Studio from https://developer.android.com/studio
# Option B: Command-line only:
mkdir -p ~/Android/Sdk && cd ~/Android/Sdk
curl -sL "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -o cmdline-tools.zip
unzip cmdline-tools.zip && mkdir -p cmdline-tools && mv cmdline-tools cmdline-tools/latest
export ANDROID_HOME=~/Android/Sdk
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platforms;android-35" "build-tools;36.1.0" "platform-tools"
flutter config --android-sdk ~/Android/Sdk

# For Android emulator: enable KVM (required for usable speed)
sudo modprobe kvm && sudo modprobe kvm_intel && sudo chmod 666 /dev/kvm
```

## Running the Linux Desktop App

### Step 1: Start Tor SOCKS Proxy on Host

```bash
# Option 1: Use system Tor
sudo systemctl start tor

# Option 2: Run Tor with custom config
cat > /tmp/user-torrc << 'EOF'
SocksPort 9050
Log notice stdout
EOF
tor -f /tmp/user-torrc &
```

Verify Tor is running:
```bash
curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/api/ip
```

### Step 2: Run Flutter App with Logs

```bash
flutter pub get
flutter run -d linux --verbose 2>&1 | tee /tmp/flutter-app.log
```

### Step 3: Connect to Backend

In the app:
1. Choose "I already have a server" (recovery flow)
2. Enter your .onion address: `YOUR_ONION_ADDRESS.onion`
3. Enter recovery key (18-word BIP39 mnemonic)

**Note:** Copy/paste may not work in Flutter Linux desktop. Type manually if needed.

### Viewing Logs

```bash
# Live logs during runtime (verbose)
# Already shown in terminal if using command above

# Or tail the log file
tail -f /tmp/flutter-app.log

# Search for GraphQL responses
grep "GraphQL Response" /tmp/flutter-app.log

# Search for errors
grep -i error /tmp/flutter-app.log
```

## Building and Running Android APK

The Android app is built from the same Flutter source code with the `production` flavor.

### Build Debug APK

```bash
flutter pub get
flutter build apk --flavor production --debug

# APK is at: build/app/outputs/flutter-apk/app-production-debug.apk
```

The app will show a setup screen at launch where you enter the onion domain and API token.

To bake in the domain at compile time instead (skips the setup screen):
```bash
ONION=$(sshpass -p '' ssh -p 2222 root@localhost cat /var/lib/tor/hidden_service/hostname)
flutter build apk --flavor production --debug \
  --dart-define=ONION_DOMAIN=$ONION \
  --dart-define=API_TOKEN=test-token-for-tor-development
```

### Tor Proxy Requirement (Android)

The app connects to `.onion` addresses through a SOCKS5 proxy on `127.0.0.1:9050`. On Android, **you must provide this proxy** — otherwise the app will hang on loading screens (services, server logs, etc.).

- **Emulator**: Use `adb reverse` to forward port 9050 from the emulator to the host's Tor daemon (see below)
- **Physical device**: Install [Orbot](https://play.google.com/store/apps/details?id=org.torproject.android) and enable it before opening the app

### Install on Android Emulator

```bash
# Enable KVM first (required for usable emulator speed)
sudo modprobe kvm && sudo modprobe kvm_intel && sudo chmod 666 /dev/kvm

# Start emulator (create one in Android Studio first, or use avdmanager)
export ANDROID_HOME=~/Android/Sdk
$ANDROID_HOME/emulator/emulator -avd Medium_Phone_API_36.1 -no-audio &

# Wait for boot
$ANDROID_HOME/platform-tools/adb wait-for-device

# Forward emulator's port 9050 to host's Tor daemon
$ANDROID_HOME/platform-tools/adb reverse tcp:9050 tcp:9050

# Install the APK
$ANDROID_HOME/platform-tools/adb install build/app/outputs/flutter-apk/app-production-debug.apk
```

### Install on Physical Android Device

1. Install [Orbot](https://play.google.com/store/apps/details?id=org.torproject.android) (Tor proxy for Android)
2. Open Orbot and start Tor — it listens on port 9050 by default
3. Transfer the APK to the device and install it
4. Open the app — it connects through Orbot's SOCKS5 proxy to your .onion backend

**Note:** To open services (Nextcloud, Jitsi, etc.) in the browser from the app, you also need Orbot in "VPN mode" or a Tor-capable browser (e.g., Tor Browser for Android).

### Android Logs

```bash
# View Flutter and SelfPrivacy logs
adb logcat -s flutter,SelfPrivacy

# View all app logs (verbose)
adb logcat | grep -i selfprivacy
```

### Build Flavors

The app has multiple build flavors:
- `production` - Production release (recommended for Tor builds)
- `fdroid` - F-Droid release (different application ID)
- `nightly` - Development builds

## Resetting App Data (Start Fresh Connection)

To clear the app's stored configuration and start a new connection:
```bash
rm -rf ~/.local/share/selfprivacy/*.hive ~/.local/share/selfprivacy/*.lock
```

## Getting Nextcloud access

username=`admin`
```sh
sshpass -p '' ssh -p 2222 -o StrictHostKeyChecking=no root@localhost 'cat /var/lib/nextcloud/admin-pass'
```

## Troubleshooting

### "Connection refused" or timeout
- Ensure Tor SOCKS proxy is running on port 9050
- Check: `curl --socks5-hostname 127.0.0.1:9050 http://YOUR_ONION.onion/api/version`

### "Invalid recovery key"
- The key must be a 18-word BIP39 mnemonic phrase, NOT a hex string
- Example format: `word1 word2 word3 ... word18`

### DNS lookup errors
- Should not happen with .onion domains (they skip DNS lookup)
- If it does, verify the modifications in `server_installation_repository.dart`

### Copy/paste not working (Linux)
- Known Flutter Linux desktop bug ([flutter#125975](https://github.com/flutter/flutter/issues/125975))
- Workaround applied in `main.dart` suppresses the assertion error in debug mode
- Fixed upstream in Flutter PR [#181894](https://github.com/flutter/flutter/pull/181894), expected in stable ~3.44
- If still not working, type the recovery key manually

### GraphQL errors in logs
- Check backend logs to see if request arrived
- Verify .onion address is correct
- Ensure backend API is running: `curl --socks5-hostname 127.0.0.1:9050 http://YOUR_ONION.onion/graphql`

## Translations

[![Translation status](http://weblate.selfprivacy.org/widgets/selfprivacy/-/selfprivacy-app/multi-auto.svg)](http://weblate.selfprivacy.org/engage/selfprivacy/)

Translations are stored in `assets/translations/*.json` and can be edited on <https://weblate.selfprivacy.org/projects/selfprivacy/selfprivacy-app/>.
