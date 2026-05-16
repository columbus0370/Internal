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

# プリビルド済みアセットを確認
if [ -d "build/web" ]; then
  echo "=== Using pre-built Flutter Web assets ==="
  echo "SUCCESS: build/web directory found"
  echo "Contents:"
  ls -la build/web | head -15
  echo ""
  echo "=== Build completed successfully (using pre-built assets) ==="
  exit 0
fi

echo "=== Pre-built assets not found. Checking if Flutter is available ==="
if ! command -v flutter &> /dev/null; then
  echo "Flutter not found, attempting to download..."

  if [ ! -d "../_flutter" ]; then
    echo "Downloading Flutter SDK..."
    cd ..

    # Flutter バージョン 3.41.9 を使用（flutter_test との互換性が確認済み）
    FLUTTER_VERSION="3.41.9"

    echo "Downloading Flutter $FLUTTER_VERSION..."
    DOWNLOAD_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

    # タイムアウト設定を追加し、より堅牢なダウンロード処理
    echo "Download URL: $DOWNLOAD_URL"
    curl -L --max-time 600 --connect-timeout 30 "$DOWNLOAD_URL" -o flutter.tar.xz 2>&1

    if [ $? -ne 0 ] || [ ! -f "flutter.tar.xz" ]; then
      echo "ERROR: Failed to download Flutter SDK from $DOWNLOAD_URL"
      echo "Note: Try rebuilding locally and committing build/web to git"
      exit 1
    fi

    # ファイルタイプ検証
    FILE_TYPE=$(file flutter.tar.xz | grep -o "XZ compressed data")
    if [ -z "$FILE_TYPE" ]; then
      echo "ERROR: Downloaded file is not valid XZ compressed data"
      file flutter.tar.xz
      exit 1
    fi

    echo "Extracting Flutter SDK..."
    tar -xf flutter.tar.xz 2>&1

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
