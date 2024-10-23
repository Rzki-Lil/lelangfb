import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';
import 'dart:async';

class EmailVerificationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxString email = ''.obs;
  RxBool isEmailVerified = false.obs;
  RxInt countdown = 60.obs;
  Timer? _timer;
  // ignore: unused_field
  int? _creationTime;
  RxBool isCountdownStarted = false.obs;
  var hasShownInitialDialog = false.obs;
  var isResendButtonPressed = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      email.value = Get.arguments['email'] ?? '';
      _creationTime = Get.arguments['creationTime'];
    } else {
      email.value = _auth.currentUser?.email ?? '';
    }
    if (!isCountdownStarted.value) {
      startCountdown();
      isCountdownStarted.value = true;
    }
    checkEmailVerification();
  }

  void startCountdown() {
    if (_timer != null && _timer!.isActive) return;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
        deleteUnverifiedAccount();
      }
    });
  }

  Future<void> checkEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      isEmailVerified.value = user.emailVerified;
      if (isEmailVerified.value) {
        _timer?.cancel();
        Get.snackbar('Sukses', 'Email berhasil diverifikasi');
        await Future.delayed(Duration(seconds: 2)); 
        Get.offAllNamed(Routes.HOME);
      } else {
      
        await Future.delayed(Duration(seconds: 5));
        checkEmailVerification();
      }
    }
  }

  Future<void> resendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      Get.snackbar('Sukses', 'Email verifikasi telah dikirim ulang');
      countdown.value = 60; 
      isResendButtonPressed.value = true;
    }
  }

  Future<void> deleteUnverifiedAccount() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.delete();
      Get.snackbar('Peringatan', 'Akun dihapus karena tidak diverifikasi');
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
