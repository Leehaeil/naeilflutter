import 'dart:io';
import 'package:interact_cli/interact_cli.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Flutter 페이지 추가 명령어
class FlutterAddPageCommand {
  final Logger logger;

  FlutterAddPageCommand(this.logger);

  /// 명령어 실행
  Future<void> run() async {
    try {
      logger.info('📄 Flutter 페이지를 추가합니다...\n');

      // 현재 작업 디렉토리 확인
      final currentDir = Directory.current;
      final pubspecFile = File(path.join(currentDir.path, 'pubspec.yaml'));

      if (!pubspecFile.existsSync()) {
        logger.err('❌ Flutter 프로젝트가 아닙니다. pubspec.yaml 파일을 찾을 수 없습니다.');
        exit(1);
      }

      // 1. 웹 플랫폼 활성화 여부 확인
      final isWebEnabled = _checkWebPlatform(currentDir);
      logger.detail('웹 플랫폼 활성화: ${isWebEnabled ? "예" : "아니오"}');

      // 2. 플랫폼 선택 (웹이 활성화되어 있을 때만)
      String platform = 'app';
      if (isWebEnabled) {
        platform = _selectPlatform();
        logger.detail('선택된 플랫폼: $platform');
      }

      // 3. 페이지 이름 입력
      final pageName = _getPageName();
      logger.detail('페이지 이름: $pageName');

      // 4. 컨트롤러 사용 여부 확인
      final useController = _askUseController();
      logger.detail('컨트롤러 사용: ${useController ? "예" : "아니오"}');

      // 5. 파일 생성
      await _createPageFiles(
        currentDir: currentDir,
        platform: platform,
        pageName: pageName,
        useController: useController,
      );

      logger.success('✅ 페이지가 성공적으로 추가되었습니다!');
      logger.info('\n📝 다음 단계:');
      logger.info('  - 라우팅 설정을 확인하세요: lib/app/routes/app_pages.dart');
      logger.info('  - 생성된 파일을 확인하세요: lib/app/pages/$pageName/');

      exit(0);
    } catch (e, stackTrace) {
      logger.err('❌ 오류 발생: $e');
      logger.detail('스택 트레이스: $stackTrace');
      exit(1);
    }
  }

  /// 웹 플랫폼 활성화 여부 확인
  bool _checkWebPlatform(Directory projectDir) {
    // 방법 1: web 폴더 존재 확인
    final webDir = Directory(path.join(projectDir.path, 'web'));
    if (webDir.existsSync()) {
      return true;
    }

    // 방법 2: pubspec.yaml에서 flutter 플랫폼 확인
    final pubspecFile = File(path.join(projectDir.path, 'pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      final content = pubspecFile.readAsStringSync();
      // web 관련 설정이 있는지 확인
      if (content.contains('web') || content.contains('platforms:')) {
        return true;
      }
    }

    return false;
  }

  /// 플랫폼 선택
  String _selectPlatform() {
    logger.info('\n플랫폼을 선택하세요:');

    final platform = Select(
      prompt: '어느 플랫폼에 추가하시겠습니까?',
      options: ['app', 'web'],
    ).interact();

    return platform == 0 ? 'app' : 'web';
  }

  /// 페이지 이름 입력
  String _getPageName() {
    final input = Input(
      prompt: '페이지 이름을 입력하세요 (예: profile, settings)',
    ).interact();

    if (input.trim().isEmpty) {
      logger.err('❌ 페이지 이름은 필수입니다.');
      exit(1);
    }

    // 페이지 이름 유효성 검사 (소문자, 숫자, 언더스코어만 허용)
    final pageName = input.trim().toLowerCase();
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(pageName)) {
      logger.err('❌ 페이지 이름은 소문자로 시작하고, 소문자/숫자/언더스코어만 사용할 수 있습니다.');
      exit(1);
    }

    return pageName;
  }

  /// 컨트롤러 사용 여부 확인
  bool _askUseController() {
    final useController = Confirm(
      prompt: '컨트롤러를 사용하시겠습니까?',
      defaultValue: true,
    ).interact();

    return useController;
  }

  /// 페이지 파일 생성
  Future<void> _createPageFiles({
    required Directory currentDir,
    required String platform,
    required String pageName,
    required bool useController,
  }) async {
    // 페이지 경로 결정
    final basePath = platform == 'web'
        ? path.join(currentDir.path, 'lib', 'web', 'pages')
        : path.join(currentDir.path, 'lib', 'app', 'pages');

    final pageDir = Directory(path.join(basePath, pageName));
    final controllersDir = Directory(path.join(pageDir.path, 'controllers'));
    final viewsDir = Directory(path.join(pageDir.path, 'views'));
    final bindingsDir = Directory(path.join(pageDir.path, 'bindings'));

    // 디렉토리 생성
    if (useController) {
      controllersDir.createSync(recursive: true);
      bindingsDir.createSync(recursive: true);
    }
    viewsDir.createSync(recursive: true);

    // 파일명 (snake_case)
    final className = _toPascalCase(pageName);
    final fileName = pageName;

    // View 파일 생성
    await _createViewFile(
      viewsDir: viewsDir,
      fileName: fileName,
      className: className,
      useController: useController,
    );

    // Controller 파일 생성 (사용 시)
    if (useController) {
      await _createControllerFile(
        controllersDir: controllersDir,
        fileName: fileName,
        className: className,
      );

      // Binding 파일 생성
      await _createBindingFile(
        bindingsDir: bindingsDir,
        fileName: fileName,
        className: className,
      );
    }

    // 라우팅 파일 업데이트
    await _updateRoutes(
      currentDir: currentDir,
      platform: platform,
      pageName: pageName,
      className: className,
      useController: useController,
    );
  }

  /// View 파일 생성
  Future<void> _createViewFile({
    required Directory viewsDir,
    required String fileName,
    required String className,
    required bool useController,
  }) async {
    final viewFile = File(path.join(viewsDir.path, '${fileName}_view.dart'));
    final viewContent = useController
        ? '''import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/${fileName}_controller.dart';

class ${className}View extends GetView<${className}Controller> {
  const ${className}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${className}View'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '${className}View 동작 중',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );
  }
}
'''
        : '''import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ${className}View extends StatelessWidget {
  const ${className}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${className}View'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '${className}View 동작 중',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );
  }
}
''';

    await viewFile.writeAsString(viewContent);
    logger.detail('✅ View 파일 생성: ${viewFile.path}');
  }

  /// Controller 파일 생성
  Future<void> _createControllerFile({
    required Directory controllersDir,
    required String fileName,
    required String className,
  }) async {
    final controllerFile = File(
      path.join(controllersDir.path, '${fileName}_controller.dart'),
    );
    final controllerContent = '''import 'package:get/get.dart';

class ${className}Controller extends GetxController {
  // TODO: ${className}Controller 구현
}
''';

    await controllerFile.writeAsString(controllerContent);
    logger.detail('✅ Controller 파일 생성: ${controllerFile.path}');
  }

  /// Binding 파일 생성
  Future<void> _createBindingFile({
    required Directory bindingsDir,
    required String fileName,
    required String className,
  }) async {
    final bindingFile = File(
      path.join(bindingsDir.path, '${fileName}_binding.dart'),
    );
    final bindingContent = '''import 'package:get/get.dart';

import '../controllers/${fileName}_controller.dart';

class ${className}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${className}Controller>(() => ${className}Controller());
  }
}
''';

    await bindingFile.writeAsString(bindingContent);
    logger.detail('✅ Binding 파일 생성: ${bindingFile.path}');
  }

  /// 라우팅 파일 업데이트
  Future<void> _updateRoutes({
    required Directory currentDir,
    required String platform,
    required String pageName,
    required String className,
    required bool useController,
  }) async {
    // 라우팅 파일 경로 결정
    final routesDir = platform == 'web'
        ? path.join(currentDir.path, 'lib', 'web', 'routes')
        : path.join(currentDir.path, 'lib', 'app', 'routes');

    final appRoutesFile = File(path.join(routesDir, 'app_routes.dart'));
    final appPagesFile = File(path.join(routesDir, 'app_pages.dart'));

    if (!appRoutesFile.existsSync() || !appPagesFile.existsSync()) {
      logger.warn('⚠️  라우팅 파일을 찾을 수 없습니다. 수동으로 추가해주세요.');
      return;
    }

    // app_routes.dart 업데이트
    await _updateAppRoutes(appRoutesFile, pageName);

    // app_pages.dart 업데이트
    await _updateAppPages(
      appPagesFile,
      platform: platform,
      pageName: pageName,
      className: className,
      useController: useController,
    );

    logger.detail('✅ 라우팅 파일 업데이트 완료');
  }

  /// app_routes.dart 업데이트
  Future<void> _updateAppRoutes(File appRoutesFile, String pageName) async {
    var content = await appRoutesFile.readAsString();

    // NAEILMAKE: route-constants 주석 찾기
    if (content.contains('// NAEILMAKE: route-constants')) {
      final routeConstant = '  static const $pageName = _Paths.$pageName;';
      content = content.replaceFirst(
        '  // NAEILMAKE: route-constants',
        '$routeConstant\n  // NAEILMAKE: route-constants',
      );
    }

    // NAEILMAKE: path-constants 주석 찾기
    if (content.contains('// NAEILMAKE: path-constants')) {
      final pathConstant = "  static const $pageName = '/$pageName';";
      content = content.replaceFirst(
        '  // NAEILMAKE: path-constants',
        '$pathConstant\n  // NAEILMAKE: path-constants',
      );
    }

    // 최종 내용 저장
    await appRoutesFile.writeAsString(content);
  }

  /// app_pages.dart 업데이트
  Future<void> _updateAppPages(
    File appPagesFile, {
    required String platform,
    required String pageName,
    required String className,
    required bool useController,
  }) async {
    var content = await appPagesFile.readAsString();

    // import 추가
    final importPath = '../pages/$pageName/views/${pageName}_view.dart';

    if (!content.contains(importPath)) {
      final importStatement = "import '$importPath';";
      content = content.replaceFirst(
        '// NAEILMAKE: import',
        "$importStatement\n// NAEILMAKE: import",
      );
    }

    // Binding import 추가 (사용 시)
    if (useController) {
      final bindingImportPath = '../pages/$pageName/bindings/${pageName}_binding.dart';

      if (!content.contains(bindingImportPath)) {
        final bindingImportStatement = "import '$bindingImportPath';";
        content = content.replaceFirst(
          '// NAEILMAKE: import',
          "$bindingImportStatement\n// NAEILMAKE: import",
        );
      }
    }

    // route 추가
    if (content.contains('// NAEILMAKE: routes')) {
      final routeConstant = 'Routes.$pageName';
      final routeCode = useController
          ? '''    GetPage<dynamic>(
      name: $routeConstant,
      page: () => const ${className}View(),
      binding: ${className}Binding(),
    ),
    // NAEILMAKE: routes'''
          : '''    GetPage<dynamic>(
      name: $routeConstant,
      page: () => const ${className}View(),
    ),
    // NAEILMAKE: routes''';

      content = content.replaceFirst(
        '    // NAEILMAKE: routes',
        routeCode,
      );
    }

    // 최종 내용 저장
    await appPagesFile.writeAsString(content);
  }

  /// snake_case를 PascalCase로 변환
  String _toPascalCase(String snakeCase) {
    return snakeCase
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join();
  }
}

