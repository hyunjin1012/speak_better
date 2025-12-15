# Render Deployment - Fixed Configuration

## Option 1: Manual Configuration (Recommended if YAML gives errors)

If Render is showing an error with the YAML file, configure manually:

1. **Go to Render Dashboard** → "New +" → "Web Service"
2. **Connect GitHub** and select `speak_better` repository
3. **Configure these settings:**

   - **Name:** `speakbetter-api`
   - **Root Directory:** `api` ⚠️ **CRITICAL**
   - **Environment:** `Node`
   - **Build Command:** `npm ci && npm run build`
   - **Start Command:** `npm start`
   - **Plan:** `Free`

4. **Add Environment Variables:**
   - `OPENAI_API_KEY` = [your key from api/.env]
   - `NODE_ENV` = `production`
   - (PORT is set automatically by Render)

5. **Click "Create Web Service"**

## Option 2: Use render.yaml (After Pulling Latest)

If you want to use the YAML file:

1. Make sure you've pulled the latest code (the YAML is now fixed)
2. In Render dashboard, when creating the service, Render should auto-detect `render.yaml`
3. It will use the configuration from the YAML file
4. You'll still need to add `OPENAI_API_KEY` manually in the dashboard

## Common Errors and Fixes

**Error: "Invalid YAML"**
- Use Option 1 (manual configuration) instead

**Error: "Build failed"**
- Check that Root Directory is set to `api`
- Check build logs for specific npm errors

**Error: "Cannot find module"**
- Make sure `npm ci` runs successfully (checks package-lock.json)
- Verify all dependencies are in package.json

**Error: "Port already in use"**
- Render sets PORT automatically, don't override it

## After Deployment

Test with:
```bash
curl https://your-service.onrender.com/health
```

Should return: `{"ok":true}`

