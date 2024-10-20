import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/controllers/auth_controller.dart';
import 'package:lelang_fb/app/modules/emailVerification/views/email_verification_view.dart';
import 'package:lelang_fb/app/utils/loading.dart';
import 'package:lelang_fb/app/utils/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'package:lelang_fb/app/modules/home/views/home_view.dart';
import 'package:lelang_fb/app/modules/login/views/login_view.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final authController = Get.put(AuthController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lelang FB',
      theme: AppTheme.lightTheme,
      getPages: AppPages.routes,
      home: Obx(() {
        if (authController.currentUser.value == null) {
          return LoginView();
        } else {
          if (authController.isEmailVerified.value || authController.isGuest.value) {
            return HomeView();
          } else {
            return GetPage(name: Routes.EMAIL_VERIFICATION, page: () => EmailVerificationView()).page();
          }
        }
      }),
    );
  }
}
