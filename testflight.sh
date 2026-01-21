#!/bin/bash

# TestFlight 배포 스크립트
# 이 스크립트는 Flutter 앱을 빌드하고 Xcode에서 Archive를 생성할 준비를 합니다.

set -e

echo "🚀 TestFlight 배포 준비 시작..."
echo ""

# 앱 디렉토리로 이동
cd "$(dirname "$0")/app"

# 1. Flutter 클린 및 의존성 설치
echo "📦 Flutter 클린 및 의존성 설치 중..."
flutter clean
flutter pub get

# 2. iOS Pods 업데이트
echo ""
echo "📱 iOS Pods 업데이트 중..."
cd ios
pod install
cd ..

# 3. 버전 확인
echo ""
echo "📋 현재 버전 정보:"
grep "^version:" pubspec.yaml | head -1

# 4. IPA 빌드
echo ""
echo "🔨 Release IPA 빌드 중..."
echo "이 작업은 몇 분이 걸릴 수 있습니다..."
flutter build ipa --release

# 5. 빌드 완료 메시지
echo ""
echo "✅ 빌드 완료!"
echo ""
echo "📝 다음 단계:"
echo "1. Xcode 열기:"
echo "   open ios/Runner.xcworkspace"
echo ""
echo "2. Xcode에서:"
echo "   - Product → Scheme → Runner 선택"
echo "   - 상단에서 'Any iOS Device (arm64)' 선택 (시뮬레이터 아님!)"
echo "   - Product → Archive 클릭"
echo "   - Archive 완료 후 'Distribute App' 클릭"
echo "   - 'App Store Connect' 선택 → 'Upload' 선택"
echo ""
echo "3. App Store Connect에서:"
echo "   - TestFlight 탭으로 이동"
echo "   - 빌드가 'Ready to Test' 상태가 될 때까지 대기 (10-30분)"
echo "   - Internal/External Testing 그룹에 빌드 추가"
echo ""
echo "💡 자세한 내용은 TESTFLIGHT_GUIDE.md를 참고하세요."
