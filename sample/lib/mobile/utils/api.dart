import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:naeil_flutter_init/mobile/services/auth_service.dart';

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
  static final _client = http.Client(); // TODO: 백엔드 API 연동 시 사용

  /// 기본 헤더 설정 (Authorization 토큰 자동 포함)
  static Map<String, String> _getHeaders({Map<String, String>? customHeaders}) {
    final headers = <String, String>{'Content-Type': 'application/json'};

    // AuthService에서 토큰을 가져와 Authorization 헤더에 추가
    if (AuthService.to.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${AuthService.to.accessToken}';
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
        Uri.parse('${ApiPath.baseUrl}$path'),
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
        Uri.parse('${ApiPath.baseUrl}$path'),
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
        Uri.parse('${ApiPath.baseUrl}$path'),
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
        Uri.parse('${ApiPath.baseUrl}$path'),
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

