#!/bin/bash

# FALLBACK BUILD SCRIPT - Use only if primary vercel-build.sh fails
# This script does NOT attempt to build Flutter
# It only verifies that pre-built assets exist

set -e

echo "=========================================="
echo "=== FALLBACK Build Script (Minimal) ==="
echo "=========================================="
echo ""
echo "WARNING: This is the FALLBACK script."
echo "Normal deployments should use: npm run vercel-build"
echo ""

# Verify minimal requirements
echo "[CHECK 1] Project structure..."
test -d epl_match_simulator || (echo "ERROR: epl_match_simulator not found" && exit 1)
test -f epl_match_simulator/build/web/index.html || (echo "ERROR: build/web/index.html not found" && exit 1)
test -d api || (echo "ERROR: api directory not found" && exit 1)
test -f api/predictMatch.js || (echo "ERROR: api/predictMatch.js not found" && exit 1)

echo "✓ All required files present"
echo ""

echo "[CHECK 2] Pre-built web assets..."
FILE_COUNT=$(find epl_match_simulator/build/web -type f | wc -l)
ASSET_SIZE=$(du -sh epl_match_simulator/build/web/ | cut -f1)

echo "✓ Files: $FILE_COUNT"
echo "✓ Size: $ASSET_SIZE"
echo ""

echo "=========================================="
echo "=== Fallback Build Complete ==="
echo "=========================================="
echo ""
echo "✓ Frontend ready at: epl_match_simulator/build/web/"
echo "✓ API ready at: api/"
echo ""
