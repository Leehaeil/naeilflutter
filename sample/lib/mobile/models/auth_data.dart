/// 인증 상태를 나타내는 enum
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

