#!/usr/bin/env bash
#
# build_release.sh — Re-Link optimized release build script
#
# Usage:
#   ./build_release.sh ios        # Build IPA only
#   ./build_release.sh android    # Build AAB only
#   ./build_release.sh all        # Build both (default)
#   ./build_release.sh analyze    # Build IPA with size analysis
#
set -euo pipefail

DEBUG_INFO_DIR="build/debug-info"
COMMON_FLAGS=(
  --release
  --obfuscate
  --split-debug-info="$DEBUG_INFO_DIR"
  --dart-define=FLUTTER_BUILD_MODE=release
)

echo "============================================"
echo "  Re-Link Release Build"
echo "  Flutter $(flutter --version --machine 2>/dev/null | grep -o '"frameworkVersion":"[^"]*"' | cut -d'"' -f4 || echo 'unknown')"
echo "============================================"
echo ""

# Ensure debug-info output directory exists
mkdir -p "$DEBUG_INFO_DIR"

build_ios() {
  echo "[iOS] Building IPA with obfuscation + split-debug-info..."
  flutter build ipa "${COMMON_FLAGS[@]}" "$@"
  echo ""
  echo "[iOS] Build complete. Debug symbols saved to: $DEBUG_INFO_DIR"
  echo "[iOS] IPA location: build/ios/ipa/"
  echo ""
}

build_android() {
  echo "[Android] Building App Bundle with obfuscation + split-debug-info..."
  flutter build appbundle "${COMMON_FLAGS[@]}" "$@"
  echo ""
  echo "[Android] Build complete. Debug symbols saved to: $DEBUG_INFO_DIR"
  echo "[Android] AAB location: build/app/outputs/bundle/release/"
  echo ""
}

build_analyze() {
  echo "[iOS] Building IPA with size analysis..."
  flutter build ipa "${COMMON_FLAGS[@]}" --analyze-size
  echo ""
  echo "[iOS] Size analysis complete. Check the DevTools link above for details."
  echo ""
}

TARGET="${1:-all}"

case "$TARGET" in
  ios)
    build_ios
    ;;
  android)
    build_android
    ;;
  all)
    build_ios
    build_android
    echo "============================================"
    echo "  All builds complete!"
    echo "  Debug symbols: $DEBUG_INFO_DIR"
    echo "============================================"
    ;;
  analyze)
    build_analyze
    ;;
  *)
    echo "Usage: $0 {ios|android|all|analyze}"
    exit 1
    ;;
esac
