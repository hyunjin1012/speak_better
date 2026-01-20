# 📱 App Distribution Guide for Testers

This guide covers multiple ways to distribute your app to testers.

## 🎯 Recommended: Firebase App Distribution (Easiest)

Firebase App Distribution is the easiest option since you already have Firebase set up. It works for both iOS and Android.

### Prerequisites

1. **Install Firebase CLI** (if not already installed):
```bash
npm install -g firebase-tools
firebase login
```

2. **Install FlutterFire CLI**:
```bash
dart pub global activate flutterfire_cli
```

### Step 1: Enable Firebase App Distribution

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **speak-better-c9023**
3. Click **App Distribution** in the left menu
4. Click **Get started** (if first time)
5. Follow the setup wizard

### Step 2: Build Your App

#### For Android (APK):
```bash
cd app
flutter build apk --release
```

#### For iOS (IPA):
```bash
cd app
flutter build ipa --release
```

**Note for iOS**: You need:
- Apple Developer account ($99/year)
- Valid provisioning profiles
- Code signing certificates

### Step 3: Distribute via Firebase CLI

#### Android:
```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:507629276132:android:28ddeb233757aa6c0655f1 \
  --groups "testers" \
  --release-notes "Version 1.0.0 - Initial release"
```

#### iOS:
```bash
firebase appdistribution:distribute build/ios/ipa/speakbetter_app.ipa \
  --app 1:507629276132:ios:e950e0e8bb1acfb60655f1 \
  --groups "testers" \
  --release-notes "Version 1.0.0 - Initial release"
```

### Step 4: Add Testers

1. Go to Firebase Console → **App Distribution**
2. Click **Testers & Groups** tab
3. Click **Add testers**
4. Enter tester emails (one per line)
5. Click **Add**

Testers will receive an email with download link.

---

## 🍎 iOS: TestFlight (Official Apple Beta Testing)

### Prerequisites
- Apple Developer account ($99/year)
- Xcode installed
- Valid provisioning profiles

### Step 1: Build for TestFlight

```bash
cd app
flutter build ipa --release
```

### Step 2: Upload to App Store Connect

1. Open **Xcode**
2. Go to **Window** → **Organizer**
3. Select your app archive
4. Click **Distribute App**
5. Choose **App Store Connect**
6. Follow the wizard to upload

### Step 3: Configure TestFlight

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Go to **TestFlight** tab
4. Wait for processing (can take 10-30 minutes)
5. Click **Internal Testing** or **External Testing**
6. Add testers:
   - **Internal**: Up to 100 testers (team members)
   - **External**: Up to 10,000 testers (requires App Review)

### Step 4: Invite Testers

1. Click **Add Testers**
2. Enter email addresses
3. Testers receive email invitation
4. They install **TestFlight** app from App Store
5. They can download your app from TestFlight

---

## 🤖 Android: Google Play Internal Testing

### Prerequisites
- Google Play Developer account ($25 one-time fee)
- Google Play Console access

### Step 1: Build App Bundle (Recommended)

```bash
cd app
flutter build appbundle --release
```

This creates: `build/app/outputs/bundle/release/app-release.aab`

### Step 2: Create App in Play Console

1. Go to [Google Play Console](https://play.google.com/console/)
2. Click **Create app**
3. Fill in:
   - App name: **Speak Better**
   - Default language: English
   - App or game: App
   - Free or paid: Free
4. Accept terms and create

### Step 3: Upload to Internal Testing

1. In Play Console, go to **Testing** → **Internal testing**
2. Click **Create new release**
3. Upload your `.aab` file
4. Add release notes
5. Click **Save**
6. Click **Review release**
7. Click **Start rollout to Internal testing**

### Step 4: Add Testers

1. Go to **Testers** tab
2. Click **Create email list**
3. Add tester emails
4. Copy the **opt-in URL**
5. Share URL with testers

Testers click the link, opt-in, then can download from Play Store.

---

## 📦 Direct Distribution (Simple but Less Secure)

### Android APK Distribution

1. Build APK:
```bash
cd app
flutter build apk --release
```

2. APK location: `build/app/outputs/flutter-apk/app-release.apk`

3. Share via:
   - Email attachment
   - Google Drive / Dropbox
   - Your own website

**⚠️ Warning**: Users need to enable "Install from unknown sources" on Android.

### iOS IPA Distribution (Requires Developer Account)

1. Build IPA:
```bash
cd app
flutter build ipa --release
```

2. IPA location: `build/ios/ipa/speakbetter_app.ipa`

3. **For Ad-Hoc Distribution**:
   - Register device UDIDs in Apple Developer Portal
   - Create Ad-Hoc provisioning profile
   - Build with Ad-Hoc profile
   - Distribute via TestFlight or direct download

---

## 🚀 Quick Start Script

Create a script to automate distribution:

### `distribute.sh` (for Firebase App Distribution)

```bash
#!/bin/bash

# Build the app
echo "Building app..."
cd app
flutter build apk --release

# Distribute to Firebase
echo "Distributing to Firebase..."
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app 1:507629276132:android:28ddeb233757aa6c0655f1 \
  --groups "testers" \
  --release-notes "$(git log -1 --pretty=%B)"

echo "Done! Testers will receive email notification."
```

Make it executable:
```bash
chmod +x distribute.sh
./distribute.sh
```

---

## 📝 Version Management

Update version before each release:

### `app/pubspec.yaml`:
```yaml
version: 1.0.1+2  # version name + build number
```

### Android (`app/android/app/build.gradle`):
```gradle
versionCode 2
versionName "1.0.1"
```

### iOS (`app/ios/Runner.xcodeproj/project.pbxproj`):
- Open in Xcode
- Select project → General tab
- Update **Version** and **Build** numbers

---

## 🔐 Security Notes

1. **Never commit**:
   - `google-services.json` (already in .gitignore)
   - `GoogleService-Info.plist` (already in .gitignore)
   - Service account keys
   - Signing certificates

2. **Use environment variables** for API keys in backend

3. **Limit tester access** - only invite trusted testers

---

## 📊 Recommended Workflow

1. **Development**: Test on simulators/devices
2. **Internal Testing**: Firebase App Distribution (quick feedback)
3. **Beta Testing**: TestFlight (iOS) / Play Internal Testing (Android)
4. **Production**: App Store / Play Store

---

## 🆘 Troubleshooting

### Android: "App not installed"
- Check if device allows unknown sources
- Ensure APK is not corrupted
- Check minimum SDK version

### iOS: "Unable to install"
- Check provisioning profile includes device UDID
- Verify code signing certificates
- Check TestFlight status in App Store Connect

### Firebase: "App not found"
- Verify app ID matches Firebase Console
- Check Firebase CLI is logged in: `firebase login`
- Ensure App Distribution is enabled in Firebase Console

---

## 📞 Next Steps

1. Choose your distribution method (recommend Firebase App Distribution)
2. Build your app
3. Add testers
4. Distribute and collect feedback!

For questions, check:
- [Firebase App Distribution Docs](https://firebase.google.com/docs/app-distribution)
- [TestFlight Guide](https://developer.apple.com/testflight/)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer/)
