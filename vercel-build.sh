#!/bin/bash

echo "=== Flutter Web Build Script Started ==="
echo "Current working directory: $(pwd)"

# チェック: epl_match_simulator ディレクトリが存在するか
if [ ! -d "epl_match_simulator" ]; then
  echo "ERROR: epl_match_simulator directory not found!"
  exit 1
fi

cd epl_match_simulator

# チェック: pubspec.yaml が存在するか
if [ ! -f "pubspec.yaml" ]; then
  echo "ERROR: pubspec.yaml not found in epl_match_simulator!"
  exit 1
fi

echo "=== Checking if Flutter is available ==="
if ! command -v flutter &> /dev/null; then
  echo "Flutter not found, attempting to download..."

  if [ ! -d "../_flutter" ]; then
    echo "Downloading Flutter SDK..."
    cd ..

    # 最新の stable Flutter リリースを取得
    echo "Fetching latest Flutter stable release..."
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/flutter/flutter/releases | grep -o '"tag_name": "[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -z "$LATEST_RELEASE" ]; then
      # API 失敗時のフォールバック
      echo "Using fallback Flutter version..."
      LATEST_RELEASE="3.24.0"
    fi

    echo "Downloading Flutter $LATEST_RELEASE..."
    DOWNLOAD_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${LATEST_RELEASE}-stable.tar.xz"

    curl -L "$DOWNLOAD_URL" -o flutter.tar.xz 2>&1

    if [ $? -ne 0 ] || [ ! -f "flutter.tar.xz" ]; then
      echo "ERROR: Failed to download Flutter SDK from $DOWNLOAD_URL"
      exit 1
    fi

    echo "Extracting Flutter SDK..."
    tar -xf flutter.tar.xz

    if [ $? -ne 0 ]; then
      echo "ERROR: Failed to extract Flutter SDK"
      exit 1
    fi

    mv flutter _flutter
    rm -f flutter.tar.xz
    cd epl_match_simulator
  fi

  export PATH="../_flutter/bin:$PATH"
fi

echo "Flutter version:"
flutter --version

echo ""
echo "=== Configuring Flutter ==="
flutter config --no-analytics

echo ""
echo "=== Getting dependencies ==="
flutter pub get

if [ $? -ne 0 ]; then
  echo "ERROR: flutter pub get failed"
  exit 1
fi

echo ""
echo "=== Building Flutter Web ==="
flutter build web --release

if [ $? -ne 0 ]; then
  echo "ERROR: Flutter build failed"
  exit 64
fi

echo ""
echo "=== Verifying build output ==="
if [ -d "build/web" ]; then
  echo "SUCCESS: build/web directory created"
  echo "Contents:"
  ls -la build/web | head -15
else
  echo "ERROR: build/web directory not found!"
  exit 1
fi

echo ""
echo "=== Build completed successfully ==="
