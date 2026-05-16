# Vercel Deployment Checklist

## Before First Deployment

- [ ] Flutter Web is built locally:
  ```bash
  ls epl_match_simulator/build/web/index.html
  ```

- [ ] Pre-built assets are committed to Git:
  ```bash
  git ls-files | grep "epl_match_simulator/build/web/" | wc -l
  # Should show many files (>20)
  ```

- [ ] Build script works locally:
  ```bash
  bash test-build.sh
  # Should output: ✓ BUILD PASSED
  ```

- [ ] `.gitignore` is correct:
  ```bash
  cat .gitignore | grep -A 2 "epl_match_simulator/build"
  # Should show: epl_match_simulator/build/web/ NOT in ignore list
  ```

- [ ] API key is set in Vercel dashboard:
  - Project Settings → Environment Variables
  - Add: `CLAUDE_API_KEY`

## Deployment Steps

### Step 1: Final Local Build (First Time Only)

```bash
cd epl_match_simulator
flutter clean
flutter pub get
flutter build web --release
cd ..
```

### Step 2: Commit and Push

```bash
git add -A
git commit -m "Prepare for Vercel deployment with pre-built assets"
git push
```

### Step 3: Deploy to Vercel

#### Via Vercel Dashboard

1. Go to https://vercel.com
2. Click "Add New..." → "Project"
3. Select your GitHub repository
4. Configure:
   - **Framework**: Flutter (or leave blank)
   - **Build Command**: `npm run vercel-build` (auto-detected)
   - **Output Directory**: `epl_match_simulator/build/web` (auto-detected)
5. Add Environment Variables:
   - `CLAUDE_API_KEY` = your API key
6. Click "Deploy"

#### Via Vercel CLI

```bash
npm install -g vercel
vercel
# Follow prompts and set environment variables
```

### Step 4: Monitor Deployment

```bash
vercel logs
# Or check at: https://vercel.com/dashboard
```

Expected output:
```
✓ Project structure verified
✓ Pre-built web assets found
✓ API function found
✓ Build Complete
```

## Post-Deployment Testing

### Test 1: Frontend Loads

```bash
curl https://your-project.vercel.app/ | grep -o "index.html\|main.dart.js"
# Should return both
```

### Test 2: API Works

```bash
curl -X POST https://your-project.vercel.app/api/predictMatch \
  -H "Content-Type: application/json" \
  -d '{
    "homeTeam": {"name": "Arsenal", "attackPower": 7, "defensePower": 8, "ballControl": 7, "formation": "4-3-3", "players": []},
    "awayTeam": {"name": "Chelsea", "attackPower": 8, "defensePower": 7, "ballControl": 8, "formation": "4-2-3-1", "players": []}
  }' \
  | jq '.success'
# Should return: true
```

### Test 3: SPA Routes Work

```bash
curl https://your-project.vercel.app/match/1 | grep -o "<!DOCTYPE html>"
# Should return the HTML (not 404)
```

## If Deployment Fails

### Error: "build/web directory not found"

**Root Cause**: Pre-built assets not in Git

**Fix**:
```bash
cd epl_match_simulator
flutter build web --release
cd ..
git add epl_match_simulator/build/web/
git commit -m "Add pre-built web assets"
git push
# Vercel will auto-redeploy
```

### Error: "tar: Child returned status 1"

**Root Cause**: Script tried to download Flutter (old setup)

**Fix**: This is FIXED in the new `vercel-build.sh`. Just push:
```bash
git push
# New deployment will NOT attempt Flutter download
```

### Error: "API returns 500"

**Root Cause**: `CLAUDE_API_KEY` not set

**Fix**:
1. Go to Vercel Dashboard
2. Project → Settings → Environment Variables
3. Add: `CLAUDE_API_KEY=sk-ant-...`
4. Redeploy

### Error: "CORS error from frontend"

**Root Cause**: API headers not set (shouldn't happen)

**Fix**: Verify `api/predictMatch.js` has:
```javascript
res.setHeader("Access-Control-Allow-Origin", "*");
```

If missing, add and push:
```bash
git push
# Vercel auto-redeploys
```

## Rollback

If deployment breaks everything:

```bash
# Check last working commit
git log --oneline | head -3

# Revert
git revert HEAD
git push

# Vercel auto-redeploys (should be fixed)
```

## Performance Targets

| Metric | Target | Check |
|--------|--------|-------|
| Build Time | < 30s | Vercel dashboard |
| Frontend Load | < 3s | Speed Test |
| API Response | < 2s | curl timing |
| Uptime | 99%+ | Monitor |

## Files Modified for This Fix

- `vercel-build.sh` - Primary build script (simplified, robust)
- `vercel.json` - Vercel configuration (improved routing)
- `package.json` - npm scripts (added commands)
- `VERCEL_DEPLOYMENT.md` - Detailed guide
- `DEPLOYMENT_CHECKLIST.md` - This file

## Next Steps After Successful Deployment

1. Update your project README with deployment URL
2. Set up GitHub Actions for CI/CD (optional)
3. Monitor Vercel analytics for performance
4. Plan Flutter updates (rebuild locally, test, push)

---

**TL;DR**: Build locally, commit, push, Vercel auto-deploys. Done.
