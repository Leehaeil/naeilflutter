import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:naeil_flutter_init/app/utils/storage_interface.dart';
import 'package:naeil_flutter_init/app/utils/mobile_storage_adapter.dart';
import 'package:naeil_flutter_init/app/utils/web_storage_stub.dart'
    if (dart.library.html) 'package:naeil_flutter_init/web/utils/web_storage_adapter.dart';

/// 플랫폼별 저장소 래퍼
/// 모바일: FlutterSecureStorage 사용
/// 웹: 쿠키 기반 저장소 사용
class LocalStorage implements StorageInterface {
  static const String accessTokenKey = 'accessToken';
  static LocalStorage? _instance;
  final StorageInterface _storage;

  LocalStorage._(this._storage);

  /// 플랫폼에 맞는 저장소 인스턴스 생성
  static LocalStorage get instance {
    if (_instance != null) return _instance!;

    // 웹인 경우 쿠키 저장소 사용, 모바일인 경우 SecureStorage 사용
    if (kIsWeb) {
      // 조건부 import로 웹 전용 어댑터 로드
      _instance = LocalStorage._(WebStorageAdapter());
    } else {
      _instance = LocalStorage._(MobileStorageAdapter());
    }
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
