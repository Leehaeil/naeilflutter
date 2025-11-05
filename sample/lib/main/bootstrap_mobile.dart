import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:naeil_flutter_init/app/routes/app_pages.dart';
import 'package:naeil_flutter_init/app/services/auth_service.dart';
import 'package:naeil_flutter_init/app/theme/custom_theme.dart';

@pragma('vm:entry-point')
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // AuthService 초기화 및 주입
  Get.put(AuthService(), permanent: true);

  // 인증 상태 확인 (토큰 확인 및 사용자 정보 로드)
  await AuthService.to.init();

  runApp(const MobileApp());
}

class MobileApp extends StatelessWidget {
  const MobileApp();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'naeil_flutter_init',
          debugShowCheckedModeBanner: false,
          theme: CustomTheme.lightTheme,
          initialRoute: Routes.splash,
          getPages: AppPages.routes,
          builder: (context, child) {
            return Material(
              color: CustomTheme.lightTheme.scaffoldBackgroundColor,
              child: SafeArea(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child!,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
