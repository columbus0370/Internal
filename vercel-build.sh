#!/bin/bash

# Vercel Build Script v3.0 - Production Ready
# This script prepares pre-built Flutter Web assets and Serverless Functions for Vercel
# NO FLUTTER INSTALLATION OR COMPILATION OCCURS HERE

set -e
trap 'echo "ERROR: Build failed at line $LINENO"; exit 1' ERR

echo "=========================================="
echo "=== Vercel Build Script (v3.0) ==="
echo "=========================================="
echo "Working directory: $(pwd)"
echo "Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo ""

# CRITICAL: Remove any Flutter-related environment variables that might interfere
unset FLUTTER_HOME
unset FLUTTER_SDK
unset PATH_WITH_FLUTTER

# ===== STEP 1: Verify basic project structure =====
echo "[STEP 1] Verifying project structure..."

if [ ! -d "epl_match_simulator" ]; then
  echo "ERROR: epl_match_simulator directory not found"
  exit 1
fi

if [ ! -d "api" ] || [ ! -f "api/predictMatch.js" ]; then
  echo "ERROR: api/predictMatch.js not found"
  exit 1
fi

echo "✓ Project structure verified"
echo ""

# ===== STEP 2: Verify pre-built Flutter Web assets =====
echo "[STEP 2] Verifying pre-built Flutter Web assets..."

if [ ! -d "epl_match_simulator/build/web" ]; then
  echo "ERROR: Pre-built web assets not found!"
  echo "This deployment requires pre-built Flutter Web assets."
  echo ""
  echo "FIX: Build locally and commit to git:"
  echo "  1. cd epl_match_simulator"
  echo "  2. flutter clean && flutter pub get"
  echo "  3. flutter build web --release"
  echo "  4. cd .."
  echo "  5. git add epl_match_simulator/build/web/"
  echo "  6. git commit -m 'Add pre-built Flutter Web assets for Vercel'"
  echo "  7. git push"
  echo ""
  exit 1
fi

# Verify critical files exist
CRITICAL_FILES=("epl_match_simulator/build/web/index.html" \
                "epl_match_simulator/build/web/main.dart.js" \
                "epl_match_simulator/build/web/flutter.js")

for file in "${CRITICAL_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "ERROR: Critical file missing: $file"
    exit 1
  fi
done

WEB_ASSET_COUNT=$(find epl_match_simulator/build/web -type f | wc -l)
WEB_ASSET_SIZE=$(du -sh epl_match_simulator/build/web | cut -f1)

echo "✓ Pre-built web assets verified"
echo "  - Files: $WEB_ASSET_COUNT"
echo "  - Size: $WEB_ASSET_SIZE"
echo "  - Key files:"
echo "    • index.html"
echo "    • main.dart.js (Flutter app)"
echo "    • flutter.js (Framework)"
echo ""

# ===== STEP 3: Verify Serverless Function =====
echo "[STEP 3] Verifying Serverless Functions..."

if [ ! -f "api/predictMatch.js" ]; then
  echo "ERROR: api/predictMatch.js not found"
  exit 1
fi

API_FILE_SIZE=$(stat -f%z api/predictMatch.js 2>/dev/null || stat -c%s api/predictMatch.js 2>/dev/null)

echo "✓ API function verified: api/predictMatch.js ($API_FILE_SIZE bytes)"
echo ""

# ===== STEP 4: Final checks =====
echo "[STEP 4] Final verification..."

WEB_DIR_EXISTS=$(test -d epl_match_simulator/build/web && echo "✓" || echo "✗")
API_FILE_EXISTS=$(test -f api/predictMatch.js && echo "✓" || echo "✗")

echo "$WEB_DIR_EXISTS Flutter Web assets ready"
echo "$API_FILE_EXISTS API function ready"
echo ""

# ===== SUCCESS =====
echo "=========================================="
echo "=== Build Completed Successfully ==="
echo "=========================================="
echo ""
echo "Deployment Summary:"
echo "  Frontend:  epl_match_simulator/build/web/ ($WEB_ASSET_SIZE, $WEB_ASSET_COUNT files)"
echo "  API:       api/predictMatch.js"
echo ""
echo "Vercel Configuration:"
echo "  • Output directory: epl_match_simulator/build/web/"
echo "  • Static files will be served"
echo "  • /api/* routes to Serverless Functions"
echo "  • All other routes → index.html (SPA)"
echo ""
exit 0
