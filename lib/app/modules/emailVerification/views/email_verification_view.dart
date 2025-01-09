import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/email_verification_controller.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:lelang_fb/app/utils/buttons.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({Key? key}) : super(key: key);

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownDialog) {
        _hasShownDialog = true;
        _showVerificationDialog();
      }
    });
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 50, color: AppColors.hijauTua),
                SizedBox(height: 16),
                Text(
                  'Email Verification',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Please ensure that the email address you provided matches your Google Gmail account for proper verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.hijauTua,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('I Understand',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetX<EmailVerificationController>(
      init: EmailVerificationController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Email Verification',
              style: TextStyle(color: Colors.black87),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.hijauTua),
              onPressed: () => Get.offAllNamed(Routes.LOGIN),
            ),
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.hijauTua.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 80,
                      color: AppColors.hijauTua,
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Check Your Email',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'We\'ve sent a verification link to:',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    controller.email.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.hijauTua,
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, color: Colors.amber[700]),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Link expires in ${controller.countdown.value} seconds',
                            style: TextStyle(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  Button.filled(
                    onPressed: controller.isCheckingVerification.value
                        ? null // Disable button while checking
                        : () => controller.checkEmailVerification(),
                    label: controller.isCheckingVerification.value
                        ? 'Memeriksa...'
                        : 'Saya sudah verifikasi email',
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
                        borderWidth: 2.0, // Atur ketebalan outline di sini
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
