# Quick Render Deployment Steps

Your code is now on GitHub! Follow these steps to deploy:

## 1. Go to Render Dashboard
- Visit: https://dashboard.render.com
- Sign up/login (use GitHub to sign in for easier setup)

## 2. Create New Web Service
1. Click **"New +"** → **"Web Service"**
2. Click **"Connect account"** if you haven't connected GitHub yet
3. Select your repository: **`hyunjin1012/speak_better`**

## 3. Configure Service
Fill in these settings:

- **Name:** `speakbetter-api`
- **Root Directory:** `api` ⚠️ **CRITICAL:** Must be `api` (not blank!)
- **Environment:** `Node`
- **Build Command:** `npm ci && npm run build`
- **Start Command:** `npm start`
- **Plan:** `Free` (for testing)

## 4. Add Environment Variable
Click **"Advanced"** → **"Add Environment Variable"**:

- **Key:** `OPENAI_API_KEY`
- **Value:** [Your API key from `api/.env` file]
- **Mark as Secret:** ✅ Yes (check this box!)

Click **"Add"**

## 5. Deploy
- Click **"Create Web Service"**
- Wait 2-3 minutes for build
- Watch the build logs - you'll see it installing dependencies and building

## 6. Get Your URL
Once deployed, you'll see a URL like:
`https://speakbetter-api.onrender.com`

Copy this URL!

## 7. Test the API
```bash
curl https://your-url.onrender.com/health
```

Should return: `{"ok":true}`

## 8. Update Flutter App
Run your app with:
```bash
cd app
flutter run --dart-define=API_BASE_URL=https://your-url.onrender.com
```

Or update `app/lib/config.dart` permanently.

---

**Note:** Free tier services spin down after 15 minutes of inactivity. First request after spin-down takes ~30 seconds to wake up.

