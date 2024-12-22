import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/controllers/auth_controller.dart';

class LoginController extends GetxController {
  //TODO: Implement LoginController

  final count = 0.obs;

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadLoginInfo();
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }

  void increment() => count.value++;

  final AuthController authC = Get.find<AuthController>();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final isLoading = true.obs;

  void loadLoginInfo() async {
    isLoading.value = true;
    Map<String, String> loginInfo = await authC.getLoginInfo();
    emailC.text = loginInfo['email'] ?? '';
    passwordC.text = loginInfo['password'] ?? '';
    isLoading.value = false;
  }

  void handleLogin() {
    Get.focusScope?.unfocus(); // Close the keyboard
    authC.login(emailC.text, passwordC.text);
  }

  void onCloseButtonPressed() {
    print("Tombol X ditekan");
  }

  void onRememberMeChanged(bool? value) {
    authC.rememberMe.value = value ?? false;
    if (!authC.rememberMe.value) {
      authC.clearLoginInfo();
    }
  }

  void signInWithGoogle() {
    authC.signInWithGoogle();
  }

  void loginAsGuest() {
    authC.loginAsGuest();
  }
}
