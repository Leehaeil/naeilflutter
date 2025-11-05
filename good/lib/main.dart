import 'package:wjf_sj/main/bootstrap_mobile.dart'
    if (dart.library.html) 'package:wjf_sj/web/bootstrap_web.dart'
    as app;

@pragma('vm:entry-point')
void main() {
  app.bootstrap();
}
