# Vercel Deployment - Troubleshooting Guide

## Quick Reference

| Issue | Cause | Fix |
|-------|-------|-----|
| tar: Child returned status 1 | `"framework": "flutter"` in vercel.json | ✓ Fixed - remove that line |
| Build fails (pre-built assets missing) | Assets not in git | Run: `git add epl_match_simulator/build/web/` |
| API returns 500 error | CLAUDE_API_KEY not set | Set in Vercel Dashboard → Environment Variables |
| Static files return 404 | SPA routing misconfigured | Check vercel.json rewrites |

---

## Problem: Build Still Fails

### Symptom
```
npm run vercel-build fails even after fix
```

### Diagnosis
1. **Verify local build passes**:
   ```bash
   npm run vercel-build
   # Should output "Build Completed Successfully"
   ```

2. **Check git status**:
   ```bash
   git status
   # Should show vercel.json and vercel-build.sh modified
   ```

3. **Verify pre-built assets exist**:
   ```bash
   test -d epl_match_simulator/build/web && echo "OK" || echo "MISSING"
   # Should output: OK
   ```

### Solution

#### If local build passes but Vercel fails:
1. In Vercel Dashboard, click "Redeploy"
2. Check build logs (should show v3.0 of the script)
3. If still failing, check for environment issues:
   ```bash
   git log --oneline | head -3
   # Verify latest commits are visible
   ```

#### If local build fails:
```bash
# Check each component
test -d epl_match_simulator && echo "✓ Flutter dir" || echo "✗ Flutter dir"
test -d api && echo "✓ API dir" || echo "✗ API dir"
test -f api/predictMatch.js && echo "✓ API file" || echo "✗ API file"
test -d epl_match_simulator/build/web && echo "✓ Assets" || echo "✗ Assets"

# Run the script with verbose output
bash -x vercel-build.sh
```

---

## Problem: API Endpoint Returns 500 Error

### Symptom
```
curl https://your-app.vercel.app/api/predictMatch
# Returns: 500 Internal Server Error
```

### Diagnosis
1. **Check if API key is set**:
   - Go to Vercel Dashboard
   - Project Settings → Environment Variables
   - Look for `CLAUDE_API_KEY`

2. **Test the key locally**:
   ```bash
   export CLAUDE_API_KEY="your-actual-key"
   node api/predictMatch.js
   ```

3. **Check function logs in Vercel**:
   - Vercel Dashboard → Functions
   - Click `api/predictMatch.js`
   - Check logs for errors

### Solution

#### Missing API Key:
1. Get your Anthropic API key from https://console.anthropic.com/
2. In Vercel Dashboard:
   - Go to Project Settings → Environment Variables
   - Add: `CLAUDE_API_KEY` = (your key)
   - Click "Save"
3. Redeploy: Click "Redeploy" button

#### Invalid API Key:
1. Get a new key from https://console.anthropic.com/
2. Update in Vercel Dashboard
3. Redeploy

#### Function code error:
Check the file exists and is valid:
```bash
cat api/predictMatch.js | head -20
# Should show valid JavaScript with exports
```

---

## Problem: Static Files Return 404

### Symptom
```
https://your-app.vercel.app/  # Works
https://your-app.vercel.app/index.html  # 404
https://your-app.vercel.app/main.dart.js  # 404
```

### Root Cause
SPA routing not configured in vercel.json

### Solution

Verify vercel.json has correct rewrites:
```bash
cat vercel.json | jq '.rewrites'
```

Should show:
```json
[
  {
    "source": "/api/:path*",
    "destination": "/api/:path*"
  },
  {
    "source": "/(.*)",
    "destination": "/index.html"
  }
]
```

If missing, update vercel.json and redeploy.

---

## Problem: Frontend Loads but App Doesn't Work

### Symptom
```
Page loads (blank or loading screen)
Browser console shows errors
App doesn't render
```

### Diagnosis
1. **Check Network tab in DevTools**:
   - Verify main.dart.js loads (200 status)
   - Verify flutter.js loads (200 status)
   - Look for failed requests

2. **Check Console tab**:
   - Look for JavaScript errors
   - Common: CORS issues, missing assets

### Solutions

#### CORS Error:
Verify api/predictMatch.js has CORS headers:
```bash
grep -A 3 "Access-Control-Allow-Origin" api/predictMatch.js
# Should show: res.setHeader("Access-Control-Allow-Origin", "*");
```

If missing, add to api/predictMatch.js:
```javascript
res.setHeader("Access-Control-Allow-Origin", "*");
res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
res.setHeader("Access-Control-Allow-Headers", "Content-Type");
```

#### Missing Assets:
Check assets folder:
```bash
ls epl_match_simulator/build/web/assets/ | head -10
# Should show: fonts, images, etc.
```

If empty, rebuild locally:
```bash
cd epl_match_simulator
flutter clean
flutter pub get
flutter build web --release
cd ..
git add epl_match_simulator/build/web/
git commit -m "Rebuild assets"
git push
```

---

## Problem: Build Takes Too Long (>1 minute)

### Expected Duration
Normal build should complete in 10-15 seconds.

### If Build Takes >1 minute:
1. **Check Vercel logs** - Look for what's taking time
2. **Verify file sizes**:
   ```bash
   du -sh epl_match_simulator/build/web/
   # Should be ~23MB (reasonable)
   ```

3. **If assets are huge (>100MB)**:
   - Rebuild locally: `flutter build web --release`
   - Large builds might be slow on Vercel network

### Solutions
1. Optimize assets locally (e.g., compress images)
2. Clear Vercel cache: Dashboard → Settings → Advanced → Clear Cache
3. Redeploy

---

## Problem: Git Push Doesn't Trigger Deployment

### Symptom
```
git push succeeds
But Vercel doesn't redeploy
```

### Diagnosis
1. **Check Vercel git integration**:
   - Dashboard → Settings → Git Integration
   - Verify GitHub/GitLab connection is active

2. **Check branch settings**:
   - Production Deployment Branch should be your push target
   - Typically: `main` or `master`

### Solution
```bash
# Verify branch name
git branch
# Should show current branch (e.g., * main)

# Verify push target
git remote -v
# Should show GitHub URL

# Force redeploy
# Go to Vercel Dashboard → Click "Redeploy" button
```

---

## Vercel Dashboard Health Checks

### Build Status
✓ Latest deployment shows "Ready"
✓ No red X marks or errors

### Function Status
✓ Functions section shows `api/predictMatch.js`
✓ No warnings or errors in function logs

### Environment Variables
✓ `CLAUDE_API_KEY` is set
✓ (Verify in Project Settings → Environment Variables)

### Deployment Logs
```bash
# View real-time logs
vercel logs --follow

# Or check in Dashboard: Deployments tab
```

---

## Recovery Procedures

### If Deployment Breaks

#### Quick Rollback:
```bash
git revert HEAD
git push
```
Vercel will automatically redeploy with previous version.

#### Hard Rollback (Delete recent commits):
```bash
# CAUTION: Use only if necessary
git log --oneline | head -5
git reset --hard HEAD~1  # Undo last commit
git push --force-with-lease
```

#### Manual Rollback in Vercel:
1. Dashboard → Deployments tab
2. Find previous working deployment
3. Click three dots → "Promote to Production"

---

## Getting Help

If none of these solutions work:

1. **Collect information**:
   ```bash
   npm run vercel-build > build.log 2>&1
   git log --oneline | head -10 > git.log
   cat vercel.json > config.log
   cat .gitignore > ignore.log
   ```

2. **Check Vercel Documentation**: https://vercel.com/docs

3. **Review error messages carefully**:
   - Look for specific file paths or line numbers
   - Error messages usually point to the root cause

4. **Test locally first**:
   - `npm run vercel-build` should always pass locally before pushing

---

## Verification Checklist

Before asking for help, verify:

- [ ] `npm run vercel-build` passes locally
- [ ] `git log` shows your commits pushed
- [ ] `git ls-files | grep build/web` shows files committed
- [ ] `vercel.json` does NOT have `"framework": "flutter"`
- [ ] `CLAUDE_API_KEY` is set in Vercel Dashboard
- [ ] Latest deployment in Vercel shows status: "Ready"
- [ ] `https://your-app.vercel.app/` loads without errors
- [ ] Browser console shows no major errors

If all boxes are checked, deployment should be working.

---

**Last Updated**: May 16, 2026  
**Version**: 1.0  
**Solution Type**: Configuration Fix
