# Offline Mode Guide

## What is Offline Mode?

Offline mode is a feature that detects when your device doesn't have an internet connection and provides appropriate feedback and restrictions.

## Current Implementation

### 1. **Visual Indicator (Offline Banner)**

- **Location**: Top of the app (in main scaffold)
- **Appearance**: Orange banner with WiFi-off icon
- **Text**: "오프라인 모드" (Korean) / "Offline Mode" (English)
- **Behavior**: Automatically appears/disappears based on connectivity

### 2. **Connectivity Checks Before API Calls**

- **Location**: `SpeakBetterApi` class
- **Behavior**:
  - Checks internet connection before making any API call
  - Throws a clear error if offline
  - Prevents unnecessary API calls when offline

### 3. **Enhanced Error Messages**

- **Location**: `ErrorMessages` utility class
- **Behavior**:
  - Detects connectivity-related errors
  - Shows user-friendly messages:
    - Korean: "인터넷 연결이 필요합니다. 네트워크 연결을 확인해주세요."
    - English: "Internet connection required. Please check your network connection."

### 4. **UI State Management**

- **Record Screen**:
  - Record button is disabled when offline
  - Button shows "오프라인 모드" / "Offline Mode" text when offline
  - Icon changes to WiFi-off icon when offline
  - Prevents users from starting recordings that will fail

## How It Works

### Connectivity Detection

- Uses `connectivity_plus` package
- Monitors network status in real-time
- Detects: WiFi, Mobile Data, or None

### API Call Protection

```dart
// Before every API call:
await _checkConnectivity(); // Throws error if offline
```

### Error Handling

- Connectivity errors are caught and displayed with clear messages
- Users understand why actions fail (no internet)

## What Works Offline

✅ **Works Offline:**

- View history (stored locally)
- Review flashcards (stored locally)
- View past session results (stored locally)
- Browse topics (stored locally)

❌ **Requires Internet:**

- Recording and transcription (needs OpenAI Whisper API)
- Speech improvement (needs OpenAI GPT API)
- Image analysis (needs OpenAI Vision API)

## User Experience

### When Online:

- All features work normally
- No banner displayed
- Record button enabled

### When Offline:

- Orange banner appears at top
- Record button disabled with offline indicator
- Clear error messages if user tries to use online features
- Offline features (history, flashcards) still work

## Technical Details

### Files Involved:

1. **`app/lib/services/connectivity_service.dart`**
   - Service for checking connectivity
   - Provides `isOnline()` method

2. **`app/lib/widgets/offline_banner.dart`**
   - Banner widget
   - Uses `connectivityProvider` to watch connectivity

3. **`app/lib/api/speakbetter_api.dart`**
   - Checks connectivity before API calls
   - Throws clear errors when offline

4. **`app/lib/utils/error_messages.dart`**
   - Enhanced error messages for offline scenarios

5. **`app/lib/features/record/record_screen.dart`**
   - Disables record button when offline
   - Shows offline state in UI

## Future Enhancements (Optional)

1. **Offline Queue**:
   - Queue recordings when offline
   - Process when back online

2. **Cached Responses**:
   - Cache recent API responses
   - Show cached results when offline

3. **Offline Indicator in More Places**:
   - Show offline state in other screens
   - Disable online-only features globally

4. **Retry Mechanism**:
   - Auto-retry failed requests when back online
   - Background sync

---

**Status**: ✅ Fully Implemented
**Package**: `connectivity_plus: ^6.0.5`
