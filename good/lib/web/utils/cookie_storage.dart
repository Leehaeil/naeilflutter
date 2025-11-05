import 'dart:html' as html;

/// 웹 전용 쿠키 기반 저장소
/// 모바일의 LocalStorage와 동일한 인터페이스를 제공
class CookieStorage {
  static const String accessTokenKey = 'accessToken';
  static CookieStorage? _instance;

  CookieStorage._();

  static CookieStorage get instance {
    _instance ??= CookieStorage._();
    return _instance!;
  }

  /// 쿠키에 데이터 저장
  ///
  /// [key] 쿠키 키
  /// [value] 저장할 값
  /// [maxAge] 쿠키 만료 시간 (초 단위, 기본값: 7일)
  Future<void> setData(String key, String value, {int? maxAge}) async {
    final expires = maxAge ?? 7 * 24 * 60 * 60; // 기본 7일
    html.document.cookie = '$key=$value; max-age=$expires; path=/; SameSite=Lax';
  }

  /// 쿠키에서 데이터 읽기
  ///
  /// [key] 쿠키 키
  /// Returns: 쿠키 값 또는 null
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

  /// 쿠키 삭제
  ///
  /// [key] 삭제할 쿠키 키
  Future<void> removeData(String key) async {
    html.document.cookie = '$key=; max-age=0; path=/; SameSite=Lax';
  }

  /// 모든 쿠키 삭제
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
