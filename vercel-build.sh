#!/bin/bash

set -e

echo "=== Flutter Web Build for Vercel ==="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Installing Flutter SDK..."
    git clone https://github.com/flutter/flutter.git -b stable ~/.flutter-vercel
    export PATH="$HOME/.flutter-vercel/bin:$PATH"
fi

# Export Flutter path
export PATH="$HOME/.flutter-vercel/bin:$PATH"

echo "Flutter version:"
flutter --version

echo "Building Flutter Web..."
cd epl_match_simulator
flutter clean
flutter pub get
flutter build web --release

echo "Build completed!"
echo "Output directory: build/web"
ls -la build/web | head -20
