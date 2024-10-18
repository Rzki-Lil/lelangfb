import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';

class AuthController extends GetxController {
  //TODO: Implement AuthController
  FirebaseAuth auth = FirebaseAuth.instance;

  // Menggunakan getter untuk stream auth status
  Stream<User?> get streamAuthStatus => auth.authStateChanges();

  void login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.offAllNamed(Routes.HOME);
      Get.snackbar('Success', 'Logged in as ${userCredential.user?.email}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar('Error', 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Get.snackbar('Error', 'Wrong password provided.');
      } else {
        Get.snackbar('Error', e.message ?? 'An error occurred');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
    }
  }

  void logout() async {
    await auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
