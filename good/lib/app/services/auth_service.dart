import 'package:get/get.dart';
import 'package:naeil_flutter_init/app/models/auth_data.dart';
import 'package:naeil_flutter_init/app/repositories/auth_repository.dart';
import 'package:naeil_flutter_init/app/utils/secure_storage.dart';

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
  // bool get isAuthenticated => authState.value == AuthState.authenticated;

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
      throw Exception('로그인 처리 중 오류가 발생했습니다: $e');
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
