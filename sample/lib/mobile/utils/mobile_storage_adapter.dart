import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:naeil_flutter_init/mobile/utils/storage_interface.dart';

/// 모바일 전용 저장소 어댑터 (FlutterSecureStorage)
class MobileStorageAdapter implements StorageInterface {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  Future<void> setData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?> getData(String key) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> removeData(String key) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> clear() async {
    await _secureStorage.deleteAll();
  }
}

