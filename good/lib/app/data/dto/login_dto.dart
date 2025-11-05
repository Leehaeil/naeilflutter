import 'package:naeil_flutter_init/app/models/auth_data.dart';

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

