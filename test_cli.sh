#!/bin/bash

# CLI 테스트 스크립트
echo "🧪 naeilflutter CLI 테스트"
echo ""

# 1. 기본 명령어 테스트
echo "1️⃣ 기본 명령어 테스트"
echo "   - 도움말 표시:"
dart run bin/naeileun.dart 2>&1 | head -5
echo ""

# 2. 잘못된 명령어 테스트
echo "2️⃣ 잘못된 명령어 테스트"
echo "   - 잘못된 명령어:"
dart run bin/naeileun.dart flutter invalid 2>&1
echo ""

# 3. Flutter 설치 확인
echo "3️⃣ Flutter 설치 확인"
if command -v flutter &> /dev/null; then
    echo "   ✅ Flutter가 설치되어 있습니다"
    flutter --version | head -1
else
    echo "   ❌ Flutter가 설치되어 있지 않습니다"
fi
echo ""

# 4. sample 폴더 확인
echo "4️⃣ sample 폴더 확인"
if [ -d "sample" ]; then
    echo "   ✅ sample 폴더가 존재합니다"
    echo "   - lib 폴더: $([ -d "sample/lib" ] && echo "✅" || echo "❌")"
    echo "   - pubspec.yaml: $([ -f "sample/pubspec.yaml" ] && echo "✅" || echo "❌")"
else
    echo "   ❌ sample 폴더가 없습니다"
fi
echo ""

# 5. 실제 실행 안내
echo "5️⃣ 실제 테스트 안내"
echo "   다음 명령어로 실제 테스트를 진행할 수 있습니다:"
echo ""
echo "   dart run bin/naeileun.dart flutter init"
echo ""
echo "   또는 전역 설치 후:"
echo "   dart pub global activate --source path ."
echo "   naeileun flutter init"
echo ""

