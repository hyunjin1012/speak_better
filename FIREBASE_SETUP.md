# Firebase Authentication Setup Guide

## Overview
This guide will help you set up Firebase Authentication for your Speak Better app.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard:
   - Enter project name: `speak-better` (or your preferred name)
   - Enable Google Analytics (optional)
   - Click "Create project"

## Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication** → **Get started**
2. Click **Sign-in method** tab
3. Enable these providers:
   - **Email/Password**: Click → Enable → Save
   - **Google** (optional): Click → Enable → Save
   - **Apple** (optional, iOS only): Click → Enable → Save

## Step 3: Configure Flutter App

### Install FlutterFire CLI (if not already installed)
```bash
dart pub global activate flutterfire_cli
```

### Configure Firebase for Flutter
```bash
cd app
flutterfire configure
```

This will:
- Detect your Firebase projects
- Let you select the project you created
- Generate `lib/firebase_options.dart` automatically
- Configure iOS and Android apps

**Note:** You'll need to register your iOS and Android apps in Firebase Console first if prompted.

### Register iOS App (if needed)
1. Firebase Console → Project Settings → Your apps
2. Click iOS icon → Register app
3. Enter bundle ID (found in `app/ios/Runner.xcodeproj` or `app/pubspec.yaml`)
4. Download `GoogleService-Info.plist`
5. Place it in `app/ios/Runner/`

### Register Android App (if needed)
1. Firebase Console → Project Settings → Your apps
2. Click Android icon → Register app
3. Enter package name: `com.example.speakbetter_app` (check `app/android/app/build.gradle`)
4. Download `google-services.json`
5. Place it in `app/android/app/`

## Step 4: Get Firebase Service Account (for Backend)

1. Firebase Console → Project Settings → Service accounts
2. Click **Generate new private key**
3. Download the JSON file (keep it secure!)
4. Copy the entire JSON content

## Step 5: Configure Render Backend

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Select your `speakbetter-api` service
3. Go to **Environment** tab
4. Add new environment variable:
   - **Key:** `FIREBASE_SERVICE_ACCOUNT_JSON`
   - **Value:** Paste the entire JSON content from Step 4
   - **Mark as Secret:** ✅ Yes
5. Click **Save Changes**
6. Render will automatically redeploy

## Step 6: Install Flutter Dependencies

```bash
cd app
flutter pub get
```

## Step 7: Test the Setup

1. **Run the Flutter app:**
   ```bash
   flutter run
   ```

2. **You should see:**
   - Login screen on first launch
   - Ability to create account or sign in
   - After login, access to main app

3. **Test API calls:**
   - Try recording something
   - API calls should include auth token automatically
   - Backend should verify token and process request

## Troubleshooting

### "Firebase initialization error"
- Make sure you ran `flutterfire configure`
- Check that `firebase_options.dart` exists in `app/lib/`
- Verify Firebase project is correctly linked

### "FIREBASE_SERVICE_ACCOUNT_JSON environment variable is not set"
- Backend error: Make sure you added the env var in Render
- Check that the JSON is valid (no extra quotes, proper formatting)
- Restart the Render service after adding env var

### "Unauthorized" errors from API
- Check that user is signed in (should see login screen if not)
- Verify token is being sent (check Flutter logs)
- Check Render logs for token verification errors

### Login screen doesn't appear
- Check Firebase initialization in `main.dart`
- Verify `firebase_options.dart` is imported correctly
- Check Flutter console for errors

## Security Notes

⚠️ **Important:**
- Never commit `firebase_options.dart` if it contains sensitive data (it usually doesn't)
- Never commit service account JSON
- Keep service account JSON secure
- Use environment variables for all secrets

## Next Steps

After setup is complete:
- ✅ Users can sign up/sign in
- ✅ API calls are authenticated
- ✅ Backend verifies tokens
- 🔄 Consider adding:
  - Rate limiting per user
  - Firebase App Check (prevent API abuse)
  - User profiles
  - Password reset functionality

