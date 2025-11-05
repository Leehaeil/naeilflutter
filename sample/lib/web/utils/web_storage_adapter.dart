import 'package:naeil_flutter_init/web/utils/storage_interface.dart';
import 'package:naeil_flutter_init/web/utils/cookie_storage.dart';

/// 웹 전용 저장소 어댑터 (쿠키 기반)
class WebStorageAdapter implements StorageInterface {
  final CookieStorage _cookieStorage = CookieStorage.instance;

  @override
  Future<void> setData(String key, String value) async {
    await _cookieStorage.setData(key, value);
  }

  @override
  Future<String?> getData(String key) async {
    return await _cookieStorage.getData(key);
  }

  @override
  Future<void> removeData(String key) async {
    await _cookieStorage.removeData(key);
  }

  @override
  Future<void> clear() async {
    await _cookieStorage.clear();
  }
}
