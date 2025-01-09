import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';
import 'package:lelang_fb/core/constants/color.dart';

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

  void showPasswordRequirementsError() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber,
                size: 50,
              ),
              SizedBox(height: 16),
              Text(
                'Password Requirements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRequirementRow('Minimum 8 characters'),
                  _buildRequirementRow('At least one uppercase letter (A-Z)'),
                  _buildRequirementRow('At least one lowercase letter (a-z)'),
                  _buildRequirementRow('At least one number (0-9)'),
                  _buildRequirementRow(
                      'At least one special character (!@#\$&*~)'),
                ],
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hijauTua,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'I Understand',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildRequirementRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 20, color: AppColors.hijauTua),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void handleSignUpError(String error) {
    if (error.contains('PASSWORD_DOES_NOT_MEET_REQUIREMENTS')) {
      showPasswordRequirementsError();
    } else {
      // Handle other errors
      Get.snackbar(
        'Error',
        'Gagal membuat akun',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        borderRadius: 10,
      );
    }
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
        showPasswordRequirementsError();
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Set display name first
        await userCredential.user!.updateDisplayName(name);
        // Reload user to ensure we have the latest data
        await userCredential.user!.reload();
        // Send verification email
        await userCredential.user!.sendEmailVerification();

        // Pass both email and creation time to email verification
        Get.offNamed(Routes.EMAIL_VERIFICATION, arguments: {
          'email': email,
          'creationTime': userCredential.user!.metadata.creationTime!.millisecondsSinceEpoch,
          'displayName': name, // Add display name to arguments
        });
      } else {
        Get.snackbar('Error', 'Gagal membuat akun');
      }
    } catch (e) {
      handleSignUpError(e.toString());
    }
  }

  bool isPasswordValid(String password) {
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(password);
  }
}
