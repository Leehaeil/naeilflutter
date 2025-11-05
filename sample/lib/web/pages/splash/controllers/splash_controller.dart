import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:naeil_flutter_init/web/routes/app_pages.dart';
import 'package:naeil_flutter_init/web/services/auth_service.dart';

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
      developer.log('인증 상태 확인 중 오류 발생: $e', error: e, stackTrace: stackTrace);
      // 에러 발생 시 로그인 페이지로 이동
      Get.offAllNamed(Routes.login);
    }
  }
}

