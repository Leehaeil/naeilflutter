# naeilflutter

Flutter 프로젝트 초기화 및 페이지 추가를 위한 CLI 도구입니다. GetX 기반 프로젝트 구조를 자동으로 생성하며, 모바일과 웹을 완전히 분리한 아키텍처를 제공합니다.

## 기능

- `naeil flutter init`: Flutter 프로젝트를 생성하고 GetX 기반 프로젝트 구조로 초기화
  - 모바일(`lib/mobile/`)과 웹(`lib/web/`) 코드를 완전히 분리하여 생성
  - 템플릿 기반 직접 생성 (sample 폴더 불필요)
- `naeil flutter addpage`: 기존 Flutter 프로젝트에 새 페이지를 추가 (View, Controller, Binding 자동 생성)

## 설치

### pub.dev에서 설치 (권장)

```bash
dart pub global activate naeilflutter
```

### 개발 버전 설치

```bash
# 저장소 클론
git clone https://github.com/yourusername/naeilflutter.git
cd naeilflutter

# 의존성 설치
dart pub get

# 활성화 (전역 설치)
dart pub global activate --source path .
```

## 사용법

### Flutter 프로젝트 생성

```bash
naeil flutter init
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
$ naeil flutter init

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

💡 생성된 프로젝트 구조:
  - lib/main.dart: 플랫폼 자동 분기 (모바일/웹)
  - lib/mobile/: 모바일 전용 코드 (항상 생성)
  - lib/web/: 웹 전용 코드 (web 플랫폼 선택 시 생성)
  - 기본 페이지: splash, login, home 페이지가 자동 생성됨
```

### Flutter 페이지 추가

기존 Flutter 프로젝트에 새 페이지를 추가할 수 있습니다.

```bash
naeil flutter addpage
```

명령어 실행 시 다음 정보를 입력받습니다:

1. **플랫폼 선택** (웹 플랫폼이 활성화되어 있는 경우): `app` 또는 `web`
2. **페이지 이름**: 페이지 이름 (예: `profile`, `settings`)
3. **컨트롤러 사용 여부**: GetX Controller 사용 여부

#### 실행 예시

```bash
$ naeil flutter addpage

📄 Flutter 페이지를 추가합니다...

플랫폼을 선택하세요:
어느 플랫폼에 추가하시겠습니까?
  ❯ app
    web

페이지 이름을 입력하세요 (예: profile, settings): profile
컨트롤러를 사용하시겠습니까? (Y/n): y

✅ 페이지가 성공적으로 추가되었습니다!

📝 다음 단계:
  - 라우팅 설정을 확인하세요: lib/{platform}/routes/app_pages.dart
  - 생성된 파일을 확인하세요: lib/{platform}/pages/profile/
```

#### 생성되는 파일 구조

컨트롤러를 사용하는 경우:

```
lib/{platform}/pages/{page_name}/
├── controllers/
│   └── {page_name}_controller.dart
├── views/
│   └── {page_name}_view.dart
└── bindings/
    └── {page_name}_binding.dart
```

컨트롤러를 사용하지 않는 경우:

```
lib/{platform}/pages/{page_name}/
└── views/
    └── {page_name}_view.dart
```

> **참고**: `{platform}`은 `mobile` 또는 `web`입니다.

## 프로젝트 구조

### CLI 패키지 구조

```
naeilflutter/
├── bin/
│   └── naeileun.dart                    # CLI 진입점
├── lib/
│   ├── commands/
│   │   ├── flutter_init_command.dart    # flutter init 명령어 구현
│   │   └── flutter_add_page_command.dart # flutter addpage 명령어 구현
│   ├── utils/
│   │   ├── flutter_runner.dart          # Flutter 명령어 실행
│   │   ├── project_initializer.dart     # 프로젝트 초기화 로직
│   │   └── project_template_generator.dart # 템플릿 기반 코드 생성
│   └── naeilflutter.dart                # 라이브러리 export
└── pubspec.yaml
```

### 생성되는 Flutter 프로젝트 구조

`naeil flutter init` 명령어로 생성되는 프로젝트 구조:

```
your_flutter_app/
├── lib/
│   ├── main.dart                        # 진입점 (플랫폼 자동 분기)
│   ├── mobile/                          # 모바일 전용 코드
│   │   ├── bootstrap_mobile.dart         # 모바일 앱 초기화
│   │   ├── data/                        # API 통신 레이어
│   │   │   ├── auth_data.dart
│   │   │   └── dto/
│   │   ├── models/                      # 도메인 모델
│   │   ├── repositories/                # Repository 구현
│   │   ├── pages/                       # 페이지별 코드
│   │   │   ├── splash/
│   │   │   ├── login/
│   │   │   └── home/
│   │   ├── routes/                      # 라우팅 설정
│   │   ├── services/                    # 전역 서비스
│   │   ├── theme/                       # 테마 설정
│   │   └── utils/                       # 유틸리티
│   └── web/                             # 웹 전용 코드 (web 플랫폼 선택 시)
│       ├── main.dart                    # 웹 진입점
│       ├── bootstrap_web.dart           # 웹 앱 초기화
│       ├── web_app.dart                 # 웹 전용 앱 위젯
│       ├── data/                        # API 통신 레이어
│       ├── models/                      # 도메인 모델
│       ├── repositories/                # Repository 구현
│       ├── pages/                       # 페이지별 코드
│       ├── routes/                      # 라우팅 설정
│       ├── services/                    # 전역 서비스
│       ├── theme/                       # 테마 설정
│       └── utils/                       # 유틸리티
├── test/
│   └── widget_test.dart                 # 기본 테스트 파일
└── pubspec.yaml                          # 프로젝트 설정
```

### 주요 특징

- **완전한 플랫폼 분리**: 모바일과 웹 코드가 완전히 독립적으로 분리되어 관리
- **템플릿 기반 생성**: sample 폴더 없이 직접 코드 생성
- **GetX 기반**: 상태 관리, 라우팅, 의존성 주입을 GetX로 통합
- **Repository 패턴**: 데이터 레이어와 비즈니스 로직 분리

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
