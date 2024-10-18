import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/route_manager.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/controllers/auth_controller.dart';
import 'package:lelang_fb/app/utils/loading.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final authC = Get.put(AuthController(), permanent: true);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authC.streamAuthStatus,
      builder: (context, snapshot) {
        print(snapshot);
        if (snapshot.connectionState == ConnectionState.active) {
          return GetMaterialApp(
            title: "testkasi dua",
            initialRoute: snapshot.data != null ? Routes.HOME : Routes.LOGIN,
            getPages: AppPages.routes,
            debugShowCheckedModeBanner: false,
          );
        }
        return LoadingView();
      },
    );
  }
}
