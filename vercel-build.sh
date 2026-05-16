#!/bin/bash
set -e

echo "=== Flutter Web Build Script Started ==="
echo "Current working directory: $(pwd)"
echo "User: $(whoami)"
echo "Node version: $(node --version)"
echo "Npm version: $(npm --version)"

echo ""
echo "=== Checking environment ==="
ls -la | head -20

echo ""
echo "=== Flutter SDK Setup ==="
if [ ! -d "_flutter" ]; then
  echo "Flutter SDK not found in _flutter directory, cloning..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
else
  echo "Flutter SDK cache found in _flutter directory"
fi

# パスを追加
export PATH="$PATH:$(pwd)/_flutter/bin"
echo "PATH updated: $PATH"

# Flutter のセットアップ
echo ""
echo "=== Flutter Configuration ==="
echo "Checking Flutter version..."
flutter --version
flutter config --no-analytics

echo ""
echo "=== Precaching web assets ==="
echo "Precaching web assets..."
flutter precache --web

# 依存関係取得
echo ""
echo "=== Getting Flutter dependencies ==="
echo "Current directory before cd: $(pwd)"
if [ -d "epl_match_simulator" ]; then
  echo "epl_match_simulator directory found"
  cd epl_match_simulator
  echo "Changed to: $(pwd)"
  ls -la | head -10
  flutter pub get
else
  echo "ERROR: epl_match_simulator directory not found!"
  echo "Contents of $(pwd):"
  ls -la
  exit 1
fi

# Web ビルド
echo ""
echo "=== Building Flutter Web ==="
echo "Building Flutter Web with release mode..."
flutter build web --release --web-renderer html

echo ""
echo "=== Build Output Verification ==="
if [ -d "build/web" ]; then
  echo "build/web directory created successfully"
  echo "Contents of build/web:"
  ls -la build/web | head -20
else
  echo "WARNING: build/web directory not found!"
  echo "Contents of current directory:"
  ls -la | head -20
fi

echo ""
echo "=== Flutter Web Build completed successfully! ==="
