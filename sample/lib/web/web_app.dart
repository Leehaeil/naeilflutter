import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:naeil_flutter_init/web/routes/app_pages.dart';
import 'package:naeil_flutter_init/web/theme/custom_theme.dart';

/// 웹 전용 앱 위젯
class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080), // 웹 기본 디자인 사이즈
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
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
