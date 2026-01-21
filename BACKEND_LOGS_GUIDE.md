# 📋 백엔드 로그 확인 가이드

백엔드 로그를 확인하는 방법은 두 가지가 있습니다:
1. **Render 대시보드** (배포된 서버)
2. **로컬 실행** (개발 중)

## 🌐 방법 1: Render 대시보드에서 로그 보기

### Step 1: Render 대시보드 접속
1. [Render Dashboard](https://dashboard.render.com) 접속
2. 로그인

### Step 2: 서비스 선택
1. 대시보드에서 **`speakbetter-api`** 서비스 클릭
2. 또는 서비스 목록에서 찾기

### Step 3: 로그 확인
1. 상단 메뉴에서 **"Logs"** 탭 클릭
2. 실시간 로그가 표시됩니다

**로그에서 확인할 수 있는 것:**
- `=== IMPROVE REQUEST ===` - 요청 정보
- `=== IMPROVE REQUEST BODY ===` - 요청 본문
- `=== IMPROVE ERROR ===` - 에러 상세 정보
- `Image analysis error:` - 이미지 분석 에러
- `Validation errors:` - 데이터 검증 에러

### Step 4: 로그 필터링 (선택사항)
- Render 로그 화면에서 검색 기능 사용 가능
- "IMPROVE" 또는 "ERROR"로 검색하여 관련 로그만 보기

## 💻 방법 2: 로컬에서 백엔드 실행하여 로그 보기

### Step 1: 백엔드 디렉토리로 이동
```bash
cd api
```

### Step 2: 환경 변수 설정
`.env` 파일이 있는지 확인:
```bash
cat .env
```

필요한 환경 변수:
```
OPENAI_API_KEY=your_api_key_here
PORT=8080
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}
```

### Step 3: 개발 모드로 실행
```bash
npm run dev
```

또는 프로덕션 모드:
```bash
npm run build
npm start
```

### Step 4: 로그 확인
터미널에서 실시간으로 로그가 출력됩니다:
- `API listening on :8080` - 서버 시작
- `=== IMPROVE REQUEST ===` - 요청 로그
- `=== IMPROVE ERROR ===` - 에러 로그

## 🔍 로그에서 확인할 주요 정보

### 정상 요청 로그:
```
=== IMPROVE REQUEST ===
Transcript received: [사용자의 전사 내용]
Transcript length: 123
Language: ko
Learner mode: english_learner
Has image: true
```

### 에러 로그:
```
=== IMPROVE ERROR ===
Error: [에러 메시지]
Error name: ZodError
Validation errors: [검증 에러 상세]
```

## 🐛 문제 해결

### 로그가 보이지 않으면:
1. **Render**: 서비스가 실행 중인지 확인 (Status가 "Live"인지 확인)
2. **로컬**: 백엔드가 실행 중인지 확인 (`npm run dev` 실행 중인지)

### 로그가 너무 많으면:
- Render 로그 화면에서 검색 기능 사용
- 특정 키워드로 필터링 (예: "ERROR", "IMPROVE")

### 로컬에서 실행 시 포트 충돌:
```bash
# 포트 8080이 사용 중이면 다른 포트 사용
PORT=8081 npm run dev
```

## 📱 Flutter 앱과 함께 테스트

로컬 백엔드를 사용하려면:

1. **로컬 백엔드 실행:**
   ```bash
   cd api
   npm run dev
   ```

2. **Flutter 앱 설정 확인:**
   - `app/lib/config.dart`에서 API URL 확인
   - iOS 시뮬레이터: `http://localhost:8080`
   - Android 에뮬레이터: `http://10.0.2.2:8080`
   - 실제 기기: 컴퓨터의 IP 주소 사용

3. **앱 실행:**
   ```bash
   cd app
   flutter run
   ```

4. **로그 동시 확인:**
   - 백엔드 터미널: 서버 로그
   - Flutter 콘솔: 앱 로그

## 💡 팁

- **에러 발생 시**: 백엔드 로그와 Flutter 콘솔 로그를 모두 확인하세요
- **디버깅**: 로컬에서 실행하면 더 빠르게 로그를 확인할 수 있습니다
- **Render 로그**: 최근 1000줄 정도만 표시되므로, 오래된 로그는 보이지 않을 수 있습니다
