# Speak Better - Language Learning App

A language learning app for Korean/English practice with audio recording, transcription, and AI-powered improvement feedback.

## Project Structure

```
speakbetter/
  ├── api/          # Node.js/TypeScript backend
  └── app/          # Flutter mobile app
```

## Backend Setup (API)

### Prerequisites
- Node.js 18+ 
- npm or yarn

### Installation

1. Navigate to the API directory:
```bash
cd api
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file (copy from `.env.example`):
```bash
cp .env.example .env
```

4. Add your OpenAI API key to `.env`:
```
OPENAI_API_KEY=your_openai_api_key_here
PORT=8080
MAX_AUDIO_SECONDS=120
```

### Running the API

Development mode:
```bash
npm run dev
```

Build for production:
```bash
npm run build
npm start
```

The API will be available at `http://localhost:8080`

### API Endpoints

- `GET /health` - Health check
- `POST /v1/transcribe` - Transcribe audio file
- `POST /v1/improve` - Improve transcript with AI feedback

## Flutter App Setup

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- iOS Simulator / Android Emulator or physical device

### Installation

1. Navigate to the app directory:
```bash
cd app
```

2. Get Flutter dependencies:
```bash
flutter pub get
```

3. Configure API base URL (optional):
   - Default: `http://localhost:8080`
   - For iOS Simulator: Use `http://localhost:8080`
   - For Android Emulator: Use `http://10.0.2.2:8080`
   - For physical device: Use your computer's IP address (e.g., `http://192.168.1.100:8080`)

   To override, run:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://your-api-url:8080
   ```

### Running the App

```bash
flutter run
```

### Features

- **Language Selection**: Choose between Korean (한국어) and English
- **Learner Mode**: Select whether you're learning Korean or English
- **Topic Management**: 
  - Built-in practice topics
  - Create custom topics
  - Delete custom topics
- **Audio Recording**: Record your speech practice
- **AI Transcription**: Automatic transcription using OpenAI Whisper
- **AI Improvement**: Get detailed feedback including:
  - Improved version of your transcript
  - Alternative versions (formal, casual, concise)
  - Grammar fixes with explanations
  - Vocabulary upgrades
  - Filler word analysis
- **History**: View and manage your practice sessions

## Architecture

### Backend
- **Express.js** - Web framework
- **TypeScript** - Type safety
- **OpenAI API** - Audio transcription and text improvement
- **Zod** - Schema validation
- **Multer** - File upload handling

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Riverpod** - State management
- **Hive** - Local data persistence
- **Record** - Audio recording
- **Dio** - HTTP client

## Security Notes

- API keys are stored server-side only (never shipped to the app)
- All API calls go through the backend
- Local storage for topics and sessions (no cloud sync in MVP)

## Development Notes

### Backend
- Uses OpenAI's Whisper model for transcription
- Uses GPT-4o-mini with structured outputs for improvement
- Validates all inputs with Zod schemas
- Temporary audio files are cleaned up after processing

### Flutter App
- Uses Riverpod for state management
- Hive for local persistence (topics and sessions)
- Material Design 3 UI
- Supports both Korean and English interfaces

## Next Steps

- Add user accounts and cloud sync
- Add more built-in topics
- Add pronunciation scoring
- Add progress tracking
- Add export functionality

## License

Private project - All rights reserved

