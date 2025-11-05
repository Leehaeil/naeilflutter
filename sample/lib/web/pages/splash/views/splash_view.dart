import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SplashView'), centerTitle: true),
      body: Center(child: Text('SplashView 동작 중 (웹)', style: TextStyle(fontSize: 20.sp))),
    );
  }
}

