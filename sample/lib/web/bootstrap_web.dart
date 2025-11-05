import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naeil_flutter_init/web/services/auth_service.dart';
import 'package:naeil_flutter_init/web/web_app.dart';

@pragma('vm:entry-point')
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AuthService 초기화 및 주입
  Get.put(AuthService(), permanent: true);

  // 인증 상태 확인 (토큰 확인 및 사용자 정보 로드)
  await AuthService.to.init();

  runApp(const WebApp());
}

