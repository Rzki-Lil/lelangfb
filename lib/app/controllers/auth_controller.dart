import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final isLoggedIn = false.obs;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    signInOption: SignInOption.standard,
  );
  RxBool rememberMe = false.obs;
  RxBool isGuest = false.obs;

  Stream<User?> get streamAuthStatus => _auth.authStateChanges();

  Rx<User?> currentUser = Rx<User?>(null);
  RxBool isEmailVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("AuthController onInit called");
    currentUser = Rx<User?>(_auth.currentUser);
    currentUser.bindStream(streamAuthStatus);
    ever(currentUser, _setInitialScreen);
    loadRememberMeStatus();
    checkGuestStatus();
    checkEmailVerificationStatus();

    // Modifikasi auth state listener untuk tidak clear login info
    _auth.authStateChanges().listen((User? user) {
      isLoggedIn.value = user != null;
      if (user != null) {
        Get.offAllNamed(Routes.HOME);
      } else {
        // Hanya navigasi ke login tanpa clear login info
        Get.offAllNamed(Routes.LOGIN);
      }
    });
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
        if (_auth.currentUser == null) {
          login(email, password);
        }
      }
    } else {
      clearLoginInfo();
      if (_auth.currentUser != null) {
        logout();
      }
    }
  }

  Future<void> createOrUpdateUserData(User user) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Check if user document exists
      final docSnapshot = await userRef.get();

      if (!docSnapshot.exists) {
        // Create new user document if it doesn't exist
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'User',
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'phoneNumber': user.phoneNumber,
          'isVerified': user.emailVerified,
          'provider': user.providerData.map((e) => e.providerId).toList(),
          // Additional user data
          'bio': '',
          'location': '',
          'totalItems': 0,
          'rating': 0.0,
          'ratingCount': 0,
          'followers': 0,
          'following': 0,
        });
      } else {
        // Update existing user document
        await userRef.update({
          'email': user.email,
          'displayName': user.displayName ?? docSnapshot.get('displayName'),
          'photoURL': user.photoURL ?? docSnapshot.get('photoURL'),
          'updatedAt': FieldValue.serverTimestamp(),
          'phoneNumber': user.phoneNumber,
          'isVerified': user.emailVerified,
          'provider': user.providerData.map((e) => e.providerId).toList(),
        });
      }
    } catch (e) {
      print('Error creating/updating user data: $e');
    }
  }

  void login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        // Create or update user document after successful login
        await createOrUpdateUserData(userCredential.user!);

        printUserInfo(userCredential.user!);
        if (userCredential.user!.emailVerified) {
          if (rememberMe.value) {
            saveLoginInfo(email, password);
          }
          navigateToHome();
          Get.snackbar(
              'Berhasil', 'Masuk sebagai ${userCredential.user?.displayName}');
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
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          // Create or update user document after successful Google sign in
          await createOrUpdateUserData(user);

          printUserInfo(user);
          // Hapus clearLoginInfo di sini
          rememberMe.value = false;
          navigateToHome();
          Get.snackbar('Berhasil', 'Masuk sebagai ${user.displayName}');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
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

      await _auth.currentUser?.linkWithCredential(credential);
      Get.snackbar('Berhasil', 'Akun Google berhasil dihubungkan');
      navigateToHome();
    } catch (e) {
      print("Error saat menghubungkan akun Google: $e");
      Get.snackbar('Error', 'Gagal menghubungkan akun Google');
    }
  }

  void loginAsGuest() async {
    try {
      await _auth.signInAnonymously();
      isGuest.value = true;
      navigateToHome();
    } catch (e) {
      Get.snackbar('Error', 'Gagal masuk sebagai tamu');
    }
  }

  void checkGuestStatus() {
    isGuest.value = _auth.currentUser?.isAnonymous ?? false;
  }

  void logout() async {
    await _auth.signOut();
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
    User? user = _auth.currentUser;
    if (user != null && !user.isAnonymous) {
      await user.reload();
      isEmailVerified.value = user.emailVerified;
      print("Email verified: ${isEmailVerified.value}");
    } else {
      print("User is null or anonymous in checkEmailVerificationStatus");
    }
  }
}
