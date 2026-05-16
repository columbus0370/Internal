#!/bin/bash
set -e

# Flutter SDK のダウンロード（キャッシュ済みならスキップ）
if [ ! -d "_flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
fi

# パスを追加
export PATH="$PATH:$(pwd)/_flutter/bin"

# Flutter のセットアップ
flutter --version
flutter config --no-analytics
flutter precache --web

# 依存関係取得
cd epl_match_simulator
flutter pub get

# Web ビルド
flutter build web --release

echo "Build completed!"
