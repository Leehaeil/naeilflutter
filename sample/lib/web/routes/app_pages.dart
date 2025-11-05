import 'package:get/get.dart';

import '../pages/splash/bindings/splash_binding.dart';
import '../pages/splash/views/splash_view.dart';
import '../pages/home/bindings/home_binding.dart';
import '../pages/home/views/home_view.dart';
import '../pages/login/bindings/login_binding.dart';
import '../pages/login/views/login_view.dart';
// NAEILMAKE: import
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage<dynamic>(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    // NAEILMAKE: routes
  ];
}

