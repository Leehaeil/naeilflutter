import 'package:get/get.dart';
import 'package:naeil_flutter_init/mobile/pages/login/controllers/login_controller.dart';

/// 로그인 페이지 바인딩
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}

