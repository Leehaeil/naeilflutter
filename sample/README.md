# naeil_flutter_init

Flutter 프로젝트 초기화 템플릿입니다.

## 📋 목차

- [프로젝트 개요](#프로젝트-개요)
- [프로젝트 구조](#프로젝트-구조)
- [아키텍처 패턴](#아키텍처-패턴)
- [폴더 구조 상세](#폴더-구조-상세)
- [개발 가이드라인](#개발-가이드라인)
- [라우팅 시스템](#라우팅-시스템)
- [API 통신 패턴](#api-통신-패턴)
- [상태 관리 (GetX)](#상태-관리-getx)
- [인증 플로우](#인증-플로우)
- [반응형 UI (ScreenUtil)](#반응형-ui-screenutil)
- [코드 작성 규칙](#코드-작성-규칙)
- [플랫폼 분리 및 부트스트랩](#플랫폼-분리-및-부트스트랩)

---

## 프로젝트 개요

이 프로젝트는 Flutter 기반의 크로스 플랫폼 애플리케이션 템플릿입니다. 모바일과 웹 모두 지원하며 다음과 같은 특징을 가집니다:

- **Feature-based 구조**: 기능 단위로 코드를 구성하여 유지보수성 향상
- **GetX 패턴**: 상태 관리, 의존성 주입, 라우팅을 GetX로 통합 관리
- **Repository 패턴**: 데이터 레이어와 비즈니스 로직 분리
- **플랫폼 분리**: 모바일과 웹을 분리된 부트스트랩으로 관리

---

## 프로젝트 구조

```
lib/
├── app/                          # 앱 공통 코드
│   ├── data/                     # API 통신 레이어 (HTTP 요청)
│   │   ├── auth_data.dart
│   │   └── dto/                  # DTO (Data Transfer Object)
│   │       └── login_dto.dart
│   ├── models/                   # 도메인 모델 (Entity)
│   │   └── auth_data.dart
│   ├── repositories/             # Repository 구현
│   │   └── auth_repository.dart
│   ├── pages/                    # 페이지별 코드
│   │   ├── splash/
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── login/
│   │   └── home/
│   ├── routes/                   # 라우팅 설정
│   │   ├── app_routes.dart
│   │   └── app_pages.dart
│   ├── services/                 # 전역 서비스
│   │   └── auth_service.dart
│   ├── theme/                    # 테마 설정
│   │   └── custom_theme.dart
│   └── utils/                    # 유틸리티
│       ├── api.dart
│       ├── secure_storage.dart
│       └── permission_service.dart
├── main/
│   └── bootstrap_mobile.dart     # 모바일 앱 초기화
├── web/
│   ├── bootstrap_web.dart        # 웹 앱 초기화
│   └── web_app.dart              # 웹 전용 앱 위젯
└── main.dart                     # 앱 진입점 (플랫폼 자동 분기)
```

---

## 아키텍처 패턴

### 1. Feature-based (기능 중심) 구조

각 기능을 독립된 모듈로 분리하여 관리하는 구조입니다.

표준 구조:

```
pages/{feature_name}/
├── controllers/    # GetX Controller (비즈니스 로직 & 상태 관리)
├── views/          # UI 화면
├── bindings/       # GetX Binding (의존성 주입)
└── widgets/        # 페이지 전용 위젯 (선택적)
```

장점:

- 기능 단위로 코드가 응집되어 있어 이해하기 쉬움
- 관련 코드를 한 곳에서 관리
- 기능 추가/삭제 시 영향 범위가 명확함

### 2. GetX 패턴 (Controller + Binding + View)

GetX 상태 관리 라이브러리의 표준 패턴을 따릅니다.

구조:

```
Controller (비즈니스 로직 & 상태 관리)
    ↓
Binding (의존성 주입 - 페이지 진입 시 자동 실행)
    ↓
View (UI 화면 - 위젯만 담당)
```

특징:

- **Binding**: 페이지 진입 시 자동으로 Controller 주입
- **Controller**: Rx 변수로 상태 관리, 비즈니스 로직 처리
- **View**: UI 렌더링만 담당 (Controller 구독하여 자동 업데이트)

### 3. Repository 패턴

데이터 레이어와 비즈니스 로직을 분리하여 관리합니다.

구조:

```
Controller → Repository → Data (API)
                  ↓
                Model (Entity)
```

레이어 설명:

- **Data Layer** (`app/data/`): HTTP 통신만 담당, DTO 사용
- **Repository Layer** (`app/repositories/`): API 응답을 도메인 모델로 변환
- **Model Layer** (`app/models/`): 도메인 엔티티 (불변 객체)
- **Controller**: Repository만 의존, DTO를 직접 사용하지 않음

장점:

- API 통신 로직과 비즈니스 로직 분리
- 테스트 용이성 향상
- 코드 재사용성 증가

---

## 폴더 구조 상세

### `app/data/` - API 통신 레이어

HTTP 통신만 담당하는 클래스들을 포함합니다.

**규칙:**

- API 엔드포인트 호출만 수행
- DTO를 사용하여 서버 응답 파싱
- 예외 처리 및 에러 매핑

**예시:**

```dart
class AuthData {
  Future<ApiResponse<Map<String, dynamic>>> login(String username, String password) async {
    return await API.post<Map<String, dynamic>>(
      ApiPath.login,
      body: {'username': username, 'password': password},
    );
  }
}
```

### `app/data/dto/` - DTO (Data Transfer Object)

서버와의 통신에 사용되는 데이터 전송 객체입니다.

**규칙:**

- 서버 응답 구조와 일치
- `fromJson` 메서드 필수
- `toEntity()` 메서드로 도메인 모델로 변환 가능

**예시:**

```dart
class LoginResponseDto {
  final String accessToken;
  final Map<String, dynamic> userJson;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: json['access_token'] as String,
      userJson: json['user'] as Map<String, dynamic>,
    );
  }

  User toEntity() {
    return User.fromJson(userJson);
  }
}
```

### `app/models/` - 도메인 모델 (Entity)

앱 내부에서 사용하는 불변 도메인 모델입니다.

**규칙:**

- 불변 객체 (immutable)
- 비즈니스 로직 포함 가능
- `fromJson`, `toJson` 메서드 제공

**예시:**

```dart
class User {
  final String id;
  final String username;
  final String? email;

  const User({required this.id, required this.username, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
    );
  }
}
```

### `app/repositories/` - Repository 구현

API 통신 결과를 도메인 모델로 변환하는 레이어입니다.

**규칙:**

- Data 레이어를 호출하여 API 통신
- DTO를 도메인 모델로 변환
- 예외 처리 및 에러 메시지 변환

**예시:**

```dart
class AuthRepository {
  final AuthData _authData = AuthData();

  Future<String> login(String username, String password) async {
    final response = await _authData.login(username, password);

    if (!response.success) {
      throw Exception(response.error ?? '로그인에 실패했습니다');
    }

    final loginDto = LoginResponseDto.fromJson(response.data!);
    return loginDto.accessToken;
  }
}
```

### `app/pages/{feature}/` - 페이지별 코드

각 기능별로 분리된 페이지 코드입니다.

**구조:**

```
pages/{feature}/
├── controllers/    # GetX Controller
├── views/          # UI 화면
├── bindings/       # GetX Binding
└── widgets/        # 페이지 전용 위젯 (선택적)
```

### `app/services/` - 전역 서비스

앱 전체에서 사용하는 서비스를 포함합니다.

**예시:**

- `AuthService`: 인증 상태 관리

### `app/utils/` - 유틸리티

공통으로 사용하는 유틸리티 함수/클래스입니다.

- `api.dart`: HTTP 통신 유틸리티
- `secure_storage.dart`: 보안 저장소
- `permission_service.dart`: 권한 관리

### `app/routes/` - 라우팅 설정

GetX 라우팅 시스템 설정입니다.

- `app_routes.dart`: 라우트 경로 상수 정의
- `app_pages.dart`: 페이지 바인딩 정의

### `app/theme/` - 테마 설정

앱 전체 테마 설정을 포함합니다.

---

## 개발 가이드라인

### 새로운 페이지 추가 시

1. **폴더 구조 생성**

   ```
   pages/{page_name}/
   ├── controllers/
   │   └── {page_name}_controller.dart
   ├── views/
   │   └── {page_name}_view.dart
   └── bindings/
       └── {page_name}_binding.dart
   ```

2. **Controller 생성**

   ```dart
   class FeatureNameController extends GetxController {
     final SomeRepository _repository = SomeRepository();
     final RxBool isLoading = false.obs;

     Future<void> loadData() async {
       isLoading.value = true;
       try {
         // Repository 호출
         final data = await _repository.getData();
         // 상태 업데이트
       } catch (e) {
         Get.snackbar('오류', e.toString());
       } finally {
         isLoading.value = false;
       }
     }

     @override
     void onClose() {
       // 리소스 정리
       super.onClose();
     }
   }
   ```

3. **View 생성**

   ```dart
   class FeatureNameView extends GetView<FeatureNameController> {
     const FeatureNameView({super.key});

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text('Feature Name')),
         body: Obx(() => controller.isLoading.value
           ? const CircularProgressIndicator()
           : const Text('Content'),
         ),
       );
     }
   }
   ```

4. **Binding 생성**

   ```dart
   class PageNameBinding extends Bindings {
     @override
     void dependencies() {
       Get.lazyPut(() => PageNameController());
     }
   }
   ```

5. **라우팅 추가**
   - `app_routes.dart`에 경로 상수 추가
   - `app_pages.dart`에 페이지 바인딩 추가

### Repository 패턴 사용 시

1. **Data 레이어 생성** (`app/data/{feature}_data.dart`)

   ```dart
   class FeatureData {
     Future<ApiResponse<Map<String, dynamic>>> getData() async {
       return await API.get<Map<String, dynamic>>(ApiPath.feature);
     }
   }
   ```

2. **DTO 생성** (`app/data/dto/{feature}_dto.dart`)

   ```dart
   class FeatureResponseDto {
     final String id;
     final String name;

     factory FeatureResponseDto.fromJson(Map<String, dynamic> json) {
       return FeatureResponseDto(
         id: json['id'] as String,
         name: json['name'] as String,
       );
     }

     Feature toEntity() {
       return Feature(id: id, name: name);
     }
   }
   ```

3. **Model 생성** (`app/models/{feature}.dart`)

   ```dart
   class Feature {
     final String id;
     final String name;

     const Feature({required this.id, required this.name});

     factory Feature.fromJson(Map<String, dynamic> json) {
       return Feature(
         id: json['id'] as String,
         name: json['name'] as String,
       );
     }
   }
   ```

4. **Repository 생성** (`app/repositories/{feature}_repository.dart`)

   ```dart
   class FeatureRepository {
     final FeatureData _featureData = FeatureData();

     Future<Feature> getData() async {
       final response = await _featureData.getData();
       if (!response.success) {
         throw Exception(response.error ?? '데이터를 불러오는데 실패했습니다');
       }
       final dto = FeatureResponseDto.fromJson(response.data!);
       return dto.toEntity();
     }
   }
   ```

5. **Controller에서 Repository 사용**

   ```dart
   class FeatureController extends GetxController {
     final FeatureRepository _repository = FeatureRepository();
     final Rx<Feature?> feature = Rx<Feature?>(null);

     Future<void> loadFeature() async {
       try {
         feature.value = await _repository.getData();
       } catch (e) {
         Get.snackbar('오류', e.toString());
       }
     }
   }
   ```

---

## 라우팅 시스템

### 라우트 경로 정의 (`app/routes/app_routes.dart`)

```dart
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const splash = _Paths.splash;
  static const home = _Paths.home;
  static const login = _Paths.login;
  // NAEILMAKE: route-constants
}

abstract class _Paths {
  _Paths._();
  static const splash = '/splash';
  static const home = '/home';
  static const login = '/login';
  // NAEILMAKE: path-constants
}
```

### 페이지 바인딩 정의 (`app/routes/app_pages.dart`)

```dart
class AppPages {
  AppPages._();

  static final routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage<dynamic>(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    // NAEILMAKE: routes
  ];
}
```

### 라우팅 사용법

```dart
// 페이지 이동
Get.toNamed(Routes.home);

// 인자 전달
Get.toNamed(Routes.detail, arguments: {'id': 123});

// 이전 페이지로 돌아가기
Get.back();

// 모든 페이지 스택 제거 후 이동
Get.offAllNamed(Routes.login);
```

---

## API 통신 패턴

### API 유틸리티 사용 (`app/utils/api.dart`)

```dart
// GET 요청
final response = await API.get<Map<String, dynamic>>(ApiPath.feature);
if (response.success) {
  final data = response.data;
} else {
  final error = response.error;
}

// POST 요청
final response = await API.post<Map<String, dynamic>>(
  ApiPath.feature,
  body: {'key': 'value'},
);

// PUT 요청
final response = await API.put<Map<String, dynamic>>(
  ApiPath.feature,
  body: {'key': 'value'},
);

// DELETE 요청
final response = await API.delete<void>(ApiPath.feature);
```

### API 경로 정의 (`app/utils/api.dart`)

```dart
class ApiPath {
  static const String baseUrl = 'http://localhost:3000';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
}
```

### 자동 인증 헤더

`API` 클래스는 자동으로 `AuthService`에서 토큰을 가져와 `Authorization` 헤더에 추가합니다.

```dart
// 자동으로 Authorization: Bearer {token} 헤더 포함
final response = await API.get<Map<String, dynamic>>(ApiPath.me);
```

---

## 상태 관리 (GetX)

### Rx 변수 사용

```dart
class MyController extends GetxController {
  // 기본 타입
  final RxBool isLoading = false.obs;
  final RxInt count = 0.obs;
  final RxString name = ''.obs;

  // 객체
  final Rx<User?> user = Rx<User?>(null);
  final RxList<String> items = <String>[].obs;
}
```

### 상태 업데이트

```dart
// 값 변경
isLoading.value = true;
count.value = 10;
user.value = User(id: '1', username: 'test');

// 리스트 조작
items.add('new item');
items.removeAt(0);
items.clear();
```

### UI에서 구독

```dart
// Obx 사용 (자동 구독)
Obx(() => Text(controller.name.value))

// GetBuilder 사용 (수동 업데이트)
GetBuilder<MyController>(
  builder: (controller) => Text(controller.name.value),
)

// GetX 사용
GetX<MyController>(
  builder: (controller) => Text(controller.name.value),
)
```

### Controller 접근

```dart
// GetView 사용 (자동 접근)
class MyView extends GetView<MyController> {
  @override
  Widget build(BuildContext context) {
    return Text(controller.name.value);
  }
}

// Get.find 사용
final controller = Get.find<MyController>();

// Get.put 사용 (없으면 생성)
final controller = Get.put(MyController());
```

---

## 인증 플로우

### AuthService

전역 인증 상태를 관리하는 서비스입니다.

```dart
// 인증 상태 확인
if (AuthService.to.isAuthenticated) {
  // 로그인된 상태
}

// 현재 사용자 정보
final user = AuthService.to.user.value;

// 액세스 토큰
final token = AuthService.to.accessToken;
```

### 로그인 플로우

1. **Controller에서 로그인 요청**

   ```dart
   final token = await _authRepository.login(username, password);
   await AuthService.to.login(token, user);
   Get.offAllNamed(Routes.home);
   ```

2. **AuthService에서 토큰 저장**

   ```dart
   await LocalStorage.instance.setData(LocalStorage.accessTokenKey, token);
   accessToken = token;
   user.value = userData;
   authState.value = AuthState.authenticated;
   ```

3. **API 호출 시 자동 토큰 포함**
   - `API` 클래스가 자동으로 `Authorization` 헤더에 토큰 추가

### 로그아웃 플로우

```dart
await AuthService.to.logout();
Get.offAllNamed(Routes.login);
```

### SecureStorage (플랫폼별 저장소)

토큰을 안전하게 저장하는 유틸리티입니다. 플랫폼에 따라 자동으로 적절한 저장소를 사용합니다.

- **모바일**: `FlutterSecureStorage` 사용 (안전한 저장소)
- **웹**: 쿠키 기반 저장소 사용 (HTTP 쿠키)

```dart
// 저장
await LocalStorage.instance.setData(LocalStorage.accessTokenKey, token);

// 읽기
final token = await LocalStorage.instance.getData(LocalStorage.accessTokenKey);

// 삭제
await LocalStorage.instance.removeData(LocalStorage.accessTokenKey);

// 전체 삭제
await LocalStorage.instance.clear();
```

#### 플랫폼별 저장소 구조

```
lib/
├── app/
│   └── utils/
│       ├── storage_interface.dart      # 저장소 인터페이스
│       ├── secure_storage.dart         # 플랫폼별 저장소 래퍼
│       ├── mobile_storage_adapter.dart # 모바일 저장소 (FlutterSecureStorage)
│       └── web_storage_stub.dart       # 모바일 빌드용 스텁
└── web/
    └── utils/
        ├── cookie_storage.dart          # 웹 쿠키 저장소 구현
        └── web_storage_adapter.dart     # 웹 저장소 어댑터
```

#### 웹 쿠키 저장소 특징

- **자동 플랫폼 감지**: `kIsWeb`으로 플랫폼 자동 감지
- **조건부 import**: 웹/모바일 빌드에 따라 적절한 구현 사용
- **쿠키 설정**: 기본 7일 만료, SameSite=Lax 보안 설정
- **동일한 인터페이스**: 모바일과 웹에서 동일한 API 사용

---

## 반응형 UI (ScreenUtil)

이 프로젝트는 `flutter_screenutil`을 사용하여 반응형 UI를 구현합니다. 모든 크기 값을 ScreenUtil 확장 기능으로 설정해야 합니다.

### ScreenUtil 확장 기능

- **`.w`**: 너비 (width)
- **`.h`**: 높이 (height)
- **`.sp`**: 폰트 크기 (fontSize)
- **`.r`**: 반지름 (radius)
- **`.sw`**: 화면 너비 비율 (screen width)
- **`.sh`**: 화면 높이 비율 (screen height)

### 사용 예시

```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Padding
Padding(
  padding: EdgeInsets.all(24.w),
  child: Text('내용'),
)

// SizedBox
SizedBox(
  width: 100.w,
  height: 50.h,
  child: ElevatedButton(...),
)

// 폰트 크기
Text(
  '제목',
  style: TextStyle(fontSize: 28.sp),
)

// BorderRadius
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8.r),
  ),
)
```

### 디자인 사이즈

- **모바일**: 390x844 (일반적인 iPhone 화면)
- **웹**: 1920x1080 (웹 기본 해상도)

### 주의사항

- **const 제거**: ScreenUtil 확장 기능은 const와 함께 사용할 수 없습니다
- **일관성 유지**: 모든 크기 값은 ScreenUtil 확장 기능을 사용해야 합니다
- **고정값 금지**: `24.0`, `50` 같은 고정값 대신 `24.w`, `50.h` 사용

### 잘못된 사용 예시

```dart
// ❌ 잘못된 사용
const Padding(
  padding: EdgeInsets.all(24.0),
  child: Text('내용', style: TextStyle(fontSize: 16)),
)

// ✅ 올바른 사용
Padding(
  padding: EdgeInsets.all(24.w),
  child: Text('내용', style: TextStyle(fontSize: 16.sp)),
)
```

---

## 코드 작성 규칙

### 네이밍 규칙

- **파일명**: snake_case (예: `login_controller.dart`)
- **클래스명**: PascalCase (예: `LoginController`)
- **변수/함수명**: camelCase (예: `isLoading`, `loadData`)
- **상수**: camelCase with `static const` (예: `static const String baseUrl = '...'`)

### 파일 구조 규칙

- **Controller**: `{feature}_controller.dart`
- **View**: `{feature}_view.dart`
- **Binding**: `{feature}_binding.dart`
- **Repository**: `{feature}_repository.dart`
- **Data**: `{feature}_data.dart`
- **DTO**: `{feature}_dto.dart`
- **Model**: `{feature}.dart` 또는 `{feature}_model.dart`

### 의존성 규칙

- **Controller → Repository**: 허용
- **Controller → Data**: 금지 (Repository를 통해 접근)
- **Controller → DTO**: 금지 (Model 사용)
- **Repository → Data**: 허용
- **Repository → DTO**: 허용 (변환용)
- **Repository → Model**: 허용

### 주석 작성 규칙

- **클래스**: 클래스의 역할과 책임 설명
- **메서드**: 파라미터, 반환값, 예외 설명
- **복잡한 로직**: 주석으로 의도 설명

```dart
/// 로그인을 수행합니다
///
/// [username] 사용자 이름
/// [password] 비밀번호
///
/// Returns: 액세스 토큰
/// Throws: Exception - 로그인 실패 시
Future<String> login(String username, String password) async {
  // ...
}
```

### 에러 처리 규칙

- **Repository**: 예외를 던짐 (Exception)
- **Controller**: 예외를 catch하여 사용자에게 표시
- **API**: ApiResponse로 성공/실패 반환

```dart
// Repository
if (!response.success) {
  throw Exception(response.error ?? '요청에 실패했습니다');
}

// Controller
try {
  final data = await _repository.getData();
} catch (e) {
  Get.snackbar('오류', e.toString().replaceAll('Exception: ', ''));
}
```

---

## 플랫폼 분리 및 부트스트랩

이 프로젝트는 모바일과 웹을 분리된 부트스트랩으로 관리합니다. `main.dart`에서 플랫폼을 자동으로 감지하여 적절한 부트스트랩을 로드합니다.

### 부트스트랩 구조

```
lib/
├── main/
│   └── bootstrap_mobile.dart    # 모바일 앱 초기화
└── web/
    ├── bootstrap_web.dart       # 웹 앱 초기화
    └── web_app.dart             # 웹 전용 앱 위젯
```

### 플랫폼 자동 분기

`main.dart`는 조건부 import를 사용하여 플랫폼을 자동으로 감지합니다:

```dart
import 'package:naeil_flutter_init/main/bootstrap_mobile.dart'
    if (dart.library.html) 'package:naeil_flutter_init/web/bootstrap_web.dart'
    as app;

@pragma('vm:entry-point')
void main() {
  app.bootstrap();
}
```

- **모바일**: `dart.library.html`이 없으면 `lib/main/bootstrap_mobile.dart` 로드
- **웹**: `dart.library.html`이 있으면 `lib/web/bootstrap_web.dart` 로드

### 모바일 부트스트랩 (`bootstrap_mobile.dart`)

모바일 전용 설정을 포함합니다:

- **SystemChrome 설정**: 상태바 스타일 설정
- **ScreenUtil**: 디자인 사이즈 390x844 (일반적인 모바일 화면)
- **SafeArea**: 노치 및 상태바 영역 고려
- **MediaQuery**: 텍스트 스케일링 고정

```dart
@pragma('vm:entry-point')
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // AuthService 초기화
  Get.put(AuthService(), permanent: true);
  await AuthService.to.init();

  runApp(const MobileApp());
}
```

### 웹 부트스트랩 (`lib/web/bootstrap_web.dart`)

웹 전용 설정을 포함합니다:

- **위치**: `lib/web/` 폴더에 웹 전용 파일 분리
- **ScreenUtil**: 디자인 사이즈 1920x1080 (웹 기본 해상도)
- **MediaQuery**: 텍스트 스케일링 고정
- **SafeArea 제외**: 웹에서는 불필요
- **SystemChrome 제외**: 웹에서는 불필요

```dart
@pragma('vm:entry-point')
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AuthService 초기화
  Get.put(AuthService(), permanent: true);
  await AuthService.to.init();

  runApp(const WebApp());
}
```

### 웹 앱 위젯 (`lib/web/web_app.dart`)

웹 전용 앱 위젯으로 분리되어 있습니다:

- **위치**: `lib/web/web_app.dart`
- **역할**: 웹 전용 GetMaterialApp 설정
- **설정**: ScreenUtil, 테마, 라우팅 등 웹 전용 설정 포함
- **페이지 공유**: `lib/app/pages/`의 모든 페이지와 로직을 모바일과 동일하게 사용

### 웹 쿠키 저장소

웹에서는 쿠키를 사용하여 토큰을 관리합니다:

- **쿠키 저장소**: `lib/web/utils/cookie_storage.dart`
- **저장소 어댑터**: `lib/web/utils/web_storage_adapter.dart`
- **자동 플랫폼 감지**: 모바일은 SecureStorage, 웹은 쿠키 자동 사용
- **동일한 API**: `LocalStorage.instance`를 사용하여 플랫폼에 관계없이 동일한 코드 사용

```dart
// 웹에서도 모바일과 동일한 코드 사용
await LocalStorage.instance.setData(LocalStorage.accessTokenKey, token);
// 웹에서는 쿠키로 저장, 모바일에서는 SecureStorage로 저장
```

### 플랫폼별 차이점

| 기능                     | 모바일               | 웹                      |
| ------------------------ | -------------------- | ----------------------- |
| SystemChrome             | ✅ 사용              | ❌ 불필요               |
| SafeArea                 | ✅ 사용              | ❌ 불필요               |
| ScreenUtil 디자인 사이즈 | 390x844              | 1920x1080               |
| MediaQuery               | ✅ 사용              | ✅ 사용                 |
| 토큰 저장소              | FlutterSecureStorage | 쿠키 (CookieStorage)    |
| 페이지/로직              | `lib/app/pages/`     | `lib/app/pages/` (공유) |

### 공통 설정

두 부트스트랩 모두 다음을 공유합니다:

- **AuthService 초기화**: 인증 서비스 초기화 및 주입
- **GetMaterialApp**: GetX 라우팅 및 상태 관리
- **CustomTheme**: 앱 테마 설정
- **AppPages**: 라우팅 설정
- **ScreenUtilInit**: 반응형 UI 설정

### 웹 실행 방법

```bash
# 웹 실행
flutter run -d chrome

# 웹 빌드
flutter build web
```

### 모바일 실행 방법

```bash
# iOS 실행
flutter run -d ios

# Android 실행
flutter run -d android

# 모바일 빌드
flutter build ios
flutter build apk
```

### 플랫폼별 코드 분리 (선택사항)

특정 플랫폼에서만 필요한 기능이 있다면:

```dart
// 플랫폼별 코드 분리
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // 웹 전용 코드
} else {
  // 모바일 전용 코드
}
```

또는:

```dart
import 'package:naeil_flutter_init/utils/mobile_utils.dart'
    if (dart.library.html) 'package:naeil_flutter_init/utils/web_utils.dart'
    as platform_utils;

platform_utils.doSomething(); // 플랫폼에 따라 다른 구현
```

---

## 주요 의존성

- **get**: ^4.7.2 - 상태 관리, 라우팅, 의존성 주입
- **flutter_screenutil**: ^5.9.0 - 반응형 UI
- **flutter_secure_storage**: ^9.2.2 - 보안 저장소
- **permission_handler**: ^11.3.1 - 권한 관리
- **http**: ^1.2.0 - HTTP 통신

---

## 추가 참고사항

- 프로젝트 구조는 Feature-based를 우선하되, 공통 기능은 `app/services/`, `app/utils/`에 배치
- 새로운 기능 추가 시 Repository 패턴을 우선적으로 적용
- DTO는 Data 레이어에만 노출하고, Controller는 Model만 사용
- 테스트 코드 작성 시 Repository 패턴이 테스트 용이성을 높임
- 페이지 생성때 `naeilcli make page이름 --app` 을 사용하면 편합니다.

---

## 라이선스

이 프로젝트는 템플릿 프로젝트입니다.
