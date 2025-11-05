import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naeil_flutter_init/web/models/auth_data.dart';
import 'package:naeil_flutter_init/web/repositories/auth_repository.dart';
import 'package:naeil_flutter_init/web/routes/app_pages.dart';
import 'package:naeil_flutter_init/web/services/auth_service.dart';

/// 로그인 페이지 컨트롤러 (웹)
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
        email: '${usernameController.text.trim()}@example.com',
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

