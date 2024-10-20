import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';

class SignupController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isPasswordVisible = false.obs;
  RxDouble passwordStrength = 0.0.obs;
  Rx<Color> passwordStrengthColor = Colors.grey.obs;
  RxString passwordStrengthText = ''.obs;
  RxBool hasMinLength = false.obs;
  RxBool hasUppercase = false.obs;
  RxBool hasLowercase = false.obs;
  RxBool hasNumber = false.obs;
  RxBool hasSpecialChar = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void checkPasswordStrength(String password) {
    if (password.isEmpty) {
      resetPasswordStrength();
      return;
    }

    hasMinLength.value = password.length >= 7;
    hasUppercase.value = password.contains(RegExp(r'[A-Z]'));
    hasLowercase.value = password.contains(RegExp(r'[a-z]'));
    hasNumber.value = password.contains(RegExp(r'[0-9]'));
    hasSpecialChar.value = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasMinLength.value) strength++;
    if (hasUppercase.value) strength++;
    if (hasLowercase.value) strength++;
    if (hasNumber.value) strength++;
    if (hasSpecialChar.value) strength++;

    passwordStrength.value = strength / 5;

    if (passwordStrength.value <= 0.2) {
      passwordStrengthColor.value = Colors.red;
      passwordStrengthText.value = 'Very Weak';
    } else if (passwordStrength.value <= 0.4) {
      passwordStrengthColor.value = Colors.orange;
      passwordStrengthText.value = 'Weak';
    } else if (passwordStrength.value <= 0.6) {
      passwordStrengthColor.value = Colors.yellow;
      passwordStrengthText.value = 'Medium';
    } else if (passwordStrength.value <= 0.8) {
      passwordStrengthColor.value = Colors.lightGreen;
      passwordStrengthText.value = 'Strong';
    } else {
      passwordStrengthColor.value = Colors.green;
      passwordStrengthText.value = 'Very Strong';
    }
  }

  void resetPasswordStrength() {
    passwordStrength.value = 0.0;
    passwordStrengthColor.value = Colors.grey;
    passwordStrengthText.value = '';
    hasMinLength.value = false;
    hasUppercase.value = false;
    hasLowercase.value = false;
    hasNumber.value = false;
    hasSpecialChar.value = false;
  }

  Future<void> signUp(String name, String email, String password) async {
    try {
      // Validasi nama
      if (name.isEmpty) {
        Get.snackbar('Error', 'Nama tidak boleh kosong.');
        return;
      }

      if (email.isEmpty) {
        Get.snackbar('Error', 'Email tidak boleh kosong.');
        return;
      } else if (!GetUtils.isEmail(email)) {
        Get.snackbar('Error', 'Format email tidak valid.');
        return;
      }

      if (passwordStrength.value < 0.6) {
        Get.snackbar(
            'Error', 'Password terlalu lemah. Silakan perkuat password Anda.');
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.sendEmailVerification();

        Get.offNamed(Routes.EMAIL_VERIFICATION, arguments: {
          'email': email,
          'creationTime': userCredential.user!.metadata.creationTime!.millisecondsSinceEpoch,
        });
      } else {
        Get.snackbar('Error', 'Gagal membuat akun');
      }
    } catch (e) {
      print("Unexpected error: $e");
      Get.snackbar('Error', 'Terjadi kesalahan yang tidak terduga');
    }
  }
}
