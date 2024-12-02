import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ProfileView'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Get.defaultDialog(
                title: "Logout",
                middleText: "Are you sure you want to logout?",
                textCancel: "Cancel",
                textConfirm: "Logout",
                confirmTextColor: Colors.white,
                onConfirm: () {
                  authC.logout();
                  Get.offAllNamed('/login');
                },
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'ProfileView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
