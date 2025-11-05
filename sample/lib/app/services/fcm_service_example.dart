/// FCM 서비스 사용 예시
/// 
/// 이 파일은 참고용 예시 코드입니다.
/// 실제 사용 시에는 필요한 부분만 적용하세요.

// import 'package:get/get.dart';
// import 'package:naeil_flutter_init/app/services/fcm_service.dart';
// import 'package:naeil_flutter_init/app/routes/app_pages.dart';

/// 예시 1: bootstrap_mobile.dart에서 초기화
///
/// ```dart
/// import 'package:firebase_core/firebase_core.dart';
/// import 'package:naeil_flutter_init/app/services/fcm_service.dart';
/// import 'package:firebase_messaging/firebase_messaging.dart';
///
/// @pragma('vm:entry-point')
/// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
///   await Firebase.initializeApp();
///   // 백그라운드 메시지 처리
/// }
///
/// @pragma('vm:entry-point')
/// Future<void> bootstrap() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Firebase 초기화
///   await Firebase.initializeApp();
///
///   // 백그라운드 메시지 핸들러 등록
///   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
///
///   // FCM 서비스 초기화
///   Get.put(FcmService(), permanent: true);
///   await FcmService.to.init();
///
///   runApp(const _MobileApp());
/// }
/// ```

/// 예시 2: 로그인 후 토큰 서버 전송
///
/// ```dart
/// class LoginController extends GetxController {
///   Future<void> login() async {
///     try {
///       // 로그인 처리...
///       final token = await _authRepository.login(username, password);
///       await AuthService.to.login(token, user);
///
///       // FCM 토큰 가져오기 및 서버 전송
///       final fcmToken = await FcmService.to.getToken();
///       if (fcmToken.isNotEmpty) {
///         await FcmService.to.sendTokenToServer(fcmToken);
///       }
///
///       Get.offAllNamed(Routes.home);
///     } catch (e) {
///       Get.snackbar('오류', e.toString());
///     }
///   }
/// }
/// ```

/// 예시 3: 로그아웃 시 토큰 삭제
///
/// ```dart
/// class MyPageController extends GetxController {
///   Future<void> logout() async {
///     try {
///       // 로그아웃 처리...
///       await AuthService.to.logout();
///
///       // FCM 토큰 삭제
///       await FcmService.to.deleteToken();
///
///       Get.offAllNamed(Routes.login);
///     } catch (e) {
///       Get.snackbar('오류', e.toString());
///     }
///   }
/// }
/// ```

/// 예시 4: 토큰 상태 확인 및 UI에 표시
///
/// ```dart
/// class SettingsView extends GetView<SettingsController> {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: const Text('설정')),
///       body: Column(
///         children: [
///           // FCM 토큰 상태 표시
///           Obx(() => ListTile(
///             title: const Text('FCM 토큰'),
///             subtitle: Text(
///               FcmService.to.fcmToken.value.isEmpty
///                 ? '토큰 없음'
///                 : FcmService.to.fcmToken.value,
///             ),
///             trailing: FcmService.to.isInitialized.value
///               ? const Icon(Icons.check_circle, color: Colors.green)
///               : const Icon(Icons.error, color: Colors.red),
///           )),
///
///           // 알림 권한 상태 표시
///           Obx(() => ListTile(
///             title: const Text('알림 권한'),
///             subtitle: Text(
///               FcmService.to.hasPermission.value
///                 ? '허용됨'
///                 : '거부됨',
///             ),
///           )),
///
///           // 토큰 새로고침 버튼
///           ElevatedButton(
///             onPressed: () async {
///               await FcmService.to.refreshToken();
///               Get.snackbar('완료', 'FCM 토큰을 새로고침했습니다.');
///             },
///             child: const Text('토큰 새로고침'),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```

/// 예시 5: 백엔드 API에 토큰 전송 (Repository 패턴)
///
/// ```dart
/// // app/data/fcm_data.dart
/// class FcmData {
///   Future<ApiResponse<void>> sendToken(String token) async {
///     return await API.post(
///       ApiPath.fcmToken,
///       body: {'fcm_token': token},
///     );
///   }
/// }
///
/// // app/repositories/fcm_repository.dart
/// class FcmRepository {
///   final FcmData _fcmData = FcmData();
///
///   Future<void> sendToken(String token) async {
///     final response = await _fcmData.sendToken(token);
///     if (!response.success) {
///       throw Exception(response.error ?? '토큰 전송에 실패했습니다');
///     }
///   }
/// }
///
/// // FcmService에서 사용
/// Future<void> sendTokenToServer(String token) async {
///   try {
///     final repository = FcmRepository();
///     await repository.sendToken(token);
///     developer.log('FCM 토큰 서버 전송 성공');
///   } catch (e) {
///     developer.log('FCM 토큰 서버 전송 실패: $e');
///   }
/// }
/// ```

/// 예시 6: 특정 페이지에서 토큰 확인
///
/// ```dart
/// class HomeController extends GetxController {
///   @override
///   void onInit() {
///     super.onInit();
///     _checkFcmToken();
///   }
///
///   Future<void> _checkFcmToken() async {
///     if (FcmService.to.fcmToken.value.isEmpty) {
///       // 토큰이 없으면 새로 가져오기
///       await FcmService.to.refreshToken();
///     }
///
///     final token = FcmService.to.fcmToken.value;
///     if (token.isNotEmpty) {
///       developer.log('현재 FCM 토큰: $token');
///     }
///   }
/// }
/// ```

