#!/bin/bash

# Test script to simulate Vercel build environment locally

set -e

echo "=========================================="
echo "=== Local Build Test ==="
echo "=========================================="
echo ""
echo "This script simulates the Vercel build process"
echo "Useful for testing before pushing to Vercel"
echo ""

# Check Node.js version
echo "[CHECK] Node.js and npm..."
node --version
npm --version
echo ""

# Run build
echo "[BUILD] Running build script..."
echo ""

bash ./vercel-build.sh

if [ $? -eq 0 ]; then
  echo ""
  echo "=========================================="
  echo "✓ BUILD PASSED"
  echo "=========================================="
  echo ""
  echo "Next steps:"
  echo "  1. git push to Vercel"
  echo "  2. Monitor build at: https://vercel.com"
  echo "  3. Check logs if deployment fails"
  echo ""
else
  echo ""
  echo "=========================================="
  echo "✗ BUILD FAILED"
  echo "=========================================="
  echo ""
  echo "Fix issues above and try again:"
  echo "  bash test-build.sh"
  echo ""
  exit 1
fi
