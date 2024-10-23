import 'package:get/get.dart';
import 'package:lelang_fb/app/controllers/auth_controller.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';

class SplashController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    print("SplashController onInit called");
    Future.delayed(Duration(seconds: 3), () {
      checkUserStatus();
    });
  }

  void checkUserStatus() {
    print("Checking user status...");
    print("Current user: ${authController.currentUser.value?.email}");
    print("Is email verified: ${authController.isEmailVerified.value}");
    print("Is guest: ${authController.isGuest.value}");
    print("Remember me: ${authController.rememberMe.value}");

    if (authController.currentUser.value == null) {
      print("User is null, navigating to login");
      Get.offAllNamed(Routes.LOGIN);
    } else {
      print("User is not null");
      if (authController.isEmailVerified.value ||
          authController.isGuest.value) {
        print("User is verified or guest, navigating to home");
        Get.offAllNamed(Routes.HOME);
      } else {
        print("User is not verified, navigating to email verification");
        Get.offAllNamed(Routes.EMAIL_VERIFICATION);
      }
    }
  }
}
