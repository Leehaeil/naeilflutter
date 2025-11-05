/// 플랫폼별 저장소 인터페이스
/// 모바일과 웹에서 동일한 인터페이스로 저장소를 사용할 수 있도록 함
abstract class StorageInterface {
  /// 데이터 저장
  Future<void> setData(String key, String value);

  /// 데이터 읽기
  Future<String?> getData(String key);

  /// 데이터 삭제
  Future<void> removeData(String key);

  /// 모든 데이터 삭제
  Future<void> clear();
}

