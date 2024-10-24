import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;
  var message = ''.obs;
  var isEmailSelected = true.obs;
  var isEmailValid = false.obs;

  RxBool isPasswordVisible = false.obs;

  var hasShownInitialDialog = false.obs;

  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<bool> checkEmailRegistered(String email) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: "incorrect_password");
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false;
      } else if (e.code == 'wrong-password') {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<void> passwordReset() async {
    isLoading.value = true;
    String email = emailController.text.trim();
    bool isRegistered = await checkEmailRegistered(email);
    if (!isRegistered) {
      message.value = 'Email tidak terdaftar di aplikasi.';
      isLoading.value = false;
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      message.value = 'Email reset password telah dikirim ke $email';
      isEmailValid.value = true;
    } catch (e) {
      print(e);
      message.value = 'Terjadi kesalahan saat mengirim email reset password.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPasswordWithPhone(String phoneNumber) async {
    isLoading.value = true;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          message.value = 'Verifikasi gagal: ${e.message}';
        },
        codeSent: (String verificationId, int? resendToken) {
          message.value = 'Kode verifikasi telah dikirim ke $phoneNumber';
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      message.value = 'Gagal mengirim kode verifikasi: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleResetMethod() {
    isEmailSelected.toggle();
  }
}
