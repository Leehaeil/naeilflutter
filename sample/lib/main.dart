import 'package:naeil_flutter_init/mobile/bootstrap_mobile.dart'
    if (dart.library.html) 'package:naeil_flutter_init/web/bootstrap_web.dart'
    as app;

@pragma('vm:entry-point')
void main() {
  app.bootstrap();
}
