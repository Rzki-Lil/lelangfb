import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/constants/color.dart';
import '../controllers/login_controller.dart';
import 'package:lelang_fb/app/controllers/auth_controller.dart';

class LoginView extends GetView<LoginController> {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final authC = Get.find<AuthController>(); // Mendapatkan instance AuthController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Assets.svg.logoLelangV2.svg(width: 40),
            SizedBox(width: 10),
            Text(
              "Lelang ",
              style: TextStyle(fontFamily: 'MotivaSansBold'),
            ),
            Text(
              "ID",
              style: TextStyle(
                fontFamily: 'MotivaSansBold',
                fontWeight: FontWeight.bold,
                color: AppColors.hijauTua,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                print("dsada");
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.hijauTua,
                ),
                child: Center(
                  child: Text(
                    "X",
                    style: TextStyle(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailC,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordC,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: ()=> authC.login(emailC.text, passwordC.text),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
