# Render Deployment Troubleshooting

## Current Configuration (Should Work)

Based on your form:
- ✅ Root Directory: `api`
- ✅ Build Command: `npm ci && npm run build`
- ✅ Start Command: `npm start`
- ✅ Language: `Node`

## Common Errors & Fixes

### Error: "Invalid YAML" or "Configuration Error"
**Fixed:** I've disabled `render.yaml` - try deploying again now.

### Error: "Build failed" or "npm ci failed"
**Possible causes:**
1. Missing `package-lock.json` - ✅ Already exists
2. Node version mismatch - Render uses Node 18+ by default
3. Build script fails - Check TypeScript compilation

**Fix:** Add Node version specification:
- In Render dashboard, add environment variable:
  - Key: `NODE_VERSION`
  - Value: `20`

### Error: "Cannot find module" or "Module not found"
**Fix:** Make sure `npm ci` installs all dependencies before build.

### Error: "Start command failed"
**Possible causes:**
1. `dist/index.js` doesn't exist (build failed)
2. Missing environment variables

**Fix:** Check build logs first, then verify:
- `OPENAI_API_KEY` is set
- `NODE_ENV` is set to `production`

## Step-by-Step Deployment

1. **Pull latest code** (render.yaml is now disabled):
   ```bash
   git pull
   ```

2. **In Render Dashboard:**
   - Click "New +" → "Web Service"
   - Connect GitHub → Select `speak_better`
   - **Name:** `speakbetter-api`
   - **Root Directory:** `api`
   - **Build Command:** `npm ci && npm run build`
   - **Start Command:** `npm start`
   - **Plan:** Free

3. **Add Environment Variables:**
   - `OPENAI_API_KEY` = [your key]
   - `NODE_ENV` = `production`
   - `NODE_VERSION` = `20` (optional, but recommended)

4. **Click "Create Web Service"**

5. **Watch the build logs** - they'll show exactly what's failing

## If Still Failing

Please share:
1. The exact error message from Render
2. The build log output (especially the error lines)
3. Any validation errors shown in the form

This will help me identify the specific issue.

