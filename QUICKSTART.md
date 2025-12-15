# Quick Start Guide

## Prerequisites

- Node.js 18+ installed
- Flutter SDK 3.0+ installed
- OpenAI API key

## Step 1: Backend Setup

```bash
cd api
npm install
cp .env.example .env
# Edit .env and add your OPENAI_API_KEY
npm run dev
```

The API should now be running on `http://localhost:8080`

## Step 2: Flutter App Setup

In a new terminal:

```bash
cd app
flutter pub get
```

### For iOS Simulator:
```bash
flutter run
```

### For Android Emulator:
Update the API URL in `app/lib/config.dart` or run:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

### For Physical Device:
1. Find your computer's IP address (e.g., `192.168.1.100`)
2. Make sure your device is on the same network
3. Run:
```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8080
```

## Step 3: Test the App

1. Open the app
2. Select a language (Korean or English)
3. Select your learner mode
4. Choose a topic or create a new one
5. Record your speech
6. View the AI-powered feedback!

## Troubleshooting

### API Connection Issues
- Make sure the backend is running (`npm run dev` in `api/` directory)
- Check that the API URL matches your setup
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical devices, ensure firewall allows connections

### Permission Issues
- iOS: Check `Info.plist` has microphone permission
- Android: Check `AndroidManifest.xml` has RECORD_AUDIO permission

### OpenAI API Errors
- Verify your API key in `api/.env`
- Check your OpenAI account has credits
- Ensure the API key has access to Whisper and GPT-4o-mini

