import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/email_verification_controller.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:lelang_fb/app/utils/buttons.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<EmailVerificationController>(
      init: EmailVerificationController(),
      builder: (controller) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!controller.hasShownInitialDialog.value) {
            Get.dialog(
              AlertDialog(
                title: Text('Perhatian'),
                content: Text('Pastikan email/nomor telepon yang Anda gunakan sesuai dengan akun yang sudah didaftarkan.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Get.back();
                      controller.hasShownInitialDialog.value = true;
                    },
                  ),
                ],
              ),
              barrierDismissible: false,
            );
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Verifikasi Email'),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Get.offAllNamed(Routes.LOGIN),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, size: 80, color: AppColors.hijauTua),
                SizedBox(height: 20),
                Text(
                  'Verifikasi Email Anda',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Kami telah mengirim link verifikasi ke ${controller.email.value}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Waktu klik link verifikasi ${controller.countdown.value} detik',
                  style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.hijauTua),
                ),
                SizedBox(height: 20),
                Button.filled(
                  onPressed: () => controller.checkEmailVerification(),
                  label: 'Saya sudah verifikasi email',
                  color: AppColors.hijauTua,
                  width: double.infinity,
                ),
                SizedBox(height: 10),
                Obx(() => Button.outlined(
                  onPressed: () => controller.resendVerificationEmail(),
                  label: 'Kirim ulang email verifikasi',
                  borderColor: AppColors.hijauTua,
                  textColor: AppColors.hijauTua,
                  width: double.infinity,
                  showBorder: controller.isResendButtonPressed.value,
                  borderWidth: 2.0,  // Atur ketebalan outline di sini
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
