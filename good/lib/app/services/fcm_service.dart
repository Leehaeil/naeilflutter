// 사용 전 필수 설정:
// 1. pubspec.yaml에 다음 패키지 추가:
//    dependencies:
//      firebase_core: ^3.0.0
//      firebase_messaging: ^15.0.0
//      flutter_local_notifications: ^17.0.0  # 로컬 알림 표시용 (선택)
//
// 2. Firebase 프로젝트 설정:
//    - Firebase Console에서 프로젝트 생성
//    - Android: google-services.json 파일을 android/app/에 추가
//    - iOS: GoogleService-Info.plist 파일을 ios/Runner/에 추가
//
// 3. main.dart에서 Firebase 초기화:
//    import 'package:firebase_core/firebase_core.dart';
//    await Firebase.initializeApp();
//
// 4. Android 권한 설정 (android/app/src/main/AndroidManifest.xml):
//    <uses-permission android:name="android.permission.INTERNET"/>
//    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
//
// 5. iOS 권한 설정 (ios/Runner/Info.plist):
//    <key>UIBackgroundModes</key>
//    <array>
//      <string>remote-notification</string>
//    </array>

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as developer;
import 'package:get/get.dart';

/// Firebase Cloud Messaging 서비스
/// GetXService를 사용하여 앱 전체에서 단일 인스턴스로 관리
///
/// 사용 방법:
/// 1. bootstrap_mobile.dart에서 초기화:
///    Get.put(FcmService(), permanent: true);
///    await FcmService.to.init();
///
/// 2. 토큰 조회:
///    final token = await FcmService.to.getToken();
///
/// 3. 토큰 삭제 (로그아웃 시):
///    await FcmService.to.deleteToken();
class FcmService extends GetxService {
  static FcmService get to => Get.find();

  // final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  // final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// FCM 토큰
  final RxString fcmToken = ''.obs;

  /// 토큰 초기화 상태
  final RxBool isInitialized = false.obs;

  /// 알림 권한 상태
  final RxBool hasPermission = false.obs;

  /// 초기화
  /// FCM 설정 및 토큰 요청
  Future<void> init() async {
    try {
      developer.log('FCM 서비스 초기화 시작');

      // TODO: Firebase 초기화 확인
      // if (!Firebase.apps.isNotEmpty) {
      //   throw Exception('Firebase가 초기화되지 않았습니다. Firebase.initializeApp()을 먼저 호출하세요.');
      // }

      // 알림 권한 요청
      await _requestPermission();

      // 토큰 가져오기
      await _getToken();

      // 포그라운드 메시지 핸들러 설정
      _setupForegroundMessageHandler();

      // 백그라운드 메시지 핸들러는 main.dart에서 설정 필요
      // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 토큰 갱신 리스너 설정
      _setupTokenRefreshListener();

      isInitialized.value = true;
      developer.log('FCM 서비스 초기화 완료');
    } catch (e, stackTrace) {
      developer.log('FCM 서비스 초기화 실패: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 알림 권한 요청
  Future<void> _requestPermission() async {
    try {
      // TODO: 실제 구현
      // final settings = await _messaging.requestPermission(
      //   alert: true,
      //   badge: true,
      //   sound: true,
      //   provisional: false,
      // );
      //
      // hasPermission.value = settings.authorizationStatus == AuthorizationStatus.authorized ||
      //     settings.authorizationStatus == AuthorizationStatus.provisional;
      //
      // if (!hasPermission.value) {
      //   developer.log('FCM 알림 권한이 거부되었습니다.');
      // }

      // 임시: 권한이 있다고 가정
      hasPermission.value = true;
      developer.log('FCM 알림 권한 확인 완료');
    } catch (e) {
      developer.log('FCM 알림 권한 요청 실패: $e');
      hasPermission.value = false;
    }
  }

  /// FCM 토큰 가져오기
  Future<void> _getToken() async {
    try {
      // TODO: 실제 구현
      // final token = await _messaging.getToken();
      // if (token != null) {
      //   fcmToken.value = token;
      //   developer.log('FCM 토큰 가져오기 성공: $token');
      //
      //   // 서버에 토큰 전송 (선택)
      //   // await _sendTokenToServer(token);
      // } else {
      //   developer.log('FCM 토큰을 가져올 수 없습니다.');
      // }

      // 임시: 더미 토큰
      fcmToken.value = 'dummy_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
      developer.log('FCM 토큰 가져오기 성공 (더미): ${fcmToken.value}');
    } catch (e) {
      developer.log('FCM 토큰 가져오기 실패: $e');
    }
  }

  /// FCM 토큰 조회
  /// Returns: FCM 토큰 문자열 (없으면 빈 문자열)
  Future<String> getToken() async {
    if (fcmToken.value.isEmpty) {
      await _getToken();
    }
    return fcmToken.value;
  }

  /// FCM 토큰 삭제 (로그아웃 시 사용)
  Future<void> deleteToken() async {
    try {
      // TODO: 실제 구현
      // await _messaging.deleteToken();
      fcmToken.value = '';
      developer.log('FCM 토큰 삭제 완료');
    } catch (e) {
      developer.log('FCM 토큰 삭제 실패: $e');
    }
  }

  /// 포그라운드 메시지 핸들러 설정
  void _setupForegroundMessageHandler() {
    // TODO: 실제 구현
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   developer.log('포그라운드 메시지 수신: ${message.messageId}');
    //   developer.log('제목: ${message.notification?.title}');
    //   developer.log('내용: ${message.notification?.body}');
    //   developer.log('데이터: ${message.data}');
    //
    //   // 로컬 알림 표시
    //   _showLocalNotification(message);
    //
    //   // 필요한 경우 상태 업데이트 또는 네비게이션 처리
    //   _handleMessage(message);
    // });
  }

  /// 토큰 갱신 리스너 설정
  void _setupTokenRefreshListener() {
    // TODO: 실제 구현
    // _messaging.onTokenRefresh.listen((String newToken) {
    //   developer.log('FCM 토큰 갱신: $newToken');
    //   fcmToken.value = newToken;
    //
    //   // 서버에 새 토큰 전송 (선택)
    //   // await _sendTokenToServer(newToken);
    // });
  }

  /// 로컬 알림 표시
  // ignore: unused_element
  Future<void> _showLocalNotification(/* RemoteMessage message */) async {
    // TODO: 실제 구현
    // const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    //   'high_importance_channel',
    //   'High Importance Notifications',
    //   channelDescription: 'This channel is used for important notifications.',
    //   importance: Importance.high,
    //   priority: Priority.high,
    // );
    //
    // const NotificationDetails notificationDetails = NotificationDetails(
    //   android: androidDetails,
    // );
    //
    // await _localNotifications.show(
    //   message.hashCode,
    //   message.notification?.title ?? '알림',
    //   message.notification?.body ?? '',
    //   notificationDetails,
    // );
  }

  /// 메시지 처리 (앱 내 상태 업데이트 또는 네비게이션)
  // ignore: unused_element
  void _handleMessage(/* RemoteMessage message */) {
    // TODO: 실제 구현
    // 예시: 특정 데이터가 있으면 특정 페이지로 이동
    // if (message.data.containsKey('route')) {
    //   Get.toNamed(message.data['route']);
    // }
    //
    // 예시: 특정 데이터로 상태 업데이트
    // if (message.data.containsKey('type')) {
    //   switch (message.data['type']) {
    //     case 'new_message':
    //       // 메시지 상태 업데이트
    //       break;
    //     case 'order_update':
    //       // 주문 상태 업데이트
    //       break;
    //   }
    // }
  }

  /// 서버에 토큰 전송 (선택적 구현)
  /// 실제 사용 시 백엔드 API 엔드포인트에 맞게 구현
  Future<void> sendTokenToServer(String token) async {
    // TODO: 실제 구현
    // try {
    //   final response = await API.post(
    //     ApiPath.fcmToken,
    //     body: {'fcm_token': token},
    //   );
    //
    //   if (response.success) {
    //     developer.log('FCM 토큰 서버 전송 성공');
    //   } else {
    //     developer.log('FCM 토큰 서버 전송 실패: ${response.error}');
    //   }
    // } catch (e) {
    //   developer.log('FCM 토큰 서버 전송 중 오류: $e');
    // }
  }

  /// 토큰 재요청
  Future<void> refreshToken() async {
    await _getToken();
  }
}

/// 백그라운드 메시지 핸들러
/// main.dart에서 최상위 함수로 정의 필요
/// @pragma('vm:entry-point')
/// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
///   await Firebase.initializeApp();
///   developer.log('백그라운드 메시지 수신: ${message.messageId}');
///   developer.log('제목: ${message.notification?.title}');
///   developer.log('내용: ${message.notification?.body}');
///   developer.log('데이터: ${message.data}');
/// }

