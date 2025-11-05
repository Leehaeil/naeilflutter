import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// 프로젝트 초기화 유틸리티
class ProjectInitializer {
  final Logger logger = Logger();

  /// sample 폴더 구조를 새 프로젝트에 복사하고 설정
  static Future<void> initialize({
    required String targetPath,
    required String samplePath,
    required String projectName,
    required String packageId,
  }) async {
    final logger = Logger();

    try {
      final targetDir = Directory(targetPath);
      final sampleDir = Directory(samplePath);

      if (!sampleDir.existsSync()) {
        logger.err('❌ sample 폴더를 찾을 수 없습니다: $samplePath');
        return;
      }

      if (!targetDir.existsSync()) {
        logger.err('❌ 대상 프로젝트 폴더를 찾을 수 없습니다: $targetPath');
        return;
      }

      // 1. lib 폴더 복사
      logger.detail('lib 폴더 구조 복사 중...');
      await _copyDirectory(
        source: path.join(samplePath, 'lib'),
        target: path.join(targetPath, 'lib'),
        logger: logger,
      );

      // 2. web 폴더 복사 (있는 경우)
      final sampleWebDir = Directory(path.join(samplePath, 'web'));
      if (sampleWebDir.existsSync()) {
        logger.detail('web 폴더 복사 중...');
        await _copyDirectory(
          source: path.join(samplePath, 'web'),
          target: path.join(targetPath, 'web'),
          logger: logger,
        );
      }

      // 3. pubspec.yaml 업데이트
      logger.detail('pubspec.yaml 업데이트 중...');
      await _updatePubspec(
        targetPath: targetPath,
        samplePath: samplePath,
        projectName: projectName,
        packageId: packageId,
        logger: logger,
      );

      // 4. 모든 Dart 파일의 import 경로 업데이트
      logger.detail('모든 Dart 파일의 import 경로 업데이트 중...');
      await _updateAllDartImports(
        targetPath: targetPath,
        packageId: packageId,
        logger: logger,
      );

      // 5. Android 패키지 이름 업데이트
      logger.detail('Android 패키지 이름 업데이트 중...');
      await _updateAndroidPackage(
        targetPath: targetPath,
        packageId: packageId,
        logger: logger,
      );

      // 6. iOS 번들 ID 업데이트
      logger.detail('iOS 번들 ID 업데이트 중...');
      await _updateIOSBundleId(
        targetPath: targetPath,
        packageId: packageId,
        logger: logger,
      );

      logger.success('✅ 프로젝트 초기화 완료');
    } catch (e, stackTrace) {
      logger.err('❌ 프로젝트 초기화 중 오류 발생: $e');
      logger.detail('스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  /// 디렉토리 복사
  static Future<void> _copyDirectory({
    required String source,
    required String target,
    required Logger logger,
  }) async {
    try {
      final sourceDir = Directory(source);
      if (!sourceDir.existsSync()) {
        logger.warn('⚠️  소스 디렉토리가 존재하지 않습니다: $source');
        return;
      }

      final targetDir = Directory(target);
      if (targetDir.existsSync()) {
        // 기존 lib 폴더 백업 후 삭제
        logger.detail('기존 $target 폴더를 삭제하는 중...');
        await targetDir.delete(recursive: true);
      }

      await targetDir.create(recursive: true);

      int fileCount = 0;
      await for (final entity in sourceDir.list(recursive: true)) {
        final relativePath = path.relative(entity.path, from: source);
        final targetPath = path.join(target, relativePath);

        if (entity is File) {
          final targetFile = File(targetPath);
          await targetFile.parent.create(recursive: true);
          await entity.copy(targetPath);
          fileCount++;
          if (fileCount % 10 == 0) {
            logger.detail('파일 복사 중... ($fileCount개)');
          }
        } else if (entity is Directory) {
          await Directory(targetPath).create(recursive: true);
        }
      }
      logger.detail('총 $fileCount개 파일 복사 완료');
    } catch (e) {
      logger.err('디렉토리 복사 중 오류: $e');
      rethrow;
    }
  }

  /// pubspec.yaml 업데이트
  static Future<void> _updatePubspec({
    required String targetPath,
    required String samplePath,
    required String projectName,
    required String packageId,
    required Logger logger,
  }) async {
    final samplePubspec = File(path.join(samplePath, 'pubspec.yaml'));
    final targetPubspec = File(path.join(targetPath, 'pubspec.yaml'));

    if (!samplePubspec.existsSync()) {
      logger.warn('⚠️  sample pubspec.yaml을 찾을 수 없습니다.');
      return;
    }

    // sample pubspec.yaml 읽기
    var content = await samplePubspec.readAsString();

    // 패키지 이름 업데이트
    final packageName = _packageIdToPackageName(packageId);
    content = content.replaceAll(
      RegExp(r'^name: .*', multiLine: true),
      'name: $packageName',
    );

    // target pubspec.yaml에 쓰기
    await targetPubspec.writeAsString(content);
  }

  /// 모든 Dart 파일의 import 경로 업데이트
  static Future<void> _updateAllDartImports({
    required String targetPath,
    required String packageId,
    required Logger logger,
  }) async {
    final libDir = Directory(path.join(targetPath, 'lib'));
    if (!libDir.existsSync()) {
      logger.warn('⚠️  lib 폴더를 찾을 수 없습니다.');
      return;
    }

    final packageName = _packageIdToPackageName(packageId);
    int updatedCount = 0;

    // lib 폴더 내의 모든 .dart 파일 찾기
    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        try {
          var content = await entity.readAsString();
          final originalContent = content;

          // package:naeil_flutter_init/를 새로운 패키지 이름으로 교체
          content = content.replaceAll(
            RegExp(r"package:naeil_flutter_init/"),
            'package:$packageName/',
          );

          // 내용이 변경되었으면 파일에 저장
          if (content != originalContent) {
            await entity.writeAsString(content);
            updatedCount++;
            logger.detail('업데이트: ${path.relative(entity.path, from: targetPath)}');
          }
        } catch (e) {
          logger.warn('⚠️  파일 업데이트 실패: ${entity.path} - $e');
        }
      }
    }

    logger.detail('총 $updatedCount개 Dart 파일의 import 경로를 업데이트했습니다.');
  }

  /// Android 패키지 이름 업데이트
  static Future<void> _updateAndroidPackage({
    required String targetPath,
    required String packageId,
    required Logger logger,
  }) async {
    // AndroidManifest.xml 파일들 업데이트
    final androidManifestPaths = [
      path.join(targetPath, 'android', 'app', 'src', 'main', 'AndroidManifest.xml'),
      path.join(targetPath, 'android', 'app', 'src', 'debug', 'AndroidManifest.xml'),
      path.join(targetPath, 'android', 'app', 'src', 'profile', 'AndroidManifest.xml'),
    ];

    for (final manifestPath in androidManifestPaths) {
      final manifestFile = File(manifestPath);
      if (manifestFile.existsSync()) {
        var content = await manifestFile.readAsString();
        content = content.replaceAll(
          RegExp(r'package="[^"]*"'),
          'package="$packageId"',
        );
        await manifestFile.writeAsString(content);
      }
    }

    // build.gradle.kts 파일 업데이트
    final buildGradle = File(
      path.join(targetPath, 'android', 'app', 'build.gradle.kts'),
    );
    if (buildGradle.existsSync()) {
      var content = await buildGradle.readAsString();
      content = content.replaceAll(
        RegExp(r'namespace\s*=\s*"[^"]*"'),
        'namespace = "$packageId"',
      );
      await buildGradle.writeAsString(content);
    }

    // Kotlin 파일 경로 이동
    final oldKotlinDir = Directory(
      path.join(
        targetPath,
        'android',
        'app',
        'src',
        'main',
        'kotlin',
        'com',
        'example',
      ),
    );

    if (oldKotlinDir.existsSync()) {
      final packageParts = packageId.split('.');
      final kotlinPathParts = [
        targetPath,
        'android',
        'app',
        'src',
        'main',
        'kotlin',
        ...packageParts,
      ];
      final newKotlinDir = Directory(path.joinAll(kotlinPathParts));

      await oldKotlinDir.rename(newKotlinDir.path);

      // MainActivity.kt 파일 내용 업데이트
      final mainActivityFile = File(
        path.join(newKotlinDir.path, packageParts.last, 'MainActivity.kt'),
      );
      if (mainActivityFile.existsSync()) {
        var content = await mainActivityFile.readAsString();
        content = content.replaceAll(
          RegExp(r'package\s+com\.example\.[^;\s]+'),
          'package $packageId',
        );
        await mainActivityFile.writeAsString(content);
      }
    }
  }

  /// iOS 번들 ID 업데이트
  static Future<void> _updateIOSBundleId({
    required String targetPath,
    required String packageId,
    required Logger logger,
  }) async {
    // Info.plist는 일반적으로 수동으로 설정하지만, 여기서는 기본 설정만 업데이트
    final projectPbxproj = File(
      path.join(targetPath, 'ios', 'Runner.xcodeproj', 'project.pbxproj'),
    );

    if (projectPbxproj.existsSync()) {
      var content = await projectPbxproj.readAsString();
      // PRODUCT_BUNDLE_IDENTIFIER 업데이트
      content = content.replaceAll(
        RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*[^;]+;'),
        'PRODUCT_BUNDLE_IDENTIFIER = $packageId;',
      );
      await projectPbxproj.writeAsString(content);
    }
  }

  /// 기존 프로젝트의 import 경로 업데이트
  /// pubspec.yaml에서 패키지 이름을 읽어서 모든 Dart 파일의 import 경로를 업데이트합니다
  static Future<void> updateExistingProjectImports({
    required String projectPath,
    required Logger logger,
  }) async {
    try {
      final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
      if (!pubspecFile.existsSync()) {
        logger.err('❌ pubspec.yaml을 찾을 수 없습니다: $projectPath');
        return;
      }

      // pubspec.yaml에서 패키지 이름 읽기
      final pubspecContent = await pubspecFile.readAsString();
      final nameMatch = RegExp(r'^name:\s*([^\s]+)', multiLine: true)
          .firstMatch(pubspecContent);
      
      if (nameMatch == null) {
        logger.err('❌ pubspec.yaml에서 패키지 이름을 찾을 수 없습니다.');
        return;
      }

      final packageName = nameMatch.group(1)?.trim();
      if (packageName == null || packageName.isEmpty) {
        logger.err('❌ 유효하지 않은 패키지 이름입니다.');
        return;
      }

      logger.info('📦 패키지 이름: $packageName');
      logger.info('🔄 import 경로 업데이트 중...');

      final libDir = Directory(path.join(projectPath, 'lib'));
      if (!libDir.existsSync()) {
        logger.warn('⚠️  lib 폴더를 찾을 수 없습니다.');
        return;
      }

      int updatedCount = 0;

      // lib 폴더 내의 모든 .dart 파일 찾기
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          try {
            var content = await entity.readAsString();
            final originalContent = content;

            // package:naeil_flutter_init/를 새로운 패키지 이름으로 교체
            content = content.replaceAll(
              RegExp(r"package:naeil_flutter_init/"),
              'package:$packageName/',
            );

            // 내용이 변경되었으면 파일에 저장
            if (content != originalContent) {
              await entity.writeAsString(content);
              updatedCount++;
              logger.detail('업데이트: ${path.relative(entity.path, from: projectPath)}');
            }
          } catch (e) {
            logger.warn('⚠️  파일 업데이트 실패: ${entity.path} - $e');
          }
        }
      }

      if (updatedCount > 0) {
        logger.success('✅ 총 $updatedCount개 Dart 파일의 import 경로를 업데이트했습니다.');
      } else {
        logger.info('ℹ️  업데이트할 파일이 없습니다.');
      }
    } catch (e, stackTrace) {
      logger.err('❌ import 경로 업데이트 중 오류 발생: $e');
      logger.detail('스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  /// 패키지 ID를 Dart 패키지 이름으로 변환
  static String _packageIdToPackageName(String packageId) {
    // com.naeil.flutter -> naeil_flutter
    // 패키지 ID의 마지막 부분을 언더스코어로 변환
    final parts = packageId.split('.');
    if (parts.length >= 2) {
      return parts.sublist(1).join('_');
    }
    return parts.last;
  }
}
