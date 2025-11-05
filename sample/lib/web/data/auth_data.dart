import 'package:naeil_flutter_init/web/utils/api.dart';

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

