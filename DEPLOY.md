# Deploy to Render - Step by Step Guide

## Prerequisites
- GitHub account
- Render account (free at https://render.com)

## Step 1: Push to GitHub

1. **Create a GitHub repository:**
   - Go to https://github.com/new
   - Name it `speakbetter` (or any name you prefer)
   - Don't initialize with README (we already have files)
   - Click "Create repository"

2. **Push your code:**
   ```bash
   cd /Users/hyunjin/Codes/speakbetter
   git add .
   git commit -m "Initial commit - Speak Better app"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/speakbetter.git
   git push -u origin main
   ```
   Replace `YOUR_USERNAME` with your GitHub username.

## Step 2: Deploy on Render

1. **Go to Render Dashboard:**
   - Visit https://dashboard.render.com
   - Sign up/login (can use GitHub to sign in)

2. **Create New Web Service:**
   - Click "New +" → "Web Service"
   - Connect your GitHub account if not already connected
   - Select your `speakbetter` repository

3. **Configure the Service:**
   - **Name:** `speakbetter-api`
   - **Root Directory:** `api` ⚠️ **IMPORTANT:** Set this to `api` since your API code is in a subdirectory
   - **Environment:** `Node`
   - **Build Command:** `npm ci && npm run build`
   - **Start Command:** `npm start`
   - **Plan:** Free (for testing) or Starter ($7/month)

4. **Add Environment Variables:**
   Click "Advanced" → "Add Environment Variable":
   - **Key:** `OPENAI_API_KEY`
   - **Value:** Your OpenAI API key (the one from your `.env` file)
   - **Mark as Secret:** ✅ Yes
   - Click "Add"

   Optional:
   - **Key:** `NODE_ENV`
   - **Value:** `production`

5. **Deploy:**
   - Click "Create Web Service"
   - Wait 2-3 minutes for build and deployment
   - You'll see build logs in real-time

6. **Get Your URL:**
   - Once deployed, you'll see a URL like: `https://speakbetter-api.onrender.com`
   - Copy this URL

## Step 3: Update Flutter App

Update your Flutter app to use the deployed API:

**Option A: Update config.dart (for permanent change)**
```dart
// In app/lib/config.dart
static const apiBaseUrl = 'https://your-render-url.onrender.com';
```

**Option B: Use command line (for testing)**
```bash
cd app
flutter run --dart-define=API_BASE_URL=https://your-render-url.onrender.com
```

## Step 4: Test

1. **Test the API:**
   ```bash
   curl https://your-render-url.onrender.com/health
   ```
   Should return: `{"ok":true}`

2. **Test in your app:**
   - Run the Flutter app
   - Try recording and see if it works!

## Troubleshooting

- **Build fails:** Check build logs in Render dashboard
- **API not responding:** Check if service is running (free tier spins down after inactivity)
- **CORS errors:** Already handled in your code
- **File upload issues:** Check Render logs for errors

## Next Steps

- Add rate limiting before public launch
- Consider adding API key authentication
- Monitor usage in Render dashboard
- Upgrade to paid plan if you need always-on service (free tier spins down)

