# FCM 서비스 사용 가이드

Firebase Cloud Messaging (FCM)을 사용한 푸시 알림 서비스입니다.

## 📋 목차

- [필수 설정](#필수-설정)
- [초기화](#초기화)
- [기본 사용법](#기본-사용법)
- [고급 기능](#고급-기능)
- [문제 해결](#문제-해결)

---

## 필수 설정

### 1. 패키지 설치

`pubspec.yaml`에 다음 패키지를 추가합니다:

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_messaging: ^15.0.0
  flutter_local_notifications: ^17.0.0 # 로컬 알림 표시용 (선택)
```

그리고 `flutter pub get` 실행:

```bash
flutter pub get
```

### 2. Firebase 프로젝트 설정

1. [Firebase Console](https://console.firebase.google.com/)에서 프로젝트 생성
2. Android 앱 추가:
   - 패키지 이름 입력 (예: `com.example.app`)
   - `google-services.json` 파일 다운로드
   - `android/app/google-services.json`에 파일 복사
3. iOS 앱 추가:
   - 번들 ID 입력 (예: `com.example.app`)
   - `GoogleService-Info.plist` 파일 다운로드
   - `ios/Runner/GoogleService-Info.plist`에 파일 복사

### 3. Android 설정

#### `android/app/build.gradle` 수정:

```gradle
// buildscript 아래에 추가
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

// 파일 맨 아래에 추가
apply plugin: 'com.google.gms.google-services'
```

#### `android/build.gradle` 수정:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### `android/app/src/main/AndroidManifest.xml` 수정:

```xml
<manifest>
    <!-- 권한 추가 -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <application>
        <!-- 기존 코드 -->
    </application>
</manifest>
```

### 4. iOS 설정

#### APNS 인증 키 설정 (필수)

1. **Apple Developer Console에서 APNS 인증 키 생성:**

   - [Apple Developer Console](https://developer.apple.com/account/resources/authkeys/list) 접속
   - "Keys" 메뉴에서 "+" 버튼 클릭하여 새 키 생성
   - Key Name 입력 (예: "FCM Push Notification Key")
   - "Apple Push Notifications service (APNs)" 체크
   - "Continue" 클릭 후 "Register"
   - 생성된 키를 다운로드 (`.p8` 파일) - **한 번만 다운로드 가능하므로 안전하게 보관**
   - Key ID 기록

2. **Firebase Console에 APNS 인증 키 업로드:**

   - Firebase Console → 프로젝트 설정 → Cloud Messaging 탭
   - "Apple app configuration" 섹션에서 "Upload" 버튼 클릭
   - 다운로드한 `.p8` 파일 업로드
   - Key ID 입력
   - Team ID 입력 (Apple Developer 계정의 Team ID)

   **또는 APNs 인증서 방식:**

   - Firebase Console → 프로젝트 설정 → Cloud Messaging 탭
   - "Apple app configuration" 섹션
   - `.p12` 인증서 파일 업로드 (인증서 비밀번호 필요)

#### `ios/Runner/Info.plist` 수정:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

#### Firebase 초기화 확인:

`ios/Runner/AppDelegate.swift`에서 Firebase 초기화가 되어 있는지 확인:

```swift
import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### Capabilities 설정 (Xcode에서):

1. Xcode에서 프로젝트 열기
2. 프로젝트 타겟 선택 → "Signing & Capabilities" 탭
3. "+ Capability" 클릭
4. "Push Notifications" 추가

#### 프로비저닝 프로파일 확인:

- Xcode에서 자동 서명 활성화 또는 수동으로 Push Notification이 활성화된 프로비저닝 프로파일 사용

---

## 초기화

### 1. main.dart에서 Firebase 초기화

`lib/main/bootstrap_mobile.dart` 또는 `lib/main.dart`에서 Firebase를 초기화합니다:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:naeil_flutter_init/app/services/fcm_service.dart';

@pragma('vm:entry-point')
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // FCM 서비스 초기화 및 주입
  Get.put(FcmService(), permanent: true);
  await FcmService.to.init();

  // 나머지 초기화 코드...
  runApp(const _MobileApp());
}
```

### 2. 백그라운드 메시지 핸들러 설정

`lib/main.dart` 또는 `lib/main/bootstrap_mobile.dart`에 백그라운드 메시지 핸들러를 추가합니다:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log('백그라운드 메시지 수신: ${message.messageId}');
  developer.log('제목: ${message.notification?.title}');
  developer.log('내용: ${message.notification?.body}');
  developer.log('데이터: ${message.data}');

  // 필요한 경우 추가 처리
}

@pragma('vm:entry-point')
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // FCM 서비스 초기화
  Get.put(FcmService(), permanent: true);
  await FcmService.to.init();

  runApp(const _MobileApp());
}
```

---

## 기본 사용법

### 1. FCM 토큰 조회

```dart
// 토큰 가져오기
final token = await FcmService.to.getToken();
print('FCM 토큰: $token');

// 토큰이 이미 있는 경우
final currentToken = FcmService.to.fcmToken.value;
```

### 2. 토큰을 서버에 전송

로그인 후 사용자의 FCM 토큰을 서버에 전송합니다:

```dart
class LoginController extends GetxController {
  Future<void> login() async {
    // 로그인 처리...

    // FCM 토큰 가져오기 및 서버 전송
    final fcmToken = await FcmService.to.getToken();
    await FcmService.to.sendTokenToServer(fcmToken);
  }
}
```

### 3. 로그아웃 시 토큰 삭제

```dart
class MyPageController extends GetxController {
  Future<void> logout() async {
    // 로그아웃 처리...

    // FCM 토큰 삭제
    await FcmService.to.deleteToken();

    // 로그인 페이지로 이동
    Get.offAllNamed(Routes.login);
  }
}
```

### 4. 토큰 상태 확인

```dart
// 초기화 상태 확인
if (FcmService.to.isInitialized.value) {
  print('FCM 서비스가 초기화되었습니다');
}

// 권한 상태 확인
if (FcmService.to.hasPermission.value) {
  print('알림 권한이 허용되었습니다');
}
```

---

## 고급 기능

### 1. 포그라운드 메시지 처리

포그라운드에서 메시지를 받았을 때 처리하는 로직은 `fcm_service.dart`의 `_handleMessage` 메서드를 수정합니다:

```dart
void _handleMessage(RemoteMessage message) {
  // 특정 데이터가 있으면 특정 페이지로 이동
  if (message.data.containsKey('route')) {
    Get.toNamed(message.data['route']);
  }

  // 특정 타입에 따라 다른 처리
  if (message.data.containsKey('type')) {
    switch (message.data['type']) {
      case 'new_message':
        // 메시지 상태 업데이트
        break;
      case 'order_update':
        // 주문 상태 업데이트
        break;
    }
  }
}
```

### 2. 서버에 토큰 전송 구현

`fcm_service.dart`의 `sendTokenToServer` 메서드를 구현합니다:

```dart
Future<void> sendTokenToServer(String token) async {
  try {
    final response = await API.post(
      ApiPath.fcmToken,  // 백엔드 API 엔드포인트
      body: {'fcm_token': token},
    );

    if (response.success) {
      developer.log('FCM 토큰 서버 전송 성공');
    } else {
      developer.log('FCM 토큰 서버 전송 실패: ${response.error}');
    }
  } catch (e) {
    developer.log('FCM 토큰 서버 전송 중 오류: $e');
  }
}
```

### 3. 토큰 갱신 처리

토큰이 자동으로 갱신되면 서버에 새 토큰을 전송하도록 설정:

```dart
// _setupTokenRefreshListener 메서드 내부
_messaging.onTokenRefresh.listen((String newToken) async {
  developer.log('FCM 토큰 갱신: $newToken');
  fcmToken.value = newToken;

  // 서버에 새 토큰 전송
  await sendTokenToServer(newToken);
});
```

### 4. 로컬 알림 설정

로컬 알림을 표시하려면 `_showLocalNotification` 메서드를 구현합니다:

```dart
Future<void> _showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await _localNotifications.show(
    message.hashCode,
    message.notification?.title ?? '알림',
    message.notification?.body ?? '',
    notificationDetails,
  );
}
```

로컬 알림 초기화는 `init` 메서드에서 수행:

```dart
Future<void> init() async {
  // Android 초기화 설정
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await _localNotifications.initialize(initializationSettings);

  // 나머지 초기화...
}
```

---

## 문제 해결

### 1. 토큰을 가져올 수 없는 경우

- Firebase 프로젝트 설정이 올바른지 확인
- `google-services.json` (Android) 또는 `GoogleService-Info.plist` (iOS) 파일이 올바른 위치에 있는지 확인
- 앱을 완전히 재시작

### 2. 알림이 표시되지 않는 경우

- 알림 권한이 허용되었는지 확인
- Android: `AndroidManifest.xml`에 권한이 추가되었는지 확인
- iOS: `Info.plist`에 `UIBackgroundModes`가 추가되었는지 확인
- Firebase Console에서 테스트 메시지 전송 확인

### 3. 백그라운드 메시지를 받지 못하는 경우

- `FirebaseMessaging.onBackgroundMessage` 핸들러가 최상위 함수로 정의되었는지 확인
- `@pragma('vm:entry-point')` 어노테이션이 있는지 확인
- Firebase 초기화가 백그라운드 핸들러 내부에서 수행되는지 확인

### 4. 토큰이 자동으로 갱신되지 않는 경우

- 토큰 갱신 리스너가 올바르게 설정되었는지 확인
- 앱을 재설치하거나 데이터를 삭제한 경우 토큰이 변경될 수 있음

### 5. iOS에서 알림을 받지 못하는 경우

- **APNS 인증 키가 Firebase Console에 업로드되었는지 확인**
  - Firebase Console → 프로젝트 설정 → Cloud Messaging 탭
  - "Apple app configuration" 섹션에서 APNS 인증 키 또는 인증서가 업로드되어 있는지 확인
- **Capabilities 설정 확인:**
  - Xcode에서 "Signing & Capabilities" 탭
  - "Push Notifications" capability가 추가되어 있는지 확인
- **프로비저닝 프로파일 확인:**
  - Push Notification이 활성화된 프로비저닝 프로파일 사용 중인지 확인
  - Xcode에서 자동 서명을 사용하는 경우 자동으로 처리됨
- **실기기에서 테스트:**
  - iOS 시뮬레이터는 푸시 알림을 지원하지 않음
  - 반드시 실제 기기에서 테스트해야 함
- **알림 권한 확인:**
  - 설정 앱 → 알림 → 해당 앱에서 알림이 허용되어 있는지 확인

---

## 참고 자료

- [Firebase Cloud Messaging 공식 문서](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire 문서](https://firebase.flutter.dev/)
- [firebase_messaging 패키지](https://pub.dev/packages/firebase_messaging)
