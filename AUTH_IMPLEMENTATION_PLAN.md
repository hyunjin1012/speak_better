# Authentication Implementation Plan

## Overview
Add Firebase Authentication to protect API endpoints and enable user-based features.

## Architecture

```
Flutter App → Firebase Auth → Get ID Token → API Call with Bearer Token
                                                      ↓
                                              Express Backend
                                                      ↓
                                         Verify Token (Firebase Admin)
                                                      ↓
                                              Process Request
```

## Implementation Steps

### Phase 1: Firebase Setup
1. Create Firebase project at https://console.firebase.google.com
2. Enable Authentication methods:
   - Email/Password
   - Google Sign-In (optional)
   - Apple Sign-In (optional, for iOS)
3. Get Firebase config (for Flutter)
4. Get Service Account JSON (for backend)

### Phase 2: Backend Changes

**Files to create/modify:**
- `api/src/lib/firebase.ts` - Initialize Firebase Admin
- `api/src/middleware/auth.ts` - Token verification middleware
- `api/src/index.ts` - Add auth middleware to protected routes

**Changes:**
- Install `firebase-admin` package
- Add `FIREBASE_SERVICE_ACCOUNT_JSON` env var in Render
- Protect `/v1/transcribe` and `/v1/improve` routes
- Keep `/health` public

### Phase 3: Flutter Changes

**Files to create/modify:**
- `app/lib/services/auth_service.dart` - Firebase Auth wrapper
- `app/lib/api/speakbetter_api.dart` - Add Authorization header
- `app/lib/features/auth/login_screen.dart` - Login UI
- `app/lib/main.dart` - Add auth state management

**Changes:**
- Install `firebase_core` and `firebase_auth` packages
- Add Firebase config files (`google-services.json`, `GoogleService-Info.plist`)
- Update API calls to include `Authorization: Bearer <token>`
- Add login screen before accessing main app

### Phase 4: Optional Enhancements
- User-based rate limiting
- Firebase App Check (prevent API abuse)
- User profile storage
- Session persistence

## Benefits

✅ **Security**: Only authenticated users can use API
✅ **Rate Limiting**: Can limit per user instead of per IP
✅ **User Features**: Can add user-specific features later
✅ **Analytics**: Track usage per user
✅ **Scalability**: Foundation for multi-user features

## Estimated Effort

- Backend setup: ~30 minutes
- Flutter integration: ~1 hour
- Testing: ~30 minutes
- **Total: ~2 hours**

## Questions to Consider

1. **Do you want to require login immediately?**
   - Option A: Require login before using app
   - Option B: Allow anonymous usage, add login later

2. **Which sign-in methods?**
   - Email/Password (required)
   - Google Sign-In (recommended)
   - Apple Sign-In (iOS only, recommended for App Store)

3. **Rate limiting strategy?**
   - Per user: X requests per day
   - Per user: X requests per minute
   - Tiered: Free users vs Premium users

