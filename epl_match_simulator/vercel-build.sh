#!/bin/bash
set -e

echo "Building Flutter web app..."
flutter pub get
flutter build web --release --web-renderer html

echo "Build complete!"
