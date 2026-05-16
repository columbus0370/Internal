#!/bin/bash
set -e

echo "Starting Flutter Web build..."

# Flutter SDK のダウンロード（キャッシュ済みならスキップ）
if [ ! -d "_flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
else
  echo "Flutter SDK cache found"
fi

# パスを追加
export PATH="$PATH:$(pwd)/_flutter/bin"

# Flutter のセットアップ
echo "Checking Flutter version..."
flutter --version
flutter config --no-analytics
echo "Precaching web assets..."
flutter precache --web

# 依存関係取得
echo "Getting dependencies..."
cd epl_match_simulator
flutter pub get

# Web ビルド
echo "Building Flutter Web..."
flutter build web --release --web-renderer html

echo "Build completed successfully!"
