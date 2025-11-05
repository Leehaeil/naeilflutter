import 'package:naeil_flutter_init/app/utils/storage_interface.dart';

/// 모바일 빌드용 스텁 (웹에서는 사용되지 않음)
/// 웹 빌드 시 web_storage_adapter.dart의 WebStorageAdapter가 사용됨
class WebStorageAdapter implements StorageInterface {
  @override
  Future<void> setData(String key, String value) async {
    throw UnsupportedError('Web storage is not available on mobile platform');
  }

  @override
  Future<String?> getData(String key) async {
    throw UnsupportedError('Web storage is not available on mobile platform');
  }

  @override
  Future<void> removeData(String key) async {
    throw UnsupportedError('Web storage is not available on mobile platform');
  }

  @override
  Future<void> clear() async {
    throw UnsupportedError('Web storage is not available on mobile platform');
  }
}

