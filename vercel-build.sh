#!/bin/bash

set -e

echo "=== Flutter Web Build for Vercel ==="

# Check if epl_match_simulator directory exists
if [ ! -d "epl_match_simulator" ]; then
    echo "Error: epl_match_simulator directory not found!"
    exit 1
fi

# Navigate to Flutter project directory
cd epl_match_simulator

# Check if Flutter SDK is installed or needs update (idempotent)
if [ ! -d "$HOME/.flutter-vercel" ]; then
    echo "Installing Flutter SDK..."
    git clone https://github.com/flutter/flutter.git -b stable ~/.flutter-vercel
else
    echo "Flutter SDK already installed, updating..."
    cd ~/.flutter-vercel
    git fetch origin stable
    git checkout stable
    cd - > /dev/null
fi

# Export Flutter path with full PATH coverage
export PATH="$HOME/.flutter-vercel/bin:$HOME/.flutter-vercel/bin/cache/dart-sdk/bin:$PATH"

echo "Flutter version:"
flutter --version

echo "Building Flutter Web..."
flutter clean
flutter pub get
flutter build web --release

echo "Build completed!"
echo "Output directory: epl_match_simulator/build/web"
ls -la build/web | head -20
