```
sudo apt install -y libfuse2 fuse
```

Get the tar.gz
Then in unpacked Readme.md:

```sh
sudo apt install ninja-build xdg-user-dirs gnome-keyring unzip xz-utils zip

sudo snap install flutter --classic
sudo apt install google-android-cmdline-tools-11.0-installer  # version 11.0+1695033340
sudo apt install libglib2.0-dev
sudo apt install libsecret-1-dev



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

Install with:
```sh
flutter pub get

```

## Additional requirements check
```sh
pkg-config --modversion libsecret-1
0.21.4
pkgconfig --modversion glib-2.0
2.80.0
```

# REsolve glitching
```sh
sudo apt install build-essential dkms linux-headers-$(uname -r) bzip2 gcc make perl -y
cd /media/$USER/VBox_GAs_*
sudo ./VBoxLinuxAdditions.run
```


## Retry:
```sh
cd /home/ubuntu/Downloads/selfprivacy.org.app-0.*/selfprivacy.org.app
flutter pub get
flutter build linux
```

## Flutter install
```sh
sudo apt update
sudo apt install -y curl git unzip xz-utils libglu1-mesa
cd ~/Downloads
curl -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.2-stable.tar.xz
tar xf flutter.tar.xz -C ~/development
export PATH="$PATH:~/development/flutter/bin"
flutter doctor
```

## Retry
```sh
pkg-config --modversion glib-2.0
pkg-config --modversion libsecret-1

sudo apt update
sudo apt install libglib2.0-dev

sudo apt install libsecret-1-0 libsecret-1-dev

sudo snap connect flutter:desktop
```

ubuntu@ubuntu:~/Downloads/selfprivacy.org.app-0.13.3/selfprivacy.org.app$ pkg-config --modversion glib-2.0
pkg-config --modversion libsecret-1

sudo apt update
sudo apt install libglib2.0-dev

sudo apt install libsecret-1-0 libsecret-1-dev
2.80.0
0.21.4
Hit:1 http://nl.archive.ubuntu.com/ubuntu noble InRelease
Hit:2 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:3 http://nl.archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:4 http://nl.archive.ubuntu.com/ubuntu noble-backports InRelease
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
libglib2.0-dev is already the newest version (2.80.0-6ubuntu3.4).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
libsecret-1-0 is already the newest version (0.21.4-1build3).
libsecret-1-dev is already the newest version (0.21.4-1build3).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
ubuntu@ubuntu:~/Downloads/selfprivacy.org.app-0.13.3/selfprivacy.org.app$


## WORKING

0. Download tar from:
https://docs.flutter.dev/install/manual

1. Install stuff.
```
sudo apt install libglib2.0-dev
sudo apt install libsecret-1-dev

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

mkdir ~/flutter
tar xf ~/Downloads/flutter_linux_*.tar.xz -C ~/flutter
export PATH="$PATH:/home/ubuntu/flutter/flutter/bin"

nano ~/.bashrc
export PATH="$PATH:/home/ubuntu/flutter/flutter/bin"
source ~/.bashrc

sudo apt install clang cmake ninja-build libgtk-3-dev mesa-utils
sudo snap install android-studio --classic

android-studio # Required Loop through licenses/installation.
 # TODO: verify path to android sdk
flutter config --android-sdk ~/Android/Sdk
# flutter doctor --android-licenses
sudo apt install google-android-cmdline-tools-11.0-installer

# export ANDROID_HOME=/usr/lib/android-sdk
# export ANDROID_HOME=/home/a/Android/Sdk

sudo apt install adb
export ANDROID_HOME=/usr/lib/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/11.0/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

flutter doctor
# Flutter docter can give 2 issues: cmdline-tools and chrome.

 cd ~/Downloads/selfprivacy.org.app-0.13.3/selfprivacy.org.app
flutter clean
flutter pub get
flutter build linux -v

cd build/linux/x64/release/bundle/
./selfprivacy  # Or ./<your-app-binary-name>
```

Legal onion:
archiveiya74codqgiixo33q62qlrqtkgmcitqx5u2oeqnmn5bpcbiyd.onion
https://archiveiya74codqgiixo33q62qlrqtkgmcitqx5u2oeqnmn5bpcbiyd.onion

```
  }) async {
    final String stagingAcme = TlsOptions.stagingAcme ? 'true' : 'false';

    int? dropletId;
    Response? serverCreateResponse;
    final Dio client = await getClient();
    try {
      final Map<String, Object> data = {
        'name': hostName,
        'size': serverType,
        'image': 'ubuntu-24-04-x64',
        'user_data':
            '#cloud-config\n'
            'runcmd:\n'
            '- curl https://git.selfprivacy.org/SelfPrivacy/selfprivacy-nixos-infect/raw/branch/master/nixos-infect | '
            "API_TOKEN=$serverApiToken ENCODED_PASSWORD='$base64Password' "
            "DNS_PROVIDER_TOKEN=$dnsApiToken DNS_PROVIDER_TYPE=$dnsProviderType DOMAIN='$domainName' "
            "HOSTNAME=$hostName LUSER='${rootUser.login}' PROVIDER=$infectProviderName STAGING_ACME='$stagingAcme' "
            "${customSshKey != null ? "SSH_AUTHORIZED_KEY='$customSshKey'" : ""} "
            'bash 2>&1 | tee /root/nixos-infect.log',
        'region': region,
      };
      logger('Decoded data: $data');
      serverCreateResponse = await client.post('/droplets', data: data);
      dropletId = serverCreateResponse.data['droplet']['id'];
    } catch (e) {
      logger('Error while creating droplet: $e', error: e);
      return GenericResult(success: false, data: null, message: e.toString());
    } finally {
      close(client);
    }
on:
https://git.selfprivacy.org/SelfPrivacy/selfprivacy.org.app/src/commit/3d939d367914dba82f6f1e64679a8c5ceddb1bd3/lib/logic/api_maps/rest_maps/server_providers/digital_ocean/digital_ocean_api.dart
```

## Running app with log
```sh
flutter run --debug
```




cat /var/lib/tor/ssh/hostname