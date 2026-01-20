#!/bin/bash

# Speak Better App Distribution Script
# Usage: ./distribute.sh [android|ios] [release-notes]

set -e

PLATFORM=${1:-android}
RELEASE_NOTES=${2:-"New version - $(date +%Y-%m-%d)"}

echo "🚀 Starting distribution process..."
echo "Platform: $PLATFORM"
echo "Release notes: $RELEASE_NOTES"
echo ""

cd app

# Build the app
echo "📦 Building app..."
if [ "$PLATFORM" = "android" ]; then
  flutter build apk --release
  APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
  
  if [ ! -f "$APK_PATH" ]; then
    echo "❌ Error: APK not found at $APK_PATH"
    exit 1
  fi
  
  echo "✅ APK built successfully: $APK_PATH"
  echo ""
  echo "📤 Distributing to Firebase App Distribution..."
  
  firebase appdistribution:distribute "$APK_PATH" \
    --app 1:507629276132:android:28ddeb233757aa6c0655f1 \
    --groups "testers" \
    --release-notes "$RELEASE_NOTES"
    
elif [ "$PLATFORM" = "ios" ]; then
  flutter build ipa --release
  IPA_PATH="build/ios/ipa/speakbetter_app.ipa"
  
  if [ ! -f "$IPA_PATH" ]; then
    echo "❌ Error: IPA not found at $IPA_PATH"
    exit 1
  fi
  
  echo "✅ IPA built successfully: $IPA_PATH"
  echo ""
  echo "📤 Distributing to Firebase App Distribution..."
  
  firebase appdistribution:distribute "$IPA_PATH" \
    --app 1:507629276132:ios:e950e0e8bb1acfb60655f1 \
    --groups "testers" \
    --release-notes "$RELEASE_NOTES"
else
  echo "❌ Error: Platform must be 'android' or 'ios'"
  echo "Usage: ./distribute.sh [android|ios] [release-notes]"
  exit 1
fi

echo ""
echo "✅ Distribution complete! Testers will receive email notifications."
echo ""
echo "📝 Next steps:"
echo "1. Check Firebase Console → App Distribution for status"
echo "2. Testers will receive email with download link"
echo "3. Monitor crash reports and feedback"
