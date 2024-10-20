import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'package:lelang_fb/app/controllers/auth_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authC.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to HomeView',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            if (authC.isGuest.value)
              Text(
                'You are logged in as a guest',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            else
              Text(
                'Your email is verified',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
