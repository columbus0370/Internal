#!/bin/bash

set -e  # Exit on any error

echo "=========================================="
echo "=== Vercel Build Script (v2.0) ==="
echo "=========================================="
echo "Working directory: $(pwd)"
echo ""

# ===== STEP 1: Verify project structure =====
echo "[STEP 1] Verifying project structure..."

if [ ! -d "epl_match_simulator" ]; then
  echo "ERROR: epl_match_simulator directory not found!"
  exit 1
fi

if [ ! -f "epl_match_simulator/pubspec.yaml" ]; then
  echo "ERROR: pubspec.yaml not found!"
  exit 1
fi

if [ ! -d "api" ] || [ ! -f "api/predictMatch.js" ]; then
  echo "ERROR: api/predictMatch.js not found!"
  exit 1
fi

echo "✓ Project structure verified"
echo ""

# ===== STEP 2: Use pre-built web assets (CRITICAL) =====
echo "[STEP 2] Checking for pre-built Flutter Web assets..."

cd epl_match_simulator

if [ ! -d "build/web" ]; then
  echo "ERROR: build/web directory not found!"
  echo ""
  echo "SOLUTION: Build locally and commit to git:"
  echo "  1. flutter pub get"
  echo "  2. flutter build web --release"
  echo "  3. git add epl_match_simulator/build/web/"
  echo "  4. git commit -m 'Add pre-built web assets'"
  echo "  5. git push"
  exit 1
fi

# Verify build output has essential files
REQUIRED_FILES=("index.html" "main.dart.js" "flutter.js")
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "build/web/$file" ]; then
    echo "ERROR: Required file missing: build/web/$file"
    exit 1
  fi
done

echo "✓ Pre-built web assets found"
echo "  - Contains: $(ls build/web | wc -l) files"
echo "  - Size: $(du -sh build/web | cut -f1)"
echo "  - Key files:"
ls -1 build/web | grep -E "\.html|\.js" | head -5 | sed 's/^/    - /'
echo ""

# ===== STEP 3: Verify API layer =====
echo "[STEP 3] Verifying Serverless Functions..."

cd ..

if [ -f "api/predictMatch.js" ]; then
  echo "✓ API function found: api/predictMatch.js"
else
  echo "ERROR: api/predictMatch.js not found!"
  exit 1
fi

echo ""

# ===== STEP 4: Final verification =====
echo "[STEP 4] Final verification..."
echo "✓ Flutter Web assets: $(test -d epl_match_simulator/build/web && echo 'READY' || echo 'MISSING')"
echo "✓ API function: $(test -f api/predictMatch.js && echo 'READY' || echo 'MISSING')"
echo ""

echo "=========================================="
echo "=== Build Complete ==="
echo "=========================================="
echo ""
echo "Output structure:"
echo "  - Frontend: epl_match_simulator/build/web/"
echo "  - API: api/predictMatch.js"
echo ""
echo "Vercel will:"
echo "  1. Serve index.html for all routes (SPA)"
echo "  2. Route /api/* to Serverless Functions"
echo ""
