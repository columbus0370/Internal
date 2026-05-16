#!/bin/bash

# Quick Deployment Script for Vercel Fix
# This script commits and pushes the fixes to GitHub
# Vercel will automatically redeploy

set -e

echo "=========================================="
echo "=== Vercel Fix Deployment Script ==="
echo "=========================================="
echo ""

# Verify we're in the right directory
if [ ! -f "vercel.json" ] || [ ! -f "vercel-build.sh" ]; then
  echo "ERROR: Not in project root directory"
  exit 1
fi

# Check git status
echo "[1] Checking git status..."
git status --short

echo ""
echo "[2] Verifying build passes locally..."
npm run vercel-build > /dev/null 2>&1 && echo "✓ Build script verified" || {
  echo "✗ Build script failed"
  exit 1
}

echo ""
echo "[3] Ready to deploy with these changes:"
echo "  • vercel.json - Removed 'framework': 'flutter'"
echo "  • vercel-build.sh - Upgraded to v3.0"
echo "  • VERCEL_FIX_SUMMARY.md - Documentation"
echo "  • IMPLEMENTATION_STEPS.md - Implementation guide"
echo ""

read -p "Continue with deployment? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "[4] Committing changes..."
  git add vercel.json vercel-build.sh VERCEL_FIX_SUMMARY.md IMPLEMENTATION_STEPS.md 2>/dev/null || true

  git commit -m "Fix Vercel tar extraction error - remove Flutter framework setting

- Remove 'framework': 'flutter' from vercel.json (fixes SDK download attempt)
- Upgrade vercel-build.sh to v3.0 with improved error handling
- Pre-built Flutter Web assets confirmed (23M, 31 files)
- Serverless API function ready (4.8KB)

This resolves the 'tar: Child returned status 1' error that occurred when Vercel
attempted to download and extract the Flutter SDK. The solution uses pre-built
assets that are already committed to git, eliminating the need for SDK download."

  echo "[5] Pushing to GitHub..."
  git push origin HEAD

  echo ""
  echo "=========================================="
  echo "=== Deployment in Progress ==="
  echo "=========================================="
  echo ""
  echo "Vercel will automatically:"
  echo "  1. Detect the push"
  echo "  2. Run npm run vercel-build"
  echo "  3. Deploy pre-built assets"
  echo "  4. Deploy Serverless Functions"
  echo ""
  echo "Expected duration: 10-15 seconds"
  echo "Check progress: https://vercel.com/dashboard"
  echo ""
else
  echo "Deployment cancelled"
  exit 0
fi
