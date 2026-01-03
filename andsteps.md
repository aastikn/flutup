# High-Level Flow for Flutter Setup Script (Arch Linux)

## Global Configuration
- **Idempotency:** Ensure checks exist (e.g., `command -v`, `[ -d directory ]`) before downloading/installing.
- **Variables:** Centralize at top of script:
  ```bash
  FLUTTER_VERSION="3.38.5"
  ANDROID_API=34
  BUILD_TOOLS="34.0.0"
  JAVA_VERSION=17
  # Gradle is optional/managed by Flutter, but if needed:
  GRADLE_VERSION="9.2.0"
  ```
- **Shell Config:** Target `$HOME/.bashrc` (or `.zshrc` if detected).

## Step 1: Prerequisite Check
- Install necessary tools via `pacman` (ensure system update first):
  ```bash
  sudo pacman -Syu --noconfirm
  sudo pacman -S --needed --noconfirm curl git unzip xz zip glu ninja base-devel tar sed awk
  ```

## Step 2: Java
- Default to OpenJDK 17.
- Check if installed (`java -version`), otherwise install:
  ```bash
  sudo pacman -S --needed --noconfirm jdk17-openjdk
  ```
- Export `JAVA_HOME` (usually `/usr/lib/jvm/java-17-openjdk`).

## Step 3: Flutter
- Location: `$HOME/src/flutter`
- Check if directory exists. If not:
  - Download `flutter_linux_${FLUTTER_VERSION}-stable.tar.xz`.
  - Extract with `tar -xJf ... -C $HOME/src`.
- **Path Setup:**
  - Grep `.bashrc` for `flutter/bin` before appending.
  - Export: `export PATH="$HOME/src/flutter/bin:$PATH"`
- Run `flutter doctor` to initialize.

## Step 3.5: Android SDK
- **Location:** `$HOME/Android/Sdk` (Isolate from `~/src` workspace).
- **Structure:**
  ```text
  ~/Android/Sdk
  ├── cmdline-tools
  │   └── latest  <-- Extract here
  ├── build-tools
  ├── emulator
  ├── licenses
  ├── platforms
  └── platform-tools
  ```
- **Installation:**
  - Download command-line tools zip.
  - Create directory: `mkdir -p $HOME/Android/Sdk/cmdline-tools`.
  - Extract and move content so `cmdline-tools/latest/bin/sdkmanager` exists.
- **Environment Variables:**
  ```bash
  export ANDROID_HOME="$HOME/Android/Sdk"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
  ```
- **SDK Manager Commands:**
  ```bash
  sdkmanager --update
  # Note: 'tools' package is deprecated, do not install.
  sdkmanager "platform-tools" "platforms;android-${ANDROID_API}" "build-tools;${BUILD_TOOLS}" "emulator"
  yes | sdkmanager --licenses
  ```

## Step 4: System Dependencies (Emulator/KVM)
- Install KVM/QEMU tools for emulator performance:
  ```bash
  sudo pacman -S --needed --noconfirm qemu-full libvirt dnsmasq virt-manager bridge-utils
  sudo usermod -aG libvirt $(whoami)
  ```

## Step 5: Final Configuration
- Configure Flutter to know about Android SDK:
  ```bash
  flutter config --android-sdk "$HOME/Android/Sdk"
  flutter doctor --android-licenses
  flutter doctor
  ```