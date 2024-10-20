import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/constants/color.dart';
import '../controllers/login_controller.dart';
import 'package:lelang_fb/app/controllers/auth_controller.dart';
import 'package:lelang_fb/app/utils/buttons.dart';
import 'package:lelang_fb/app/utils/custom_text_field.dart';

class LoginView extends GetView<LoginController> {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final authC = Get.find<AuthController>();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadLoginInfo();
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Assets.svg.logoLelangV2.svg(width: 40),
                  SizedBox(width: 10),
                  Text(
                    "Lelang ",
                    style: TextStyle(
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "ID",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.hijauTua,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  print("Tombol X ditekan");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hijauTua,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  minimumSize: Size(40, 35),
                  padding: EdgeInsets.zero, // Menghilangkan padding default
                ),
                child: Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 30.0,
            right: 30.0,
            top: 30.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Log in",
                style: TextStyle(

                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Selamat Datang di Lelang ID",
                style: TextStyle(
                     fontSize: 15, color: Colors.grey),
              ),
              SizedBox(height: 24),
              CustomTextField(
                controller: emailC,
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                height: 50,
                focusNode: emailFocus, 
                onSubmitted: (_) => FocusScope.of(context).requestFocus(passwordFocus), 
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: passwordC,
                labelText: 'Password',
                isPassword: true,
                prefixIcon: Icon(Icons.lock),
                height: 50,
                focusNode: passwordFocus, 
                onSubmitted: (_) => _handleLogin(context), 
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Transform.translate(
                    offset: Offset(-10, 0),
                    child: Obx(() => Container(
                          child: Checkbox(
                            value: authC.rememberMe.value,
                            onChanged: (value) {
                              authC.rememberMe.value = value!;
                            },
                            activeColor: AppColors.hijauTua,
                            side: BorderSide(color: Colors.grey),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )),
                  ),
                  Transform.translate(
                    offset: Offset(-40, 0),
                    child: Text(
                      "Remember me",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Lupa password diklik");
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.hijauTua,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Button.filled(
                onPressed: () => _handleLogin(context), 
                label: 'Log in',
                color: AppColors.hijauTua,
                width: double.infinity,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.SIGNUP);
                      print("Sign up now diklik");
                    },
                    child: Text(
                      "Sign up now",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.hijauTua,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.hijauTua,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Or Sign in with",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Button.outlined(
                      onPressed: () {
                        authC.signInWithGoogle();
                      },
                      label: 'Google',
                      color: Colors.white,
                      textColor: Colors.black,
                      borderColor: Colors.grey,
                      fontSize: 17,
                      icon: Image.asset('assets/logo/google.png', height: 24),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Button.outlined(
                      onPressed: () {
                        authC.loginAsGuest();
                      },
                      label: 'Guest',
                      color: Colors.white,
                      fontSize: 17,
                      textColor: Colors.black,
                      borderColor: Colors.grey,
                      icon: Icon(Icons.person_outline_rounded, color: Colors.black, size: 30),
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loadLoginInfo() async {
    Map<String, String> loginInfo = await authC.getLoginInfo();
    emailC.text = loginInfo['email'] ?? '';
    passwordC.text = loginInfo['password'] ?? '';
  }

  // Tambahkan metode ini
  void _handleLogin(BuildContext context) {
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();
    // Panggil metode login
    authC.login(emailC.text, passwordC.text);
  }
}
