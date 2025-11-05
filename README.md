# naeilflutter

Flutter 프로젝트 초기화 CLI 도구입니다.

## 기능

- `naeileun flutter init`: Flutter 프로젝트를 생성하고 sample 폴더 구조에 맞춰 초기화

## 설치

```bash
# 의존성 설치
dart pub get

# 활성화 (전역 설치)
dart pub global activate --source path .
```

## 사용법

### Flutter 프로젝트 생성

```bash
naeileun flutter init
```

명령어 실행 시 다음 정보를 입력받습니다:

1. **프로젝트 이름**: Flutter 프로젝트 이름 (예: `my_flutter_app`)
2. **패키지 ID**: Android/iOS 패키지 ID (예: `com.naeil.flutter`)
3. **플랫폼 선택**: 지원할 플랫폼을 체크박스로 선택
   - android
   - ios
   - web
   - windows
   - macos
   - linux

### 실행 예시

```bash
$ naeileun flutter init

🚀 Flutter 프로젝트 초기화를 시작합니다...

프로젝트 이름을 입력하세요 [my_flutter_app]: my_app
패키지 ID를 입력하세요 (예: com.naeil.flutter) [com.example.app]: com.naeil.flutter

플랫폼을 선택하세요 (스페이스바로 선택, Enter로 확인):
플랫폼 선택
  ☑ android
  ☑ ios
  ☐ web
  ☐ windows
  ☐ macos
  ☐ linux

📦 Flutter 프로젝트를 생성하는 중...
✅ Flutter 프로젝트가 생성되었습니다: /path/to/my_app

🔧 프로젝트 구조를 초기화하는 중...
✅ 프로젝트 초기화가 완료되었습니다!

📝 다음 단계:
  cd my_app
  flutter pub get
  flutter run
```

## 프로젝트 구조

```
naeilflutter/
├── bin/
│   └── naeileun.dart          # CLI 진입점
├── lib/
│   ├── commands/
│   │   └── flutter_init_command.dart  # flutter init 명령어 구현
│   ├── utils/
│   │   ├── flutter_runner.dart        # Flutter 명령어 실행
│   │   └── project_initializer.dart   # 프로젝트 초기화 로직
│   └── naeilflutter.dart      # 라이브러리 export
├── sample/                     # Flutter 프로젝트 템플릿
└── pubspec.yaml
```

## 의존성

- `args: ^2.6.0` - 명령어 인자 파싱
- `path: ^1.9.0` - 경로 처리
- `interact_cli: ^2.4.0` - 체크박스/멀티셀렉트 TUI
- `mason_logger: ^0.3.3` - 로그/프롬프트 출력

## 개발

```bash
# 코드 분석
dart analyze

# 테스트 실행
dart test

# 의존성 업데이트
dart pub get
```

## 라이선스

MIT License