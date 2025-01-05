import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'package:lelang_fb/app/controllers/auth_controller.dart';
import 'package:lelang_fb/app/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Get.put(AuthController(), permanent: true);

  // Check if user was previously logged in
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool wasLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(wasLoggedIn: wasLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool wasLoggedIn;
  MyApp({this.wasLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lelang FB',
      theme: AppTheme.lightTheme,
      getPages: AppPages.routes,
      initialRoute: wasLoggedIn ? Routes.HOME : Routes.SPLASH,
    );
  }
}
