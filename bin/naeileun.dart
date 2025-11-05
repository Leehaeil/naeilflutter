#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:naeilflutter/commands/flutter_init_command.dart';

void main(List<String> args) async {
  final logger = Logger();
  final parser = ArgParser()
    ..addCommand(
      'flutter',
      ArgParser()
        ..addCommand(
          'init',
          ArgParser(),
        ),
    );

  try {
    final result = parser.parse(args);

    if (result.command?.name == 'flutter' &&
        result.command?.arguments.isNotEmpty == true) {
      final flutterCommand = result.command!.arguments[0];

      if (flutterCommand == 'init') {
        try {
          await FlutterInitCommand(logger).run();
          // run() 메서드 내에서 이미 exit(0)를 호출하지만, 혹시 모를 경우를 대비
          exit(0);
        } catch (e, stackTrace) {
          logger.err('명령어 실행 중 오류: $e');
          logger.detail('스택 트레이스: $stackTrace');
          exit(1);
        }
      } else {
        logger.err('알 수 없는 명령어: flutter $flutterCommand');
        logger.info('사용 가능한 명령어: flutter init');
        exit(1);
      }
    } else {
      _showUsage(logger);
      exit(1);
    }
  } catch (e) {
    logger.err('오류 발생: $e');
    exit(1);
  }
}

void _showUsage(Logger logger) {
  logger.info('''
Flutter 프로젝트 초기화 CLI 도구

사용법:
  naeileun flutter init

명령어:
  flutter init    Flutter 프로젝트를 생성하고 초기화합니다
  ''');
}
