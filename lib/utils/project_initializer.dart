import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:naeilflutter/utils/project_template_generator.dart';
import 'package:path/path.dart' as path;

/// 프로젝트 초기화 유틸리티
/// 템플릿 기반으로 직접 파일을 생성합니다
class ProjectInitializer {
  final Logger logger = Logger();

  /// 템플릿 기반으로 프로젝트 구조 생성
  static Future<void> initialize({
    required String targetPath,
    required String projectName,
    required String packageId,
    required List<String> platforms,
  }) async {
    final logger = Logger();

    try {
      final targetDir = Directory(targetPath);

      if (!targetDir.existsSync()) {
        logger.err('❌ 대상 프로젝트 폴더를 찾을 수 없습니다: $targetPath');
        return;
      }

      // 템플릿 기반으로 프로젝트 구조 생성
      await ProjectTemplateGenerator.generateProject(
        targetPath: targetPath,
        projectName: projectName,
        packageId: packageId,
        platforms: platforms,
        logger: logger,
      );

      // Android 패키지 이름 업데이트
      logger.detail('Android 패키지 이름 업데이트 중...');
      await _updateAndroidPackage(
        targetPath: targetPath,
        packageId: packageId,
        logger: logger,
      );

      // iOS 번들 ID 업데이트
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

}
