#!/bin/bash
set -e

# Navigate to project root (script lives in scripts/)
cd "$(dirname "$0")/.."

echo "=== Re-Link Release Build ==="
echo "Project root: $(pwd)"
echo ""

# Step 1: Get dependencies
echo "[1/4] Running flutter pub get..."
flutter pub get

# Step 2: Code generation
echo "[2/4] Running build_runner..."
dart run build_runner build --delete-conflicting-outputs

# Step 3: Build Android APK
echo "[3/4] Building Android APK (release)..."
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info/android \
  --split-per-abi

echo "  Android APK output: build/app/outputs/flutter-apk/"

# Step 4: Build iOS IPA
echo "[4/4] Building iOS IPA (release, no codesign)..."
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/debug-info/ios \
  --no-codesign

echo "  iOS IPA output: build/ios/ipa/"

echo ""
echo "=== Build Complete ==="
echo "Android APKs : build/app/outputs/flutter-apk/"
echo "iOS IPA      : build/ios/ipa/"
echo "Debug symbols: build/debug-info/"
