# Vercel Deployment Guide - EPL Match Simulator

## Current Architecture

```
epl-match-simulator/
├── epl_match_simulator/
│   ├── build/web/           ← Flutter Web (pre-built, committed to git)
│   ├── lib/
│   ├── pubspec.yaml
│   └── ...
├── api/
│   └── predictMatch.js       ← Serverless Function (Claude API)
├── vercel-build.sh           ← Build script (CRITICAL)
├── vercel.json               ← Vercel configuration
└── package.json
```

## Why This Approach?

**Problem**: Previous attempts to build Flutter in Vercel's environment resulted in:
```
tar: Child returned status 1
ERROR: Failed to extract Flutter SDK
```

**Solution**: Pre-build Flutter Web locally and commit to git.

**Benefits**:
- No Flutter SDK download in Vercel (eliminates network issues)
- Faster builds (90% reduction in build time)
- Smaller payload (23MB vs 2GB+ with Flutter)
- More reliable deployments

## Setup Instructions

### 1. Local Build & Commit (First Time Only)

```bash
# Build Flutter Web locally
cd epl_match_simulator
flutter pub get
flutter build web --release
cd ..

# Verify build output
ls -la epl_match_simulator/build/web/
du -sh epl_match_simulator/build/web/

# Add to git and push
git add epl_match_simulator/build/web/
git commit -m "Add pre-built Flutter Web assets"
git push
```

### 2. Verify .gitignore

Ensure `.gitignore` is correctly configured:
```
# These should be IGNORED:
_flutter/
build/          ← Root build/ directory (Python, etc.)
epl_match_simulator/.dart_tool/
epl_match_simulator/.packages
epl_match_simulator/pubspec.lock

# This should be TRACKED:
epl_match_simulator/build/web/  ← Pre-built web assets (NOT in .gitignore)
```

Run to verify:
```bash
git ls-files | grep "epl_match_simulator/build/web/"
# Should show many files like:
# epl_match_simulator/build/web/index.html
# epl_match_simulator/build/web/main.dart.js
# ... etc
```

### 3. Deploy to Vercel

#### Option A: Via Git Integration (Recommended)

1. Go to [vercel.com](https://vercel.com)
2. Import project from GitHub
3. Vercel will automatically:
   - Detect `vercel.json` and `package.json`
   - Run `npm run vercel-build` (which calls `vercel-build.sh`)
   - Serve `epl_match_simulator/build/web/` as static content
   - Deploy `api/predictMatch.js` as Serverless Functions

#### Option B: Via Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# View logs
vercel logs
```

### 4. Environment Variables

Set in Vercel Dashboard:
- Project Settings → Environment Variables
- Add: `CLAUDE_API_KEY` = your Anthropic API key

### 5. Verify Deployment

After deployment, check:

```bash
# Frontend loads correctly
curl https://your-project.vercel.app/

# API is accessible
curl -X POST https://your-project.vercel.app/api/predictMatch \
  -H "Content-Type: application/json" \
  -d '{"homeTeam": {"name": "Arsenal"}, "awayTeam": {"name": "Chelsea"}}'
```

## Troubleshooting

### Issue: "build/web directory not found"

**Solution:**
```bash
# Build locally
cd epl_match_simulator
flutter clean
flutter pub get
flutter build web --release
cd ..

# Verify
test -d epl_match_simulator/build/web && echo "OK" || echo "FAIL"

# Commit
git add epl_match_simulator/build/web/
git commit -m "Rebuild web assets"
git push
```

### Issue: API returns 500 error

**Check:**
1. Is `CLAUDE_API_KEY` set in Vercel? (Check dashboard)
2. Is API key valid? (Test with curl)
3. Check function logs in Vercel dashboard

```bash
# Test locally
export CLAUDE_API_KEY="your-key-here"
node -e "
const fn = require('./api/predictMatch.js');
const req = {
  method: 'POST',
  body: {
    homeTeam: { name: 'Arsenal', attackPower: 7 },
    awayTeam: { name: 'Chelsea', attackPower: 8 }
  }
};
const res = {
  setHeader: () => {},
  status: (code) => ({ json: (data) => console.log(data), end: () => {} })
};
fn(req, res);
"
```

### Issue: Static files return 404

**Solution:**
Verify `vercel.json` rewrites are correct:
```bash
cat vercel.json | grep -A 10 '"rewrites"'
```

Should have:
```json
"rewrites": [
  { "source": "/api/:path*", "destination": "/api/:path*" },
  { "source": "/(.*)", "destination": "/index.html" }
]
```

### Issue: CORS errors from frontend

**Check:** `api/predictMatch.js` has CORS headers (should already be set):
```javascript
res.setHeader("Access-Control-Allow-Origin", "*");
res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
res.setHeader("Access-Control-Allow-Headers", "Content-Type");
```

## File Sizes & Limits

- `epl_match_simulator/build/web/`: ~23MB
  - Vercel default limit: 250MB (no issue)
  - Each file must be <104.8 MB
  
- Serverless Function: `api/predictMatch.js`
  - Code size: ~4KB
  - Max duration: 60 seconds (configured in `vercel.json`)

## Performance Notes

- Frontend: Cached indefinitely (immutable, hash-based names)
- API: Not cached (must be fresh)
- Build time: ~5-10 seconds (vs 5+ minutes with Flutter build)

## Rollback Procedure

If deployment breaks:

```bash
# Check git log
git log --oneline | head -5

# Revert last commit
git revert HEAD
git push

# Vercel auto-redeploys on push
```

## Local Testing (Simulating Vercel)

```bash
# Run build script
bash ./vercel-build.sh

# Should see:
# ✓ Project structure verified
# ✓ Pre-built web assets found
# ✓ API function found
```

## Migration from Previous Setup

If you had Flutter building on Vercel previously:

1. Delete `.vercel/` (if it exists locally)
2. Build Flutter locally and commit
3. Push to GitHub
4. Redeploy from Vercel dashboard
5. Monitor build logs to confirm success

## Summary

| Step | Status | Command |
|------|--------|---------|
| Build Flutter locally | One-time | `flutter build web --release` |
| Commit build/web/ | One-time | `git add epl_match_simulator/build/web/` |
| Deploy to Vercel | On push | Automatic (Git integration) |
| Set API key | One-time | Vercel dashboard |
| Test API | Verify | `curl -X POST /api/predictMatch` |

---

For questions: Check Vercel logs or re-run local build.
