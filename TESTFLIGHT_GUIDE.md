# 🍎 TestFlight 배포 가이드

이 가이드는 Speak Better 앱을 TestFlight에 배포하는 전체 과정을 안내합니다.

## 📋 사전 준비사항

### 1. Apple Developer 계정
- **필수**: Apple Developer Program 멤버십 ($99/년)
- [Apple Developer](https://developer.apple.com/programs/)에서 가입
- 가입 후 24-48시간 소요될 수 있음

### 2. App Store Connect 설정

#### 옵션 A: 기존 앱이 있는 경우
1. [App Store Connect](https://appstoreconnect.apple.com/) 접속
2. **My Apps** 클릭
3. 이미 생성된 **Speak Better** 앱이 있는지 확인
4. 있다면 그 앱을 사용하면 됩니다!

#### 옵션 B: 새 앱 생성 (기존 앱이 없는 경우)
1. [App Store Connect](https://appstoreconnect.apple.com/) 접속
2. **My Apps** 클릭
3. **+** 버튼 → **New App** 클릭
4. 정보 입력:
   - **Platform**: iOS
   - **Name**: Speak Better (또는 다른 이름, 예: "Speak Better App")
   - **Primary Language**: English (또는 Korean)
   - **Bundle ID**: `com.speakbetter.app` (이미 사용 중이면 아래 해결 방법 참고)
   - **SKU**: `speakbetter-001` (이미 사용 중이면 다른 값 사용, 예: `speakbetter-002`)
   - **User Access**: Full Access
5. **Create** 클릭

#### ⚠️ 에러 발생 시: "SKU/Bundle ID already used"

**해결 방법 1: 기존 앱 확인**
- App Store Connect의 **My Apps**에서 이미 생성된 앱이 있는지 확인
- 있다면 그 앱을 사용하세요!

**해결 방법 2: 새로운 SKU 사용**
- SKU는 고유해야 합니다
- 예: `speakbetter-001` → `speakbetter-002`, `speakbetter-app-2024`, `speakbetter-ios-v1` 등

**해결 방법 3: 새로운 Bundle ID 사용**
- Bundle ID가 이미 사용 중이면:
  1. [Apple Developer Portal](https://developer.apple.com/account/) 접속
  2. **Identifiers** → 확인하여 사용 가능한 Bundle ID 찾기
  3. 또는 새로운 Bundle ID 사용: `com.yourname.speakbetter`, `com.speakbetter.app.v2` 등
  4. Xcode 프로젝트의 Bundle ID도 변경 필요 (아래 참고)

## 🔧 Xcode 프로젝트 설정

### Step 1: Bundle Identifier 확인

```bash
cd app/ios
open Runner.xcworkspace
```

Xcode에서:
1. 왼쪽 프로젝트 네비게이터에서 **Runner** 선택
2. **TARGETS** → **Runner** 선택
3. **Signing & Capabilities** 탭
4. **Bundle Identifier** 확인: `com.speakbetter.app`

### Step 2: Signing 설정

1. **Signing & Capabilities** 탭에서
2. **Automatically manage signing** 체크
3. **Team** 선택 (Apple Developer 계정)
4. Xcode가 자동으로:
   - Provisioning Profile 생성
   - Signing Certificate 설정

**에러 발생 시:**
- "No profiles for 'com.speakbetter.app' were found"
  → App Store Connect에서 Bundle ID가 등록되어 있는지 확인
  → Xcode → Preferences → Accounts → Apple ID 추가 확인

### Step 3: Version 및 Build 번호 설정

**방법 1: Xcode에서**
1. **TARGETS** → **Runner** → **General** 탭
2. **Version**: `1.0.0` (사용자에게 보이는 버전)
3. **Build**: `1` (내부 빌드 번호, 매번 증가)

**방법 2: pubspec.yaml에서**
```yaml
version: 1.0.0+1  # version+build
```

그리고 Xcode에서도 동일하게 설정

## 📦 Archive 생성 및 업로드

### Step 1: Flutter 빌드

터미널에서:
```bash
cd app
flutter clean
flutter pub get
flutter build ipa --release
```

**또는 Xcode에서 직접:**

### Step 2: Xcode에서 Archive

1. Xcode에서 **Product** → **Scheme** → **Runner** 선택
2. 상단에서 **Any iOS Device (arm64)** 선택 (시뮬레이터 아님!)
3. **Product** → **Archive** 클릭
4. 빌드 완료까지 대기 (5-10분 소요)

### Step 3: Archive Organizer

Archive가 완료되면 자동으로 **Organizer** 창이 열립니다.

1. **Distribute App** 클릭
2. **App Store Connect** 선택 → **Next**
3. **Upload** 선택 → **Next**
4. **Automatically manage signing** 선택 → **Next**
5. **Upload** 클릭
6. 업로드 완료까지 대기 (5-15분)

**수동으로 Organizer 열기:**
- **Window** → **Organizer**
- 또는 **Product** → **Archive** 후 Organizer 자동 열림

## 🚀 App Store Connect에서 TestFlight 설정

### Step 1: 빌드 처리 대기

1. [App Store Connect](https://appstoreconnect.apple.com/) 접속
2. **My Apps** → **Speak Better** 선택
3. **TestFlight** 탭 클릭
4. **iOS Builds** 섹션에서 업로드된 빌드 확인
5. 상태가 **Processing** → **Ready to Test**로 변경될 때까지 대기 (10-30분)

### Step 2: Internal Testing 설정 (빠른 테스트)

**Internal Testing**은 최대 100명의 팀 멤버에게 즉시 배포 가능:

1. **TestFlight** 탭 → **Internal Testing** 섹션
2. **+** 버튼 클릭 → **New Internal Group** 생성
3. 그룹 이름: `Internal Testers`
4. **Add Builds** 클릭 → 업로드된 빌드 선택
5. **Save** 클릭

**테스터 추가:**
1. **Testers** 탭 클릭
2. **+** 버튼 → 이메일 주소 입력
3. 테스터는 이메일로 초대장 받음
4. **TestFlight** 앱 설치 후 앱 다운로드 가능

### Step 3: External Testing 설정 (공개 테스트)

**External Testing**은 최대 10,000명에게 배포 가능 (App Review 필요):

1. **TestFlight** 탭 → **External Testing** 섹션
2. **+** 버튼 → **Create a Group**
3. 그룹 이름 입력
4. **Add Builds** → 빌드 선택
5. **Next** 클릭

**테스트 정보 입력:**
- **What to Test**: 테스터에게 알릴 내용
  ```
  이 버전에서 테스트할 주요 기능:
  - 음성 녹음 및 전사
  - AI 기반 텍스트 개선
  - 연습 세션 히스토리
  - 진행 상황 추적
  ```
- **Feedback Email**: 피드백 받을 이메일
- **Description**: 앱 설명

6. **Submit for Review** 클릭
7. Apple 심사 대기 (보통 24-48시간)

**테스터 추가:**
- **Public Link** 생성하여 공유
- 또는 이메일로 개별 초대

## 📝 필수 정보 입력 (첫 배포 시)

### App Information

1. **App Store Connect** → **App Information**
2. 필수 정보 입력:
   - **Category**: Education
   - **Privacy Policy URL**: (필요시)
   - **Support URL**: (필요시)

### App Privacy

1. **App Privacy** 탭
2. 데이터 수집 여부 선택:
   - **Audio Data**: Yes (녹음 기능)
   - **User Content**: Yes (연습 세션)
   - **Usage Data**: Optional
   - **Diagnostics**: Optional

## 🔍 문제 해결

### 문제 1: "No signing certificate found"

**해결:**
```bash
# Xcode에서
Xcode → Preferences → Accounts → Apple ID 선택 → Download Manual Profiles
```

또는:
1. [Apple Developer Portal](https://developer.apple.com/account/) 접속
2. **Certificates, Identifiers & Profiles**
3. **Certificates** → **+** → **iOS App Development** 선택
4. Certificate 다운로드 후 설치

### 문제 2: "Bundle ID not found"

**해결:**
1. [Apple Developer Portal](https://developer.apple.com/account/) 접속
2. **Identifiers** → **+** 클릭
3. **App IDs** 선택
4. **Description**: Speak Better
5. **Bundle ID**: `com.speakbetter.app` (Explicit)
6. **Capabilities** 선택:
   - ✅ App Groups (필요시)
   - ✅ Associated Domains (필요시)
7. **Continue** → **Register**

### 문제 3: Archive가 생성되지 않음

**해결:**
1. **Any iOS Device (arm64)** 선택 확인 (시뮬레이터 아님!)
2. **Product** → **Clean Build Folder** (Shift+Cmd+K)
3. 다시 Archive 시도

### 문제 4: "Invalid Bundle"

**해결:**
- Bundle Identifier가 App Store Connect와 일치하는지 확인
- Version/Build 번호가 이전보다 큰지 확인
- Info.plist에 필수 키가 있는지 확인

### 문제 5: 업로드 실패

**해결:**
```bash
# Transporter 앱 사용 (Xcode 대신)
# Mac App Store에서 "Transporter" 검색 후 설치
# Archive를 .ipa로 Export 후 Transporter로 업로드
```

## 📱 테스터가 받는 것

1. **이메일 초대장** 받음
2. **TestFlight 앱** 설치 (App Store에서 무료)
3. 초대장의 **View in TestFlight** 클릭
4. 앱 다운로드 및 설치
5. 테스트 시작!

## 🎯 빠른 체크리스트

- [ ] Apple Developer 계정 활성화 ($99/년)
- [ ] App Store Connect에서 앱 생성
- [ ] Bundle ID 등록 (`com.speakbetter.app`)
- [ ] Xcode에서 Signing 설정 완료
- [ ] Version/Build 번호 설정
- [ ] `flutter build ipa --release` 성공
- [ ] Xcode에서 Archive 생성 성공
- [ ] App Store Connect에 업로드 성공
- [ ] 빌드가 "Ready to Test" 상태로 변경됨
- [ ] Internal/External Testing 그룹 생성
- [ ] 테스터 추가 완료

## 🚀 빠른 시작 명령어

```bash
# 1. 프로젝트 디렉토리로 이동
cd /Users/hyunjin/Codes/speakbetter/app

# 2. 클린 빌드
flutter clean
flutter pub get

# 3. IPA 빌드
flutter build ipa --release

# 4. Xcode 열기
open ios/Runner.xcworkspace

# 5. Xcode에서:
# - Product → Scheme → Runner
# - Any iOS Device (arm64) 선택
# - Product → Archive
# - Distribute App → App Store Connect → Upload
```

## 📞 추가 도움말

- [Apple TestFlight 가이드](https://developer.apple.com/testflight/)
- [App Store Connect 도움말](https://help.apple.com/app-store-connect/)
- [Flutter iOS 배포 가이드](https://docs.flutter.dev/deployment/ios)

---

**문제가 발생하면:**
1. Xcode의 **Report Navigator** (왼쪽 사이드바)에서 빌드 로그 확인
2. App Store Connect의 **Activity** 탭에서 업로드 상태 확인
3. 에러 메시지를 검색하여 해결 방법 찾기

행운을 빕니다! 🎉
