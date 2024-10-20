import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  RxBool rememberMe = false.obs;
  RxBool isGuest = false.obs;

  // Menggunakan getter untuk stream auth status
  Stream<User?> get streamAuthStatus => auth.authStateChanges();

  @override
  void onInit() {
    super.onInit();
    loadRememberMeStatus();
    checkGuestStatus();
  }

  void loadRememberMeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    rememberMe.value = prefs.getBool('rememberMe') ?? false;
    if (rememberMe.value) {
      String? email = prefs.getString('email');
      String? password = prefs.getString('password');
      if (email != null && password != null) {
        if (auth.currentUser == null) {
          login(email, password);
        }
      }
    }
  }

  void login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (rememberMe.value) {
        saveLoginInfo(email, password);
      } else {
        clearLoginInfo();
      }
      Get.offAllNamed(Routes.HOME);
      Get.snackbar('Berhasil', 'Masuk sebagai ${userCredential.user?.email}');
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      switch (e.code) {
        case 'user-not-found':
          Get.snackbar('Error', 'Tidak ada pengguna dengan email tersebut.');
          break;
        case 'wrong-password':
          Get.snackbar('Error', 'Password yang dimasukkan salah.');
          break;
        case 'invalid-credential':
          Get.snackbar('Error', 'Email atau password salah.');
          break;
        case 'invalid-email':
          Get.snackbar('Error', 'Format email tidak valid.');
          break;
        case 'too-many-requests':
          Get.snackbar('Error', 'Terlalu banyak percobaan. Coba lagi nanti.');
          break;
        default:
          Get.snackbar('Error', e.message ?? 'Terjadi kesalahan saat login');
      }
    } catch (e) {
      print("Unexpected error: $e");
      Get.snackbar('Error', 'Terjadi kesalahan yang tidak terduga');
    }
  }

  void loginAsGuest() async {
    try {
      await auth.signInAnonymously();
      isGuest.value = true;
      Get.offAllNamed(Routes.HOME);
      Get.snackbar('Berhasil', 'Masuk sebagai Tamu');
    } catch (e) {
      print("Error saat login sebagai tamu: $e");
      Get.snackbar('Error', 'Gagal masuk sebagai Tamu');
    }
  }

  void checkGuestStatus() {
    isGuest.value = auth.currentUser?.isAnonymous ?? false;
  }

  void logout() async {
    await auth.signOut();
    clearLoginInfo();
    rememberMe.value = false;
    isGuest.value = false;
    Get.offAllNamed(Routes.LOGIN);
  }

  void saveLoginInfo(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setBool('rememberMe', true);
  }

  void clearLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('rememberMe');
  }

  Future<Map<String, String>> getLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    String password = prefs.getString('password') ?? '';
    return {'email': email, 'password': password};
  }
}
