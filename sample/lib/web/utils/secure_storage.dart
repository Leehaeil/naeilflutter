import 'package:naeil_flutter_init/web/utils/storage_interface.dart';
import 'package:naeil_flutter_init/web/utils/web_storage_adapter.dart';

/// 웹 전용 저장소 래퍼
/// 쿠키 기반 저장소 사용
class LocalStorage implements StorageInterface {
  static const String accessTokenKey = 'accessToken';
  static LocalStorage? _instance;
  final StorageInterface _storage;

  LocalStorage._(this._storage);

  /// 웹 저장소 인스턴스 생성
  static LocalStorage get instance {
    if (_instance != null) return _instance!;
    _instance = LocalStorage._(WebStorageAdapter());
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

