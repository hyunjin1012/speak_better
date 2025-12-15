# Deployment Guide

## Quick Start: Render (Recommended for MVP)

1. **Push your code to GitHub** (if not already)
   ```bash
   git add .
   git commit -m "Add deployment configs"
   git push
   ```

2. **Go to Render Dashboard**
   - Visit https://render.com
   - Sign up/login
   - Click "New +" → "Web Service"
   - Connect your GitHub repository

3. **Configure the service:**
   - **Name:** `speakbetter-api`
   - **Root Directory:** `api` (since your API is in a subdirectory)
   - **Environment:** `Node`
   - **Build Command:** `npm ci && npm run build`
   - **Start Command:** `npm start`
   - **Plan:** Free tier is fine for testing

4. **Add Environment Variables:**
   - `OPENAI_API_KEY` - Your OpenAI API key (mark as Secret)
   - `NODE_ENV` - Set to `production`
   - `PORT` - Render sets this automatically, but your code handles it

5. **Deploy**
   - Click "Create Web Service"
   - Wait for deployment (2-3 minutes)
   - Copy the service URL (e.g., `https://speakbetter-api.onrender.com`)

6. **Update Flutter App:**
   - Update `app/lib/config.dart` or use:
   ```bash
   flutter run --dart-define=API_BASE_URL=https://your-render-url.onrender.com
   ```

## Google Cloud Run (Recommended for Production)

### Prerequisites
- Google Cloud account
- `gcloud` CLI installed: https://cloud.google.com/sdk/docs/install

### Steps

1. **Enable Cloud Run API:**
   ```bash
   gcloud services enable run.googleapis.com
   ```

2. **Set your project:**
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Build and deploy:**
   ```bash
   cd api
   gcloud run deploy speakbetter-api \
     --source . \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated \
     --set-env-vars OPENAI_API_KEY=your_key_here
   ```

4. **Get your URL:**
   ```bash
   gcloud run services describe speakbetter-api --region us-central1 --format 'value(status.url)'
   ```

5. **Update Flutter App** with the Cloud Run URL

## Important Notes

- **File Uploads:** Both platforms handle file uploads fine. Temp files are cleaned up automatically.
- **CORS:** Already configured in your code. For production, consider restricting origins.
- **Rate Limiting:** Add this before public launch to prevent abuse.
- **API Key:** Never commit your `.env` file. Use platform environment variables.

## Testing Deployment

After deployment, test the health endpoint:
```bash
curl https://your-api-url.com/health
```

Should return: `{"ok":true}`

