import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Flutter 명령어 실행 유틸리티
class FlutterRunner {
  final Logger logger = Logger();

  /// Flutter 프로젝트 생성
  static Future<String?> createProject({
    required String projectName,
    required String packageId,
    required List<String> platforms,
  }) async {
    final logger = Logger();

    try {
      // Flutter가 설치되어 있는지 확인
      final flutterCheck = await Process.run(
        'flutter',
        ['--version'],
        runInShell: true,
      );

      if (flutterCheck.exitCode != 0) {
        logger.err('❌ Flutter가 설치되어 있지 않거나 PATH에 없습니다.');
        return null;
      }

      // 플랫폼 옵션 생성
      final platformFlags = <String>[];
      for (final platform in platforms) {
        platformFlags.add('--platforms=$platform');
      }

      // Flutter 프로젝트 생성 명령어 실행
      logger.detail('Flutter 프로젝트 생성 중...');
      logger.detail('명령어: flutter create ${platformFlags.join(" ")} $projectName');

      final result = await Process.run(
        'flutter',
        [
          'create',
          ...platformFlags,
          '--org',
          packageId.split('.').take(packageId.split('.').length - 1).join('.'),
          '--project-name',
          projectName,
          projectName,
        ],
        runInShell: true,
      );

      if (result.exitCode != 0) {
        logger.err('Flutter 프로젝트 생성 실패:');
        logger.err(result.stderr);
        return null;
      }

      final projectPath = path.join(Directory.current.path, projectName);
      return projectPath;
    } catch (e) {
      logger.err('오류 발생: $e');
      return null;
    }
  }
}
