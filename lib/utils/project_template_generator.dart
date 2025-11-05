import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// 프로젝트 템플릿 생성 유틸리티
/// sample 폴더 없이 직접 파일을 생성합니다
class ProjectTemplateGenerator {
  final Logger logger = Logger();

  /// 프로젝트 구조 생성
  static Future<void> generateProject({
    required String targetPath,
    required String projectName,
    required String packageId,
    required List<String> platforms,
    required Logger logger,
  }) async {
    final generator = ProjectTemplateGenerator();
    final packageName = _packageIdToPackageName(packageId);
    final hasWeb = platforms.contains('web');

    try {
      // 1. pubspec.yaml 생성
      logger.detail('pubspec.yaml 생성 중...');
      await generator._createPubspec(targetPath, packageName, logger);

      // 2. lib/main.dart 생성
      logger.detail('lib/main.dart 생성 중...');
      await generator._createMainDart(targetPath, packageName, hasWeb, logger);

      // 3. lib/mobile 폴더 구조 생성
      logger.detail('lib/mobile 폴더 구조 생성 중...');
      await generator._createMobileStructure(targetPath, packageName, logger);

      // 4. lib/web 폴더 구조 생성 (web이 선택된 경우)
      if (hasWeb) {
        logger.detail('lib/web 폴더 구조 생성 중...');
        await generator._createWebStructure(targetPath, packageName, logger);
      }

      // 5. test 폴더 생성
      logger.detail('test 폴더 생성 중...');
      await generator._createTestStructure(targetPath, logger);

      logger.success('✅ 프로젝트 템플릿 생성 완료');
    } catch (e, stackTrace) {
      logger.err('❌ 프로젝트 템플릿 생성 중 오류 발생: $e');
      logger.detail('스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  /// pubspec.yaml 생성
  Future<void> _createPubspec(String targetPath, String packageName, Logger logger) async {
    final file = File(path.join(targetPath, 'pubspec.yaml'));
    final content = '''name: $packageName
description: "A new Flutter project."
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ^3.7.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  get: ^4.7.2
  flutter_screenutil: ^5.9.0
  flutter_secure_storage: ^9.2.2
  permission_handler: ^11.3.1
  http: ^1.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
''';
    await file.writeAsString(content);
  }

  /// lib/main.dart 생성
  Future<void> _createMainDart(
    String targetPath,
    String packageName,
    bool hasWeb,
    Logger logger,
  ) async {
    final file = File(path.join(targetPath, 'lib', 'main.dart'));
    await file.parent.create(recursive: true);

    String content;
    if (hasWeb) {
      content =
          '''import 'package:$packageName/mobile/bootstrap_mobile.dart'
    if (dart.library.html) 'package:$packageName/web/bootstrap_web.dart'
    as app;

@pragma('vm:entry-point')
void main() {
  app.bootstrap();
}
''';
    } else {
      content = '''import 'package:$packageName/mobile/bootstrap_mobile.dart' as app;

@pragma('vm:entry-point')
void main() {
  app.bootstrap();
}
''';
    }

    await file.writeAsString(content);
  }

  /// lib/mobile 폴더 구조 생성
  Future<void> _createMobileStructure(String targetPath, String packageName, Logger logger) async {
    // bootstrap
    await _createMobileBootstrap(targetPath, packageName);

    // routes
    await _createMobileRoutes(targetPath, packageName);
    await _createMobilePages(targetPath, packageName);

    // pages
    await _createMobileSplashPage(targetPath, packageName);
    await _createMobileLoginPage(targetPath, packageName);
    await _createMobileHomePage(targetPath, packageName);

    // services
    await _createMobileAuthService(targetPath, packageName);

    // repositories
    await _createMobileAuthRepository(targetPath, packageName);

    // data
    await _createMobileAuthData(targetPath, packageName);
    await _createMobileLoginDto(targetPath, packageName);

    // models
    await _createMobileAuthDataModel(targetPath, packageName);

    // utils
    await _createMobileApiUtil(targetPath, packageName);
    await _createMobileSecureStorage(targetPath, packageName);
    await _createMobileStorageInterface(targetPath, packageName);
    await _createMobileStorageAdapter(targetPath, packageName);
    await _createMobilePermissionService(targetPath, packageName);

    // theme
    await _createMobileCustomTheme(targetPath, packageName);
  }

  /// Mobile Bootstrap 생성
  Future<void> _createMobileBootstrap(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'bootstrap_mobile.dart'));
    await file.parent.create(recursive: true);

    final content =
        '''import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:$packageName/mobile/routes/app_pages.dart';
import 'package:$packageName/mobile/services/auth_service.dart';
import 'package:$packageName/mobile/theme/custom_theme.dart';

@pragma('vm:entry-point')
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // AuthService 초기화 및 주입
  Get.put(AuthService(), permanent: true);

  // 인증 상태 확인 (토큰 확인 및 사용자 정보 로드)
  await AuthService.to.init();

  runApp(const MobileApp());
}

class MobileApp extends StatelessWidget {
  const MobileApp();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: '$packageName',
          debugShowCheckedModeBanner: false,
          theme: CustomTheme.lightTheme,
          initialRoute: Routes.splash,
          getPages: AppPages.routes,
          builder: (context, child) {
            return Material(
              color: CustomTheme.lightTheme.scaffoldBackgroundColor,
              child: SafeArea(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child!,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
''';
    await file.writeAsString(content);
  }

  /// Mobile Routes 생성
  Future<void> _createMobileRoutes(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'routes', 'app_routes.dart'));
    await file.parent.create(recursive: true);

    final content = '''part of 'app_pages.dart';

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
''';
    await file.writeAsString(content);
  }

  /// Mobile Pages 생성
  Future<void> _createMobilePages(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'routes', 'app_pages.dart'));
    await file.parent.create(recursive: true);

    final content = '''import 'package:get/get.dart';

import '../pages/splash/bindings/splash_binding.dart';
import '../pages/splash/views/splash_view.dart';
import '../pages/home/bindings/home_binding.dart';
import '../pages/home/views/home_view.dart';
import '../pages/login/bindings/login_binding.dart';
import '../pages/login/views/login_view.dart';
// NAEILMAKE: import
part 'app_routes.dart';

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
    GetPage<dynamic>(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    // NAEILMAKE: routes
  ];
}
''';
    await file.writeAsString(content);
  }

  /// Mobile Splash Page 생성
  Future<void> _createMobileSplashPage(String targetPath, String packageName) async {
    // controller
    final controllerFile = File(
      path.join(
        targetPath,
        'lib',
        'mobile',
        'pages',
        'splash',
        'controllers',
        'splash_controller.dart',
      ),
    );
    await controllerFile.parent.create(recursive: true);
    final controllerContent =
        '''import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:$packageName/mobile/routes/app_pages.dart';
import 'package:$packageName/mobile/services/auth_service.dart';

/// 스플래시 페이지 컨트롤러
/// 앱 시작 시 인증 상태를 확인하고 적절한 페이지로 라우팅
class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkAuthAndNavigate();
  }

  /// 인증 상태 확인 및 페이지 이동
  Future<void> _checkAuthAndNavigate() async {
    try {
      // bootstrap에서 이미 AuthService.init()이 호출되었으므로
      // 여기서는 바로 인증 상태만 확인

      // 스플래시 화면 표시 시간 (최소 1초)
      await Future.delayed(const Duration(seconds: 1));

      // 로그인 상태에 따라 페이지 이동
      if (AuthService.to.isAuthenticated) {
        developer.log('인증 상태 확인: 로그인됨 → 홈으로 이동');
        Get.offAllNamed(Routes.home);
      } else {
        developer.log('인증 상태 확인: 로그인 안됨 → 로그인 페이지로 이동');
        Get.offAllNamed(Routes.login);
      }
    } catch (e, stackTrace) {
      developer.log('인증 상태 확인 중 오류 발생: \$e', error: e, stackTrace: stackTrace);
      // 에러 발생 시 로그인 페이지로 이동
      Get.offAllNamed(Routes.login);
    }
  }
}
''';
    await controllerFile.writeAsString(controllerContent);

    // view
    final viewFile = File(
      path.join(targetPath, 'lib', 'mobile', 'pages', 'splash', 'views', 'splash_view.dart'),
    );
    await viewFile.parent.create(recursive: true);
    final viewContent = '''import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SplashView'), centerTitle: true),
      body: Center(child: Text('SplashView 동작 중', style: TextStyle(fontSize: 20.sp))),
    );
  }
}
''';
    await viewFile.writeAsString(viewContent);

    // binding
    final bindingFile = File(
      path.join(targetPath, 'lib', 'mobile', 'pages', 'splash', 'bindings', 'splash_binding.dart'),
    );
    await bindingFile.parent.create(recursive: true);
    final bindingContent = '''import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}
''';
    await bindingFile.writeAsString(bindingContent);
  }

  /// Mobile Login Page 생성
  Future<void> _createMobileLoginPage(String targetPath, String packageName) async {
    // controller
    final controllerFile = File(
      path.join(
        targetPath,
        'lib',
        'mobile',
        'pages',
        'login',
        'controllers',
        'login_controller.dart',
      ),
    );
    await controllerFile.parent.create(recursive: true);
    final controllerContent =
        '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:$packageName/mobile/models/auth_data.dart';
import 'package:$packageName/mobile/repositories/auth_repository.dart';
import 'package:$packageName/mobile/routes/app_pages.dart';
import 'package:$packageName/mobile/services/auth_service.dart';

/// 로그인 페이지 컨트롤러
class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  /// 사용자 이름 입력 컨트롤러
  final TextEditingController usernameController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final TextEditingController passwordController = TextEditingController();

  /// 로딩 상태
  final RxBool isLoading = false.obs;

  /// 로그인 수행
  Future<void> login() async {
    // 중복 요청 방지
    if (isLoading.value) return;

    // 입력 검증
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar('오류', '사용자 이름을 입력해주세요.');
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      Get.snackbar('오류', '비밀번호를 입력해주세요.');
      return;
    }

    isLoading.value = true;

    try {
      // Repository를 통해 로그인 API 호출
      final token = await _authRepository.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      // TODO: 백엔드 API 연동 후 실제 사용자 정보 가져오기
      // 임시로 더미 사용자 정보 생성
      final user = User(
        id: '1',
        username: usernameController.text.trim(),
        email: '\${usernameController.text.trim()}@example.com',
      );

      // AuthService에 로그인 정보 저장
      await AuthService.to.login(token, user);

      // 로그인 성공 시 홈으로 이동
      Get.offAllNamed(Routes.home);
    } catch (e) {
      // 에러 메시지 표시
      Get.snackbar(
        '로그인 실패',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
''';
    await controllerFile.writeAsString(controllerContent);

    // view
    final viewFile = File(
      path.join(targetPath, 'lib', 'mobile', 'pages', 'login', 'views', 'login_view.dart'),
    );
    await viewFile.parent.create(recursive: true);
    final viewContent =
        '''import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:$packageName/mobile/pages/login/controllers/login_controller.dart';

/// 로그인 페이지 뷰
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 또는 타이틀 영역 (선택사항)
              Text(
                '환영합니다',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 48.h),

              // 사용자 이름 입력 필드
              TextField(
                controller: controller.usernameController,
                decoration: InputDecoration(
                  labelText: '사용자 이름',
                  hintText: '사용자 이름을 입력하세요',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16.h),

              // 비밀번호 입력 필드
              TextField(
                controller: controller.passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: '비밀번호를 입력하세요',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.login(),
              ),
              SizedBox(height: 32.h),

              // 로그인 버튼
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.login,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''';
    await viewFile.writeAsString(viewContent);

    // binding
    final bindingFile = File(
      path.join(targetPath, 'lib', 'mobile', 'pages', 'login', 'bindings', 'login_binding.dart'),
    );
    await bindingFile.parent.create(recursive: true);
    final bindingContent = '''import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginController());
  }
}
''';
    await bindingFile.writeAsString(bindingContent);
  }

  /// Mobile Home Page 생성
  Future<void> _createMobileHomePage(String targetPath, String packageName) async {
    // controller
    final controllerFile = File(
      path.join(
        targetPath,
        'lib',
        'mobile',
        'pages',
        'home',
        'controllers',
        'home_controller.dart',
      ),
    );
    await controllerFile.parent.create(recursive: true);
    final controllerContent = '''import 'package:get/get.dart';

class HomeController extends GetxController {
  // TODO: HomeController 구현
}
''';
    await controllerFile.writeAsString(controllerContent);

    // view
    final viewFile = File(
      path.join(targetPath, 'lib', 'mobile', 'pages', 'home', 'views', 'home_view.dart'),
    );
    await viewFile.parent.create(recursive: true);
    final viewContent = '''import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'HomeView 동작 중',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );
  }
}
''';
    await viewFile.writeAsString(viewContent);

    // binding
    final bindingFile = File(
      path.join(targetPath, 'lib', 'mobile', 'pages', 'home', 'bindings', 'home_binding.dart'),
    );
    await bindingFile.parent.create(recursive: true);
    final bindingContent = '''import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
  }
}
''';
    await bindingFile.writeAsString(bindingContent);
  }

  /// Mobile AuthService 생성
  Future<void> _createMobileAuthService(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'services', 'auth_service.dart'));
    await file.parent.create(recursive: true);

    final content =
        '''import 'package:get/get.dart';
import 'package:$packageName/mobile/models/auth_data.dart';
import 'package:$packageName/mobile/repositories/auth_repository.dart';
import 'package:$packageName/mobile/utils/secure_storage.dart';

/// 전역 인증 상태 관리 서비스
/// GetXService를 사용하여 앱 전체에서 단일 인스턴스로 관리
class AuthService extends GetxService {
  static AuthService get to => Get.find();

  /// 현재 로그인한 사용자
  final Rx<User?> user = Rx<User?>(null);

  /// 액세스 토큰
  String accessToken = '';

  /// 로그인 상태 (authenticated, unauthenticated, loading)
  final Rx<AuthState> authState = AuthState.loading.obs;

  /// 로그인 여부 (computed)
  bool get isAuthenticated => authState.value == AuthState.authenticated;

  /// 초기화: 앱 시작 시 토큰 확인 및 사용자 정보 로드
  Future<void> init() async {
    try {
      authState.value = AuthState.loading;

      // SecureStorage에서 토큰 확인
      final token = await LocalStorage.instance.getData(LocalStorage.accessTokenKey);

      if (token != null && token.isNotEmpty) {
        accessToken = token;
        // TODO: 백엔드 API 연동 후 사용자 정보 로드
        // await _loadCurrentUser();

        // 임시로 토큰만 확인하여 인증 상태 설정
        authState.value = AuthState.authenticated;
      } else {
        accessToken = '';
        user.value = null;
        authState.value = AuthState.unauthenticated;
      }
    } catch (e) {
      // 에러 발생 시 미인증 상태로 설정
      accessToken = '';
      user.value = null;
      authState.value = AuthState.unauthenticated;
    }
  }

  /// 현재 사용자 정보 로드
  /// TODO: 백엔드 API 연동 후 init() 메서드에서 호출 예정
  // ignore: unused_element
  Future<void> _loadCurrentUser() async {
    // TODO: 백엔드 API 연동
    // 실제 구현 예시:
    final repository = AuthRepository();
    final currentUser = await repository.getCurrentUser();
    if (currentUser != null) {
      user.value = currentUser;
      authState.value = AuthState.authenticated;
    } else {
      await logout();
    }
  }

  /// 로그인 처리
  ///
  /// [token] 액세스 토큰
  /// [userData] 사용자 정보
  Future<void> login(String token, User userData) async {
    try {
      // 토큰을 SecureStorage에 저장
      await LocalStorage.instance.setData(LocalStorage.accessTokenKey, token);

      // AuthService 상태 업데이트
      accessToken = token;
      user.value = userData;
      authState.value = AuthState.authenticated;
    } catch (e) {
      throw Exception('로그인 처리 중 오류가 발생했습니다: \$e');
    }
  }

  /// 로그아웃 처리
  Future<void> logout() async {
    try {
      // SecureStorage에서 토큰 삭제
      await LocalStorage.instance.removeData(LocalStorage.accessTokenKey);

      // AuthService 상태 초기화
      accessToken = '';
      user.value = null;
      authState.value = AuthState.unauthenticated;

      // TODO: 백엔드 API 연동
      // 실제 구현 예시:
      final repository = AuthRepository();
      await repository.logout();
    } catch (e) {
      // 에러가 발생해도 로컬 상태는 초기화
      accessToken = '';
      user.value = null;
      authState.value = AuthState.unauthenticated;
    }
  }

  /// 인증 상태 확인 및 갱신
  Future<void> checkAuthStatus() async {
    await init();
  }
}
''';
    await file.writeAsString(content);
  }

  /// Mobile AuthRepository 생성
  Future<void> _createMobileAuthRepository(String targetPath, String packageName) async {
    final file = File(
      path.join(targetPath, 'lib', 'mobile', 'repositories', 'auth_repository.dart'),
    );
    await file.parent.create(recursive: true);

    final content =
        '''import 'package:$packageName/mobile/data/auth_data.dart';
import 'package:$packageName/mobile/data/dto/login_dto.dart';
import 'package:$packageName/mobile/models/auth_data.dart';

/// 인증 관련 Repository
/// API 통신 결과를 페이지 목적에 맞게 가공하는 로직만 포함
class AuthRepository {
  final AuthData _authData = AuthData();

  /// 로그인을 수행합니다
  ///
  /// [username] 사용자 이름
  /// [password] 비밀번호
  ///
  /// Returns: 액세스 토큰
  /// Throws: Exception - 로그인 실패 시
  Future<String> login(String username, String password) async {
    final response = await _authData.login(username, password);

    if (!response.success) {
      throw Exception(response.error ?? '로그인에 실패했습니다');
    }

    final loginDto = LoginResponseDto.fromJson(response.data!);
    return loginDto.accessToken;
  }

  /// 로그아웃을 수행합니다
  Future<void> logout() async {
    final response = await _authData.logout();

    if (!response.success) {
      // 로그아웃 실패는 에러를 던지지 않고 무시 (로컬 상태는 초기화됨)
      return;
    }
  }

  /// 현재 로그인한 사용자 정보를 조회합니다
  ///
  /// Returns: 사용자 정보 (로그인되지 않은 경우 null)
  Future<User?> getCurrentUser() async {
    final response = await _authData.getCurrentUser();

    if (!response.success) {
      return null;
    }

    return User.fromJson(response.data!);
  }
}
''';
    await file.writeAsString(content);
  }

  /// Mobile AuthData 생성
  Future<void> _createMobileAuthData(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'data', 'auth_data.dart'));
    await file.parent.create(recursive: true);

    final content = '''import 'package:$packageName/mobile/utils/api.dart';

/// 인증 관련 API 통신만 담당하는 클래스
/// HTTP 통신 및 응답 반환만 수행
class AuthData {
  /// 로그인 API 호출
  ///
  /// [username] 사용자 이름
  /// [password] 비밀번호
  ///
  /// Returns: API 응답 데이터
  Future<ApiResponse<Map<String, dynamic>>> login(String username, String password) async {
    return await API.post<Map<String, dynamic>>(
      ApiPath.login,
      body: {
        'username': username,
        'password': password,
      },
    );
  }

  /// 로그아웃 API 호출
  ///
  /// Returns: API 응답
  Future<ApiResponse<void>> logout() async {
    return await API.post<void>(ApiPath.logout);
  }

  /// 현재 로그인한 사용자 정보 조회 API 호출
  ///
  /// Returns: API 응답 데이터
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    return await API.get<Map<String, dynamic>>(ApiPath.me);
  }
}
''';
    await file.writeAsString(content);
  }

  /// Mobile LoginDto 생성
  Future<void> _createMobileLoginDto(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'data', 'dto', 'login_dto.dart'));
    await file.parent.create(recursive: true);

    final content = '''import 'package:$packageName/mobile/models/auth_data.dart';

/// 로그인 API 응답 DTO
class LoginResponseDto {
  final String accessToken;
  final Map<String, dynamic> userJson;

  const LoginResponseDto({
    required this.accessToken,
    required this.userJson,
  });

  /// JSON에서 LoginResponseDto 생성
  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String,
      userJson: json['user'] as Map<String, dynamic>,
    );
  }

  /// User 엔티티로 변환
  User toEntity() {
    return User.fromJson(userJson);
  }
}
''';
    await file.writeAsString(content);
  }

  /// Mobile AuthDataModel 생성
  Future<void> _createMobileAuthDataModel(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'models', 'auth_data.dart'));
    await file.parent.create(recursive: true);

    final content = '''/// 인증 상태를 나타내는 enum
enum AuthState {
  /// 로그인된 상태
  authenticated,

  /// 로그인되지 않은 상태
  unauthenticated,

  /// 로딩 중 (인증 상태 확인 중)
  loading,
}

/// 사용자 엔티티
class User {
  final String id;
  final String username;
  final String? email;

  const User({required this.id, required this.username, this.email});

  /// JSON에서 User 객체 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
    );
  }

  /// User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, if (email != null) 'email': email};
  }
}

/// 로그인 요청 데이터
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({required this.username, required this.password});

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}
''';
    await file.writeAsString(content);
  }

  /// Mobile ApiUtil 생성
  Future<void> _createMobileApiUtil(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'utils', 'api.dart'));
    await file.parent.create(recursive: true);

    final content =
        '''import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:$packageName/mobile/services/auth_service.dart';

/// API 엔드포인트 경로 상수
class ApiPath {
  // TODO: 백엔드 API URL 설정
  static const String baseUrl = 'http://localhost:3000'; // 백엔드 URL로 변경 필요

  // TODO: 백엔드 API 엔드포인트 경로 정의
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
}

/// API 응답 래퍼 클래스
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResponse.success(this.data) : error = null, success = true;
  ApiResponse.error(this.error) : data = null, success = false;
}

/// HTTP 통신 유틸리티 클래스
class API {
  static final _client = http.Client();

  /// 기본 헤더 설정 (Authorization 토큰 자동 포함)
  static Map<String, String> _getHeaders({Map<String, String>? customHeaders}) {
    final headers = <String, String>{'Content-Type': 'application/json'};

    // AuthService에서 토큰을 가져와 Authorization 헤더에 추가
    if (AuthService.to.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer \${AuthService.to.accessToken}';
    }

    // 커스텀 헤더가 있으면 추가
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// GET 요청
  static Future<ApiResponse<T>> get<T>(String path) async {
    try {
      final response = await _client.get(
        Uri.parse('\${ApiPath.baseUrl}\$path'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(data as T);
      } else {
        final error = jsonDecode(response.body)['message'] as String? ?? '요청 실패';
        return ApiResponse.error(error);
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// POST 요청
  static Future<ApiResponse<T>> post<T>(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.post(
        Uri.parse('\${ApiPath.baseUrl}\$path'),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(data as T);
      } else {
        final error = jsonDecode(response.body)['message'] as String? ?? '요청 실패';
        return ApiResponse.error(error);
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// PUT 요청
  static Future<ApiResponse<T>> put<T>(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.put(
        Uri.parse('\${ApiPath.baseUrl}\$path'),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(data as T);
      } else {
        final error = jsonDecode(response.body)['message'] as String? ?? '요청 실패';
        return ApiResponse.error(error);
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// DELETE 요청
  static Future<ApiResponse<T>> delete<T>(String path) async {
    try {
      final response = await _client.delete(
        Uri.parse('\${ApiPath.baseUrl}\$path'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(null);
      } else {
        final error = jsonDecode(response.body)['message'] as String? ?? '요청 실패';
        return ApiResponse.error(error);
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
''';
    await file.writeAsString(content);
  }

  /// Mobile SecureStorage 생성
  Future<void> _createMobileSecureStorage(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'utils', 'secure_storage.dart'));
    await file.parent.create(recursive: true);

    final content =
        '''import 'package:$packageName/mobile/utils/storage_interface.dart';
import 'package:$packageName/mobile/utils/mobile_storage_adapter.dart';

/// 모바일 전용 저장소 래퍼
/// FlutterSecureStorage 사용
class LocalStorage implements StorageInterface {
  static const String accessTokenKey = 'accessToken';
  static LocalStorage? _instance;
  final StorageInterface _storage;

  LocalStorage._(this._storage);

  /// 모바일 저장소 인스턴스 생성
  static LocalStorage get instance {
    if (_instance != null) return _instance!;
    _instance = LocalStorage._(MobileStorageAdapter());
    return _instance!;
  }

  @override
  Future<void> setData(String key, String value) async {
    await _storage.setData(key, value);
  }

  @override
  Future<String?> getData(String key) async {
    return await _storage.getData(key);
  }

  @override
  Future<void> removeData(String key) async {
    await _storage.removeData(key);
  }

  @override
  Future<void> clear() async {
    await _storage.clear();
  }
}
''';
    await file.writeAsString(content);
  }

  /// Mobile StorageInterface 생성
  Future<void> _createMobileStorageInterface(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'utils', 'storage_interface.dart'));
    await file.parent.create(recursive: true);

    final content = '''/// 플랫폼별 저장소 인터페이스
/// 모바일에서 사용하는 저장소 인터페이스
abstract class StorageInterface {
  /// 데이터 저장
  Future<void> setData(String key, String value);

  /// 데이터 읽기
  Future<String?> getData(String key);

  /// 데이터 삭제
  Future<void> removeData(String key);

  /// 모든 데이터 삭제
  Future<void> clear();
}
''';
    await file.writeAsString(content);
  }

  /// Mobile StorageAdapter 생성
  Future<void> _createMobileStorageAdapter(String targetPath, String packageName) async {
    final file = File(
      path.join(targetPath, 'lib', 'mobile', 'utils', 'mobile_storage_adapter.dart'),
    );
    await file.parent.create(recursive: true);

    final content =
        '''import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:$packageName/mobile/utils/storage_interface.dart';

/// 모바일 전용 저장소 어댑터 (FlutterSecureStorage)
class MobileStorageAdapter implements StorageInterface {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  Future<void> setData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?> getData(String key) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> removeData(String key) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> clear() async {
    await _secureStorage.deleteAll();
  }
}
''';
    await file.writeAsString(content);
  }

  /// Mobile PermissionService 생성
  Future<void> _createMobilePermissionService(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'utils', 'permission_service.dart'));
    await file.parent.create(recursive: true);

    final content = '''import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static PermissionService? _instance;

  PermissionService._();

  static PermissionService get instance {
    _instance ??= PermissionService._();
    return _instance!;
  }

  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    if (await Permission.camera.isGranted) {
      return true;
    }

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestPhotosPermission() async {
    if (await Permission.photos.isGranted) {
      return true;
    }

    final status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    if (await Permission.microphone.isGranted) {
      return true;
    }

    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> checkInternetPermission() async {
    return true;
  }

  Future<Map<Permission, bool>> requestAllPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.camera,
      Permission.photos,
      Permission.microphone,
    ];

    final statuses = await permissions.request();
    return statuses.map((key, value) => MapEntry(key, value.isGranted));
  }

  Future<bool> isStorageGranted() async {
    return await Permission.storage.isGranted;
  }

  Future<bool> isCameraGranted() async {
    return await Permission.camera.isGranted;
  }

  Future<bool> isPhotosGranted() async {
    return await Permission.photos.isGranted;
  }

  Future<bool> isMicrophoneGranted() async {
    return await Permission.microphone.isGranted;
  }
}
''';
    await file.writeAsString(content);
  }

  /// Mobile CustomTheme 생성
  Future<void> _createMobileCustomTheme(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'mobile', 'theme', 'custom_theme.dart'));
    await file.parent.create(recursive: true);

    // 간단한 버전으로 생성 (전체 내용은 기존 파일 참고)
    final content = '''import 'package:flutter/material.dart';

/// 앱의 색상 팔레트를 정의하는 클래스
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF00BCD4);
  static const Color primaryLight = Color(0xFF62EFFF);
  static const Color primaryDark = Color(0xFF008BA3);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFE53935);
}

/// 앱의 커스텀 테마를 정의하는 클래스
class CustomTheme {
  CustomTheme._();

  /// 라이트 테마
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
      background: AppColors.background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
    );
  }
}
''';
    await file.writeAsString(content);
  }

  /// Web 구조 생성
  Future<void> _createWebStructure(String targetPath, String packageName, Logger logger) async {
    // Web Bootstrap
    await _createWebBootstrap(targetPath, packageName);
    // Web Main
    await _createWebMain(targetPath, packageName);
    // Web App
    await _createWebApp(targetPath, packageName);
    // Web Routes
    await _createWebRoutes(targetPath, packageName);
    await _createWebPages(targetPath, packageName);
    // Web Pages (Splash, Login, Home)
    await _createWebSplashPage(targetPath, packageName);
    await _createWebLoginPage(targetPath, packageName);
    await _createWebHomePage(targetPath, packageName);
    // Web Services
    await _createWebAuthService(targetPath, packageName);
    // Web Repositories
    await _createWebAuthRepository(targetPath, packageName);
    // Web Data
    await _createWebAuthData(targetPath, packageName);
    await _createWebLoginDto(targetPath, packageName);
    // Web Models
    await _createWebAuthDataModel(targetPath, packageName);
    // Web Utils
    await _createWebApiUtil(targetPath, packageName);
    await _createWebSecureStorage(targetPath, packageName);
    await _createWebStorageInterface(targetPath, packageName);
    await _createWebStorageAdapter(targetPath, packageName);
    await _createWebCookieStorage(targetPath, packageName);
    // Web Theme
    await _createWebCustomTheme(targetPath, packageName);
  }

  /// Web Bootstrap 생성
  Future<void> _createWebBootstrap(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'bootstrap_web.dart'));
    await file.parent.create(recursive: true);

    final content =
        '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:$packageName/web/services/auth_service.dart';
import 'package:$packageName/web/web_app.dart';

@pragma('vm:entry-point')
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AuthService 초기화 및 주입
  Get.put(AuthService(), permanent: true);

  // 인증 상태 확인 (토큰 확인 및 사용자 정보 로드)
  await AuthService.to.init();

  runApp(const WebApp());
}
''';
    await file.writeAsString(content);
  }

  /// Web Main 생성
  Future<void> _createWebMain(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'main.dart'));
    await file.parent.create(recursive: true);

    final content = '''import 'package:$packageName/web/bootstrap_web.dart';

@pragma('vm:entry-point')
void main() {
  bootstrap();
}
''';
    await file.writeAsString(content);
  }

  /// Web App 생성
  Future<void> _createWebApp(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'web_app.dart'));
    await file.parent.create(recursive: true);

    final content =
        '''import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:$packageName/web/routes/app_pages.dart';
import 'package:$packageName/web/theme/custom_theme.dart';

/// 웹 전용 앱 위젯
class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: '$packageName',
          debugShowCheckedModeBanner: false,
          theme: CustomTheme.lightTheme,
          initialRoute: Routes.splash,
          getPages: AppPages.routes,
          builder: (context, child) {
            return Material(
              color: CustomTheme.lightTheme.scaffoldBackgroundColor,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
''';
    await file.writeAsString(content);
  }

  /// Web Routes 생성
  Future<void> _createWebRoutes(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'routes', 'app_routes.dart'));
    await file.parent.create(recursive: true);

    final content = '''part of 'app_pages.dart';

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
''';
    await file.writeAsString(content);
  }

  /// Web Pages 생성
  Future<void> _createWebPages(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'routes', 'app_pages.dart'));
    await file.parent.create(recursive: true);

    final content = '''import 'package:get/get.dart';

import '../pages/splash/bindings/splash_binding.dart';
import '../pages/splash/views/splash_view.dart';
import '../pages/home/bindings/home_binding.dart';
import '../pages/home/views/home_view.dart';
import '../pages/login/bindings/login_binding.dart';
import '../pages/login/views/login_view.dart';
// NAEILMAKE: import
part 'app_routes.dart';

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
    GetPage<dynamic>(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    // NAEILMAKE: routes
  ];
}
''';
    await file.writeAsString(content);
  }

  /// Web Splash/Login/Home 페이지 생성 (Mobile과 유사하지만 web 경로 사용)
  Future<void> _createWebSplashPage(String targetPath, String packageName) async {
    final controllerFile = File(
      path.join(
        targetPath,
        'lib',
        'web',
        'pages',
        'splash',
        'controllers',
        'splash_controller.dart',
      ),
    );
    await controllerFile.parent.create(recursive: true);
    await controllerFile.writeAsString('''import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:$packageName/web/routes/app_pages.dart';
import 'package:$packageName/web/services/auth_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (AuthService.to.isAuthenticated) {
        Get.offAllNamed(Routes.home);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      Get.offAllNamed(Routes.login);
    }
  }
}
''');

    final viewFile = File(
      path.join(targetPath, 'lib', 'web', 'pages', 'splash', 'views', 'splash_view.dart'),
    );
    await viewFile.parent.create(recursive: true);
    await viewFile.writeAsString('''import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SplashView'), centerTitle: true),
      body: Center(child: Text('SplashView 동작 중', style: TextStyle(fontSize: 20.sp))),
    );
  }
}
''');

    final bindingFile = File(
      path.join(targetPath, 'lib', 'web', 'pages', 'splash', 'bindings', 'splash_binding.dart'),
    );
    await bindingFile.parent.create(recursive: true);
    await bindingFile.writeAsString('''import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}
''');
  }

  Future<void> _createWebLoginPage(String targetPath, String packageName) async {
    // Mobile과 유사하지만 web 경로 사용 - 간단히 생성
    final controllerFile = File(
      path.join(targetPath, 'lib', 'web', 'pages', 'login', 'controllers', 'login_controller.dart'),
    );
    await controllerFile.parent.create(recursive: true);
    await controllerFile.writeAsString('''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:$packageName/web/models/auth_data.dart';
import 'package:$packageName/web/repositories/auth_repository.dart';
import 'package:$packageName/web/routes/app_pages.dart';
import 'package:$packageName/web/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;

  Future<void> login() async {
    if (isLoading.value) return;
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar('오류', '사용자 이름을 입력해주세요.');
      return;
    }
    if (passwordController.text.trim().isEmpty) {
      Get.snackbar('오류', '비밀번호를 입력해주세요.');
      return;
    }

    isLoading.value = true;
    try {
      final token = await _authRepository.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );
      final user = User(
        id: '1',
        username: usernameController.text.trim(),
        email: '\${usernameController.text.trim()}@example.com',
      );
      await AuthService.to.login(token, user);
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar('로그인 실패', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
''');

    final viewFile = File(
      path.join(targetPath, 'lib', 'web', 'pages', 'login', 'views', 'login_view.dart'),
    );
    await viewFile.parent.create(recursive: true);
    await viewFile.writeAsString('''import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:$packageName/web/pages/login/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('환영합니다', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 48.h),
              TextField(
                controller: controller.usernameController,
                decoration: const InputDecoration(labelText: '사용자 이름', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller.passwordController,
                decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder()),
                obscureText: true,
                onSubmitted: (_) => controller.login(),
              ),
              SizedBox(height: 32.h),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.login,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('로그인'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
''');

    final bindingFile = File(
      path.join(targetPath, 'lib', 'web', 'pages', 'login', 'bindings', 'login_binding.dart'),
    );
    await bindingFile.parent.create(recursive: true);
    await bindingFile.writeAsString('''import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginController());
  }
}
''');
  }

  Future<void> _createWebHomePage(String targetPath, String packageName) async {
    final controllerFile = File(
      path.join(targetPath, 'lib', 'web', 'pages', 'home', 'controllers', 'home_controller.dart'),
    );
    await controllerFile.parent.create(recursive: true);
    await controllerFile.writeAsString('''import 'package:get/get.dart';

class HomeController extends GetxController {
  // TODO: HomeController 구현
}
''');

    final viewFile = File(
      path.join(targetPath, 'lib', 'web', 'pages', 'home', 'views', 'home_view.dart'),
    );
    await viewFile.parent.create(recursive: true);
    await viewFile.writeAsString('''import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HomeView'), centerTitle: true),
      body: Center(child: Text('HomeView 동작 중', style: TextStyle(fontSize: 20.sp))),
    );
  }
}
''');

    final bindingFile = File(
      path.join(targetPath, 'lib', 'web', 'pages', 'home', 'bindings', 'home_binding.dart'),
    );
    await bindingFile.parent.create(recursive: true);
    await bindingFile.writeAsString('''import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
  }
}
''');
  }

  // Web 나머지 파일들 생성 (Mobile과 유사하지만 web 경로 사용)
  Future<void> _createWebAuthService(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'services', 'auth_service.dart'));
    await file.parent.create(recursive: true);

    final content =
        '''import 'package:get/get.dart';
import 'package:$packageName/web/models/auth_data.dart';
import 'package:$packageName/web/repositories/auth_repository.dart';
import 'package:$packageName/web/utils/secure_storage.dart';

/// 전역 인증 상태 관리 서비스
/// GetXService를 사용하여 앱 전체에서 단일 인스턴스로 관리
class AuthService extends GetxService {
  static AuthService get to => Get.find();

  /// 현재 로그인한 사용자
  final Rx<User?> user = Rx<User?>(null);

  /// 액세스 토큰
  String accessToken = '';

  /// 로그인 상태 (authenticated, unauthenticated, loading)
  final Rx<AuthState> authState = AuthState.loading.obs;

  /// 로그인 여부 (computed)
  bool get isAuthenticated => authState.value == AuthState.authenticated;

  /// 초기화: 앱 시작 시 토큰 확인 및 사용자 정보 로드
  Future<void> init() async {
    try {
      authState.value = AuthState.loading;

      // SecureStorage에서 토큰 확인
      final token = await LocalStorage.instance.getData(LocalStorage.accessTokenKey);

      if (token != null && token.isNotEmpty) {
        accessToken = token;
        // TODO: 백엔드 API 연동 후 사용자 정보 로드
        // await _loadCurrentUser();

        // 임시로 토큰만 확인하여 인증 상태 설정
        authState.value = AuthState.authenticated;
      } else {
        accessToken = '';
        user.value = null;
        authState.value = AuthState.unauthenticated;
      }
    } catch (e) {
      // 에러 발생 시 미인증 상태로 설정
      accessToken = '';
      user.value = null;
      authState.value = AuthState.unauthenticated;
    }
  }

  /// 현재 사용자 정보 로드
  /// TODO: 백엔드 API 연동 후 init() 메서드에서 호출 예정
  // ignore: unused_element
  Future<void> _loadCurrentUser() async {
    // TODO: 백엔드 API 연동
    // 실제 구현 예시:
    final repository = AuthRepository();
    final currentUser = await repository.getCurrentUser();
    if (currentUser != null) {
      user.value = currentUser;
      authState.value = AuthState.authenticated;
    } else {
      await logout();
    }
  }

  /// 로그인 처리
  ///
  /// [token] 액세스 토큰
  /// [userData] 사용자 정보
  Future<void> login(String token, User userData) async {
    try {
      // 토큰을 SecureStorage에 저장
      await LocalStorage.instance.setData(LocalStorage.accessTokenKey, token);

      // AuthService 상태 업데이트
      accessToken = token;
      user.value = userData;
      authState.value = AuthState.authenticated;
    } catch (e) {
      throw Exception('로그인 처리 중 오류가 발생했습니다: \$e');
    }
  }

  /// 로그아웃 처리
  Future<void> logout() async {
    try {
      // SecureStorage에서 토큰 삭제
      await LocalStorage.instance.removeData(LocalStorage.accessTokenKey);

      // AuthService 상태 초기화
      accessToken = '';
      user.value = null;
      authState.value = AuthState.unauthenticated;

      // TODO: 백엔드 API 연동
      // 실제 구현 예시:
      final repository = AuthRepository();
      await repository.logout();
    } catch (e) {
      // 에러가 발생해도 로컬 상태는 초기화
      accessToken = '';
      user.value = null;
      authState.value = AuthState.unauthenticated;
    }
  }

  /// 인증 상태 확인 및 갱신
  Future<void> checkAuthStatus() async {
    await init();
  }
}
''';
    await file.writeAsString(content);
  }

  Future<void> _createWebAuthRepository(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'repositories', 'auth_repository.dart'));
    await file.parent.create(recursive: true);
    await file.writeAsString('''import 'package:$packageName/web/data/auth_data.dart';
import 'package:$packageName/web/data/dto/login_dto.dart';
import 'package:$packageName/web/models/auth_data.dart';

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

  Future<void> logout() async {
    await _authData.logout();
  }

  Future<User?> getCurrentUser() async {
    final response = await _authData.getCurrentUser();
    if (!response.success) return null;
    return User.fromJson(response.data!);
  }
}
''');
  }

  Future<void> _createWebAuthData(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'data', 'auth_data.dart'));
    await file.parent.create(recursive: true);
    await file.writeAsString('''import 'package:$packageName/web/utils/api.dart';

class AuthData {
  Future<ApiResponse<Map<String, dynamic>>> login(String username, String password) async {
    return await API.post<Map<String, dynamic>>(
      ApiPath.login,
      body: {'username': username, 'password': password},
    );
  }

  Future<ApiResponse<void>> logout() async {
    return await API.post<void>(ApiPath.logout);
  }

  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    return await API.get<Map<String, dynamic>>(ApiPath.me);
  }
}
''');
  }

  Future<void> _createWebLoginDto(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'data', 'dto', 'login_dto.dart'));
    await file.parent.create(recursive: true);
    await file.writeAsString('''import 'package:$packageName/web/models/auth_data.dart';

class LoginResponseDto {
  final String accessToken;
  final Map<String, dynamic> userJson;

  const LoginResponseDto({required this.accessToken, required this.userJson});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String,
      userJson: json['user'] as Map<String, dynamic>,
    );
  }

  User toEntity() {
    return User.fromJson(userJson);
  }
}
''');
  }

  Future<void> _createWebAuthDataModel(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'models', 'auth_data.dart'));
    await file.parent.create(recursive: true);
    // Mobile과 동일
    await file.writeAsString('''enum AuthState { authenticated, unauthenticated, loading }

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

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, if (email != null) 'email': email};
  }
}

class LoginRequest {
  final String username;
  final String password;
  const LoginRequest({required this.username, required this.password});
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}
''');
  }

  Future<void> _createWebApiUtil(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'utils', 'api.dart'));
    await file.parent.create(recursive: true);
    // Mobile과 동일하지만 web 경로 사용
    final content =
        '''import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:$packageName/web/services/auth_service.dart';

class ApiPath {
  static const String baseUrl = 'http://localhost:3000';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
}

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;
  ApiResponse.success(this.data) : error = null, success = true;
  ApiResponse.error(this.error) : data = null, success = false;
}

class API {
  static final _client = http.Client();

  static Map<String, String> _getHeaders({Map<String, String>? customHeaders}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (AuthService.to.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer \${AuthService.to.accessToken}';
    }
    if (customHeaders != null) headers.addAll(customHeaders);
    return headers;
  }

  static Future<ApiResponse<T>> get<T>(String path) async {
    try {
      final response = await _client.get(Uri.parse('\${ApiPath.baseUrl}\$path'), headers: _getHeaders());
      if (response.statusCode == 200) {
        return ApiResponse.success(jsonDecode(response.body) as T);
      } else {
        return ApiResponse.error('요청 실패');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<T>> post<T>(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.post(
        Uri.parse('\${ApiPath.baseUrl}\$path'),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(jsonDecode(response.body) as T);
      } else {
        return ApiResponse.error('요청 실패');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<T>> put<T>(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.put(
        Uri.parse('\${ApiPath.baseUrl}\$path'),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(jsonDecode(response.body) as T);
      } else {
        return ApiResponse.error('요청 실패');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<T>> delete<T>(String path) async {
    try {
      final response = await _client.delete(Uri.parse('\${ApiPath.baseUrl}\$path'), headers: _getHeaders());
      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('요청 실패');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
''';
    await file.writeAsString(content);
  }

  Future<void> _createWebSecureStorage(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'utils', 'secure_storage.dart'));
    await file.parent.create(recursive: true);
    await file.writeAsString('''import 'package:$packageName/web/utils/storage_interface.dart';
import 'package:$packageName/web/utils/web_storage_adapter.dart';

class LocalStorage implements StorageInterface {
  static const String accessTokenKey = 'accessToken';
  static LocalStorage? _instance;
  final StorageInterface _storage;

  LocalStorage._(this._storage);

  static LocalStorage get instance {
    if (_instance != null) return _instance!;
    _instance = LocalStorage._(WebStorageAdapter());
    return _instance!;
  }

  @override
  Future<void> setData(String key, String value) async => await _storage.setData(key, value);

  @override
  Future<String?> getData(String key) async => await _storage.getData(key);

  @override
  Future<void> removeData(String key) async => await _storage.removeData(key);

  @override
  Future<void> clear() async => await _storage.clear();
}
''');
  }

  Future<void> _createWebStorageInterface(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'utils', 'storage_interface.dart'));
    await file.parent.create(recursive: true);
    await file.writeAsString('''abstract class StorageInterface {
  Future<void> setData(String key, String value);
  Future<String?> getData(String key);
  Future<void> removeData(String key);
  Future<void> clear();
}
''');
  }

  Future<void> _createWebStorageAdapter(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'utils', 'web_storage_adapter.dart'));
    await file.parent.create(recursive: true);
    await file.writeAsString('''import 'package:$packageName/web/utils/storage_interface.dart';
import 'package:$packageName/web/utils/cookie_storage.dart';

class WebStorageAdapter implements StorageInterface {
  final CookieStorage _cookieStorage = CookieStorage.instance;

  @override
  Future<void> setData(String key, String value) async => await _cookieStorage.setData(key, value);

  @override
  Future<String?> getData(String key) async => await _cookieStorage.getData(key);

  @override
  Future<void> removeData(String key) async => await _cookieStorage.removeData(key);

  @override
  Future<void> clear() async => await _cookieStorage.clear();
}
''');
  }

  Future<void> _createWebCookieStorage(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'utils', 'cookie_storage.dart'));
    await file.parent.create(recursive: true);
    await file.writeAsString('''import 'dart:html' as html;

class CookieStorage {
  static const String accessTokenKey = 'accessToken';
  static CookieStorage? _instance;

  CookieStorage._();

  static CookieStorage get instance {
    _instance ??= CookieStorage._();
    return _instance!;
  }

  Future<void> setData(String key, String value, {int? maxAge}) async {
    final expires = maxAge ?? 7 * 24 * 60 * 60;
    html.document.cookie = '\$key=\$value; max-age=\$expires; path=/; SameSite=Lax';
  }

  Future<String?> getData(String key) async {
    final cookies = html.document.cookie?.split(';') ?? [];
    for (final cookie in cookies) {
      final parts = cookie.trim().split('=');
      if (parts.length == 2 && parts[0] == key) {
        return parts[1];
      }
    }
    return null;
  }

  Future<void> removeData(String key) async {
    html.document.cookie = '\$key=; max-age=0; path=/; SameSite=Lax';
  }

  Future<void> clear() async {
    final cookies = html.document.cookie?.split(';') ?? [];
    for (final cookie in cookies) {
      final parts = cookie.trim().split('=');
      if (parts.isNotEmpty) {
        await removeData(parts[0]);
      }
    }
  }
}
''');
  }

  Future<void> _createWebCustomTheme(String targetPath, String packageName) async {
    final file = File(path.join(targetPath, 'lib', 'web', 'theme', 'custom_theme.dart'));
    await file.parent.create(recursive: true);
    // Mobile과 동일
    await file.writeAsString('''import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();
  static const Color primary = Color(0xFF00BCD4);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color error = Color(0xFFE53935);
}

class CustomTheme {
  CustomTheme._();
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
    );
  }
}
''');
  }

  /// Test 구조 생성
  Future<void> _createTestStructure(String targetPath, Logger logger) async {
    final file = File(path.join(targetPath, 'test', 'widget_test.dart'));
    await file.parent.create(recursive: true);

    final content = '''// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
''';
    await file.writeAsString(content);
  }

  /// 패키지 ID를 Dart 패키지 이름으로 변환
  static String _packageIdToPackageName(String packageId) {
    // com.naeil.flutter -> naeil_flutter
    // 패키지 ID의 마지막 부분을 언더스코어로 변환
    final parts = packageId.split('.');
    if (parts.length >= 2) {
      return parts.sublist(1).join('_');
    }
    return parts.last;
  }
}
