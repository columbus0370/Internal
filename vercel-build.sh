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
    # curl を使用してダウンロード（git が使えない場合の代替）
    cd ..
    curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz -o flutter.tar.xz
    if [ $? -ne 0 ]; then
      echo "ERROR: Failed to download Flutter SDK"
      exit 1
    fi
    tar -xf flutter.tar.xz
    mv flutter _flutter
    rm flutter.tar.xz
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
flutter build web --release --no-fast-start

if [ $? -ne 0 ]; then
  echo "ERROR: Flutter build failed"
  exit 1
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
