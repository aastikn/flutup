#!/bin/bash

# Fast & Idempotent Flutter Setup for Arch Linux
# Based on 'andsteps.md' high-level flow

set -u # Error on undefined variables

# --- Configuration ---
FLUTTER_VERSION="3.38.5"
ANDROID_API=35
BUILD_TOOLS="35.0.0"
JAVA_VERSION=17
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" # Version from latest known good

# Paths
CURRENT_USER=${USER:-$(whoami)}
SRC_DIR="$HOME/src"
ANDROID_HOME="$HOME/Android/Sdk"
FLUTTER_HOME="$SRC_DIR/flutter"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# --- Step 1: Prerequisites ---
log "Step 1: Checking System Prerequisites..."

# Ensure system is up to date (User might want to skip this if they just updated, but safer to include)
# read -p "Update system packages? (y/N) " -n 1 -r
# echo
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#    sudo pacman -Syu --noconfirm
# fi

log "Installing base dependencies..."
sudo pacman -S --needed --noconfirm \
    curl git unzip xz zip \
    glu ninja base-devel \
    clang cmake \
    tar sed awk

success "Prerequisites installed."

# --- Step 2: Java ---
log "Step 2: Checking Java configuration..."

if type -p java >/dev/null; then
    _java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    log "Found Java version: $_java_version"
    # Basic check - in production we might want stricter version parsing
else
    log "Java not found. Installing OpenJDK $JAVA_VERSION..."
    sudo pacman -S --needed --noconfirm jdk${JAVA_VERSION}-openjdk
fi

# Ensure JAVA_HOME is set in .bashrc
JAVA_HOME_PATH="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk"
if ! grep -q "export JAVA_HOME=$JAVA_HOME_PATH" "$HOME/.bashrc"; then
    log "Configuring JAVA_HOME in ~/.bashrc..."
    echo "" >> "$HOME/.bashrc"
    echo "# Java" >> "$HOME/.bashrc"
    echo "export JAVA_HOME=$JAVA_HOME_PATH" >> "$HOME/.bashrc"
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> "$HOME/.bashrc"
else
    log "JAVA_HOME already configured in ~/.bashrc."
fi

success "Java setup complete."

# --- Step 3: Flutter ---
log "Step 3: Setting up Flutter..."

mkdir -p "$SRC_DIR"

if [ -d "$FLUTTER_HOME" ]; then
    log "Flutter directory already exists at $FLUTTER_HOME."
else
    log "Downloading Flutter $FLUTTER_VERSION..."
    FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
    curl -C - -O "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/$FLUTTER_ARCHIVE"
    
    log "Extracting Flutter..."
    tar -xJf "$FLUTTER_ARCHIVE" -C "$SRC_DIR"
    rm "$FLUTTER_ARCHIVE"
fi

# Configure PATH
if ! grep -q "$FLUTTER_HOME/bin" "$HOME/.bashrc"; then
    log "Adding Flutter to PATH in ~/.bashrc..."
    echo "" >> "$HOME/.bashrc"
    echo "# Flutter" >> "$HOME/.bashrc"
    echo "export PATH=\"$FLUTTER_HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
else
    log "Flutter PATH already configured."
fi

# Reload PATH for current session to run flutter doctor
export PATH="$FLUTTER_HOME/bin:$PATH"

log "Running flutter doctor..."
flutter doctor

success "Flutter setup complete."

# --- Step 3.5: Android SDK ---
log "Step 3.5: Setting up Android SDK..."

mkdir -p "$ANDROID_HOME/cmdline-tools"

LATEST_TOOLS_DIR="$ANDROID_HOME/cmdline-tools/latest"

if [ -d "$LATEST_TOOLS_DIR/bin" ]; then
    log "Android Command-line Tools already installed."
else
    log "Downloading Android Command-line Tools..."
    CMD_TOOLS_ARCHIVE="commandlinetools-linux.zip"
    curl -C - -o "$CMD_TOOLS_ARCHIVE" "$CMDLINE_TOOLS_URL"
    
    log "Extracting Command-line Tools..."
    unzip -q "$CMD_TOOLS_ARCHIVE"
    
    # The zip extracts to 'cmdline-tools', we need to move it to 'latest'
    # Check if extraction created a folder named 'cmdline-tools'
    if [ -d "cmdline-tools" ]; then
        mv cmdline-tools "$LATEST_TOOLS_DIR"
    else
        log "Error: Unexpected content in commandlinetools zip."
        ls -F
        exit 1
    fi
    
    rm "$CMD_TOOLS_ARCHIVE"
fi

# Configure Android Env Vars
if ! grep -q "export ANDROID_HOME=" "$HOME/.bashrc"; then
    log "Configuring Android Environment Variables in ~/.bashrc..."
    echo "" >> "$HOME/.bashrc"
    echo "# Android SDK" >> "$HOME/.bashrc"
    echo "export ANDROID_HOME=\"$ANDROID_HOME\"" >> "$HOME/.bashrc"
    echo "export ANDROID_SDK_ROOT=\"\$ANDROID_HOME\"" >> "$HOME/.bashrc"
    echo "export PATH=\"\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/emulator:\$PATH\"" >> "$HOME/.bashrc"
else
    log "Android Environment Variables already configured."
fi

# Reload PATH for sdkmanager
export ANDROID_HOME="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

log "Updating SDK Manager and installing components..."
yes | sdkmanager --update

log "Installing Android SDK packages (API $ANDROID_API, Build Tools $BUILD_TOOLS)..."
# Install specific versions + emulator + platform-tools
yes | sdkmanager \
    "platform-tools" \
    "platforms;android-${ANDROID_API}" \
    "build-tools;${BUILD_TOOLS}" \
    "emulator"

log "Accepting licenses..."
yes | sdkmanager --licenses
yes | flutter doctor --android-licenses || true

success "Android SDK setup complete."

# --- Step 4: System Dependencies (Emulator/KVM) ---
log "Step 4: Installing Emulator/KVM dependencies..."

sudo pacman -S --needed --noconfirm \
    qemu-full libvirt dnsmasq virt-manager bridge-utils

# Add user to libvirt group
if ! groups "$CURRENT_USER" | grep -q "libvirt"; then
    log "Adding $CURRENT_USER to libvirt group..."
    sudo usermod -aG libvirt "$CURRENT_USER"
else
    log "User $CURRENT_USER is already in libvirt group."
fi

log "Note: You may need to enable libvirtd service manually: sudo systemctl enable --now libvirtd"

success "Emulator dependencies installed."

# --- Step 5: Final Configuration ---
log "Step 5: Finalizing setup..."

# Configure Flutter
log "Configuring Flutter with Android SDK path..."
flutter config --android-sdk "$ANDROID_HOME"

log "Verifying Android Licenses with Flutter..."
# This might ask for input if licenses are missing, but we accepted them via sdkmanager.
# Piping yes just in case.
yes | flutter doctor --android-licenses

log "Running final Flutter Doctor..."
flutter doctor

success "Setup Complete! Please restart your shell or run: source ~/.bashrc"




