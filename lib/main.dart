import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/controllers/auth_controller.dart';
import 'package:lelang_fb/app/utils/app_theme.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController(), permanent: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lelang FB',
      theme: AppTheme.lightTheme,
      getPages: AppPages.routes,
      initialRoute: Routes.SPLASH,
    );
  }
}
