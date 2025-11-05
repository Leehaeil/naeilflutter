#!/usr/bin/env dart

import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:naeilflutter/utils/project_initializer.dart';
import 'package:path/path.dart' as path;

/// 기존 프로젝트의 import 경로를 업데이트하는 스크립트
void main(List<String> args) async {
  final logger = Logger();

  if (args.isEmpty) {
    logger.err('❌ 사용법: dart run bin/update_imports.dart <프로젝트_경로>');
    logger.info('');
    logger.info('예시:');
    logger.info('  dart run bin/update_imports.dart good');
    logger.info('  dart run bin/update_imports.dart sample');
    exit(1);
  }

  final projectPath = args[0];
  final absolutePath = path.isAbsolute(projectPath)
      ? projectPath
      : path.join(Directory.current.path, projectPath);

  if (!Directory(absolutePath).existsSync()) {
    logger.err('❌ 프로젝트 폴더를 찾을 수 없습니다: $absolutePath');
    exit(1);
  }

  logger.info('🔄 프로젝트 import 경로 업데이트 시작...');
  logger.info('프로젝트 경로: $absolutePath\n');

  try {
    await ProjectInitializer.updateExistingProjectImports(
      projectPath: absolutePath,
      logger: logger,
    );

    logger.success('\n✅ import 경로 업데이트가 완료되었습니다!');
    exit(0);
  } catch (e, stackTrace) {
    logger.err('❌ 오류 발생: $e');
    logger.detail('스택 트레이스: $stackTrace');
    exit(1);
  }
}

