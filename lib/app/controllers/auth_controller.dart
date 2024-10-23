import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    signInOption: SignInOption.standard,
  );
  RxBool rememberMe = false.obs;
  RxBool isGuest = false.obs;

  // Menggunakan getter untuk stream auth status
  Stream<User?> get streamAuthStatus => auth.authStateChanges();

  Rx<User?> currentUser = Rx<User?>(null);
  RxBool isEmailVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("AuthController onInit called");
    currentUser = Rx<User?>(auth.currentUser);
    currentUser.bindStream(streamAuthStatus);
    ever(currentUser, _setInitialScreen);
    loadRememberMeStatus();
    checkGuestStatus();
    checkEmailVerificationStatus();
  }

  void _setInitialScreen(User? user) async {
    print("_setInitialScreen called with user: ${user?.email}");
    if (user != null) {
      await user.reload();
      isEmailVerified.value = user.emailVerified;
      isGuest.value = user.isAnonymous;
      printUserInfo(user);
    } else {
      print("User is null in _setInitialScreen");
    }
  }

  void navigateToHome() {
    if (Get.currentRoute != Routes.HOME) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  void navigateToEmailVerification() {
    if (Get.currentRoute != Routes.EMAIL_VERIFICATION) {
      Get.offNamed(Routes.EMAIL_VERIFICATION);
    }
  }

  void navigateToLogin() {
    if (Get.currentRoute != Routes.LOGIN) {
      Get.offAllNamed(Routes.LOGIN);
    }
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
    } else {
      // Jika Remember Me tidak diaktifkan, pastikan untuk menghapus informasi login
      clearLoginInfo();
      if (auth.currentUser != null) {
        logout();
      }
    }
  }

  void login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        printUserInfo(userCredential.user!);
        if (userCredential.user!.emailVerified) {
          if (rememberMe.value) {
            saveLoginInfo(email, password);
          } else {
            clearLoginInfo();
          }
          navigateToHome();
          Get.snackbar(
              'Berhasil', 'Masuk sebagai ${userCredential.user?.email}');
        } else {
          await userCredential.user!.sendEmailVerification();
          navigateToEmailVerification();
        }
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      if (e.code == 'user-not-found') {
        Get.snackbar('Error', 'Tidak ada pengguna dengan email tersebut.');
      } else if (e.code == 'wrong-password') {
        Get.snackbar('Error', 'Password yang dimasukkan salah.');
      } else if (e.code == 'invalid-email') {
        Get.snackbar('Error', 'Format email tidak valid.');
      } else if (e.code == 'user-disabled') {
        Get.snackbar('Error', 'Akun pengguna telah dinonaktifkan.');
      } else {
        Get.snackbar('Error', e.message ?? 'Terjadi kesalahan saat login');
      }
    } catch (e) {
      print("Unexpected error: $e");
      Get.snackbar('Error', 'Terjadi kesalahan yang tidak terduga');
    }
  }

  Future<void> signInWithGoogle({String? email}) async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      // Jika email diberikan, pastikan email Google cocok
      if (email != null && googleUser.email != email) {
        Get.snackbar(
            'Error', 'Email Google tidak cocok dengan akun yang terdaftar');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          printUserInfo(user); // Tambahkan ini
          clearLoginInfo();
          rememberMe.value = false;
          navigateToHome();
          Get.snackbar('Berhasil', 'Masuk sebagai ${user.displayName}');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // Coba menghubungkan akun Google dengan akun yang sudah ada
          await linkGoogleAccount(googleUser);
        } else {
          Get.snackbar('Error',
              e.message ?? 'Terjadi kesalahan saat login dengan Google');
        }
      }
    } catch (e) {
      print("Error saat login dengan Google: $e");
      Get.snackbar('Error', 'Gagal masuk dengan Google');
    }
  }

  Future<void> linkGoogleAccount(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.currentUser?.linkWithCredential(credential);
      Get.snackbar('Berhasil', 'Akun Google berhasil dihubungkan');
      navigateToHome();
    } catch (e) {
      print("Error saat menghubungkan akun Google: $e");
      Get.snackbar('Error', 'Gagal menghubungkan akun Google');
    }
  }

  void loginAsGuest() async {
    try {
      await auth.signInAnonymously();
      isGuest.value = true;
      navigateToHome();
    } catch (e) {
      Get.snackbar('Error', 'Gagal masuk sebagai tamu');
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
    navigateToLogin();
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
    rememberMe.value = false;
    print("Login info cleared"); // Tambahkan log ini
  }

  Future<Map<String, String>> getLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    String password = prefs.getString('password') ?? '';
    return {'email': email, 'password': password};
  }

  void printUserInfo(User user) {
    print('==== User Info ====');
    print('UID: ${user.uid}');
    print('Email: ${user.email}');
    print('Display Name: ${user.displayName}');
    print('Phone Number: ${user.phoneNumber}');
    print('Email Verified: ${user.emailVerified}');
    print('Is Anonymous: ${user.isAnonymous}');
    print(
        'Provider ID: ${user.providerData.map((e) => e.providerId).join(', ')}');
    print('Photo URL: ${user.photoURL}'); 
    print('====================');
  }

  Future<void> checkEmailVerificationStatus() async {
    User? user = auth.currentUser;
    if (user != null && !user.isAnonymous) {
      await user.reload();
      isEmailVerified.value = user.emailVerified;
      print("Email verified: ${isEmailVerified.value}");
    } else {
      print("User is null or anonymous in checkEmailVerificationStatus");
    }
  }
}
