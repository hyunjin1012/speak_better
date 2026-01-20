# 🧪 Testing Guide - New Features

## Setup

First, install the new dependencies:

```bash
cd /Users/hyunjin/Codes/speakbetter/app
flutter pub get
```

If you get permission errors, fix them first:
```bash
sudo chown -R $(whoami) /opt/homebrew/Caskroom/flutter/3.7.7/flutter/bin/cache/lockfile
```

Then run the app:
```bash
flutter run
```

Or on your iPhone:
```bash
flutter run -d "iPhone 17 Pro"
```

---

## ✅ Feature 1: Audio Playback

### How to Test:
1. **Record a session**:
   - Sign in
   - Select language and learner mode
   - Choose a topic
   - Record something (at least 10 seconds)
   - Stop recording and wait for processing

2. **Test audio playback**:
   - On the Results screen, you should see an audio player at the top
   - Click the **Play** button ▶️
   - Audio should start playing
   - You should see:
     - Play/Pause button
     - Progress slider
     - Current time / Total time (e.g., "00:05 / 00:30")
   - Drag the slider to seek to different positions
   - Click pause to stop

### Expected Behavior:
- ✅ Audio plays from the recording
- ✅ Progress updates in real-time
- ✅ Slider allows seeking
- ✅ Time display shows current position and duration

---

## ✅ Feature 2: Search History

### How to Test:
1. **Create multiple sessions**:
   - Record at least 3-4 different sessions with different topics
   - Make sure transcripts are different (e.g., talk about food, travel, hobbies)

2. **Test search**:
   - Go to **History** tab
   - You should see a **search bar** at the top
   - Type a word from one of your transcripts
   - Results should filter in real-time
   - You should see "X results" count below search bar
   - Click the **X** button to clear search

### Expected Behavior:
- ✅ Search bar appears at top of history screen
- ✅ Typing filters sessions instantly
- ✅ Results count updates
- ✅ Clear button (X) clears search
- ✅ Empty state shows when no results

---

## ✅ Feature 3: Export Sessions

### How to Test:
1. **Open a session**:
   - Go to History
   - Tap on any session to open Results screen

2. **Test export menu**:
   - Click the **Share** icon (📤) in the top-right
   - A bottom sheet should appear with 3 options:
     - Export as PDF
     - Export as Text
     - Share

3. **Test PDF Export**:
   - Click "Export as PDF"
   - PDF viewer should open
   - Should show:
     - Session date
     - Original transcript
     - Improved text
     - Grammar fixes (if any)
     - Vocabulary upgrades (if any)
   - You can save/share the PDF

4. **Test Text Export**:
   - Click "Export as Text"
   - Share sheet should open
   - Text should include all session details
   - You can copy or share it

5. **Test Share**:
   - Click "Share"
   - Share sheet should open
   - Should show transcript and improved text

### Expected Behavior:
- ✅ Share button appears in Results screen
- ✅ Export menu shows 3 options
- ✅ PDF export creates formatted PDF
- ✅ Text export creates readable text
- ✅ Share option works

---

## ✅ Feature 4: More Built-in Topics

### How to Test:
1. **Check topic list**:
   - Go to **Topics** tab
   - You should see many more topics than before

2. **Verify categories**:
   - Look for topics in different categories:
     - Daily Life (오늘 하루 요약, Describe your day, etc.)
     - Food (좋아하는 음식, Favorite food, etc.)
     - Travel (여행 경험, Travel experience, etc.)
     - Hobbies (취미 소개, My hobby, etc.)
     - Work/Study (직업 소개, My job or studies, etc.)
     - Culture (한국 문화 소개, Cultural tradition, etc.)

3. **Test different topics**:
   - Try recording with different topics
   - Each should have unique prompts

### Expected Behavior:
- ✅ 24 topics total (was 4 before)
- ✅ Topics organized by category
- ✅ Both Korean and English topics available
- ✅ Each topic has a clear prompt

---

## 🐛 Common Issues & Fixes

### Issue: Audio playback doesn't work
**Possible causes:**
- Audio file was deleted (temporary files)
- File path is invalid

**Fix:** Record a new session - audio files are now preserved

### Issue: Export PDF doesn't work
**Possible causes:**
- Missing `pdf` or `printing` packages

**Fix:** Run `flutter pub get` again

### Issue: Search doesn't filter
**Possible causes:**
- No sessions match the search term

**Fix:** Try searching for words you know are in your transcripts

### Issue: Topics don't appear
**Possible causes:**
- App needs restart
- Cache issue

**Fix:** Hot restart the app (press `R` in terminal or restart)

---

## 📝 Testing Checklist

- [ ] Audio playback works
- [ ] Search filters sessions correctly
- [ ] PDF export creates valid PDF
- [ ] Text export creates readable text
- [ ] Share functionality works
- [ ] All 24 topics appear
- [ ] Can record with different topics
- [ ] All features work in both Korean and English UI

---

## 🎯 What to Look For

### Positive Signs:
- ✅ Smooth audio playback
- ✅ Fast search filtering
- ✅ Well-formatted PDF exports
- ✅ Easy-to-read text exports
- ✅ Variety of topics to choose from

### Things to Report:
- ❌ Audio doesn't play
- ❌ Search doesn't work
- ❌ Export fails
- ❌ Topics missing
- ❌ UI looks broken
- ❌ App crashes

---

## 🚀 Next Steps After Testing

Once you've tested these features, we can:
1. Fix any bugs you find
2. Continue with remaining features:
   - Streak counter
   - Achievement badges
   - Progress charts
   - Push notifications
   - Pronunciation scoring
   - Spaced repetition

Happy testing! 🎉
