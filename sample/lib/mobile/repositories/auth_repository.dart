import 'package:naeil_flutter_init/mobile/data/auth_data.dart';
import 'package:naeil_flutter_init/mobile/data/dto/login_dto.dart';
import 'package:naeil_flutter_init/mobile/models/auth_data.dart';

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

