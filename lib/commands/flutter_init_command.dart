import 'dart:io';
import 'package:interact_cli/interact_cli.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:naeilflutter/utils/flutter_runner.dart';
import 'package:naeilflutter/utils/project_initializer.dart';

/// Flutter 프로젝트 초기화 명령어
class FlutterInitCommand {
  final Logger logger;

  FlutterInitCommand(this.logger);

  /// 명령어 실행
  Future<void> run() async {
    try {
      logger.info('🚀 Flutter 프로젝트 초기화를 시작합니다...\n');

      // 1. 프로젝트 이름 입력
      final projectName = _getProjectName();
      logger.detail('프로젝트 이름: $projectName');

      // 2. 패키지 ID 입력
      final packageId = _getPackageId();
      logger.detail('패키지 ID: $packageId');

      // 3. 플랫폼 선택 (멀티셀렉트)
      final platforms = _selectPlatforms();
      logger.detail('선택된 플랫폼: ${platforms.join(", ")}');

      // 4. Flutter 프로젝트 생성
      logger.info('\n📦 Flutter 프로젝트를 생성하는 중...');
      final projectPath = await FlutterRunner.createProject(
        projectName: projectName,
        packageId: packageId,
        platforms: platforms,
      );

      if (projectPath == null) {
        logger.err('❌ Flutter 프로젝트 생성에 실패했습니다.');
        exit(1);
      }

      logger.success('✅ Flutter 프로젝트가 생성되었습니다: $projectPath');

      // 5. 템플릿 기반으로 프로젝트 구조 생성
      logger.info('\n🔧 프로젝트 구조를 초기화하는 중...');

      await ProjectInitializer.initialize(
        targetPath: projectPath,
        projectName: projectName,
        packageId: packageId,
        platforms: platforms,
      );

      logger.success('✅ 프로젝트 초기화가 완료되었습니다!');
      logger.info('\n📝 다음 단계:');
      logger.info('  cd $projectName');
      logger.info('  flutter pub get');
      logger.info('  flutter run');

      // 명시적으로 종료
      exit(0);
    } catch (e, stackTrace) {
      logger.err('❌ 오류 발생: $e');
      logger.detail('스택 트레이스: $stackTrace');
      exit(1);
    }
  }

  /// 프로젝트 이름 입력
  String _getProjectName() {
    final input = Input(prompt: '프로젝트 이름을 입력하세요', defaultValue: 'my_flutter_app').interact();

    if (input.trim().isEmpty) {
      logger.err('❌ 프로젝트 이름은 필수입니다.');
      exit(1);
    }

    // 프로젝트 이름 유효성 검사 (소문자, 숫자, 언더스코어만 허용)
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(input.trim())) {
      logger.err('❌ 프로젝트 이름은 소문자로 시작하고, 소문자/숫자/언더스코어만 사용할 수 있습니다.');
      exit(1);
    }

    return input.trim();
  }

  /// 패키지 ID 입력
  String _getPackageId() {
    final input = Input(
      prompt: '패키지 ID를 입력하세요 (예: com.naeil.flutter)',
      defaultValue: 'com.example.app',
    ).interact();

    if (input.trim().isEmpty) {
      logger.err('❌ 패키지 ID는 필수입니다.');
      exit(1);
    }

    // 패키지 ID 유효성 검사 (도메인 형식)
    if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$').hasMatch(input.trim())) {
      logger.err('❌ 패키지 ID는 점(.)으로 구분된 도메인 형식이어야 합니다 (예: com.naeil.flutter)');
      exit(1);
    }

    return input.trim();
  }

  /// 플랫폼 선택 (멀티셀렉트)
  List<String> _selectPlatforms() {
    logger.info('\n플랫폼을 선택하세요 (스페이스바로 선택, Enter로 확인):');

    final platforms = ['android', 'ios', 'web', 'windows', 'macos', 'linux'];

    final selected = MultiSelect(
      prompt: '플랫폼 선택 (스페이스바로 선택, Enter로 확인)',
      options: platforms,
    ).interact();

    if (selected.isEmpty) {
      logger.err('❌ 최소 하나의 플랫폼을 선택해야 합니다.');
      exit(1);
    }

    return selected.map((index) => platforms[index]).toList();
  }
}
