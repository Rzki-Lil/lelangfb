import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
        title: const Text('LoginView'),
        centerTitle: true,
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
