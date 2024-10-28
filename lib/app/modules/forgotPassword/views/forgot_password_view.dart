import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/core/assets/assets.gen.dart';
import '../controllers/forgot_password_controller.dart';
import '../../../../core/constants/color.dart';
import '../../../utils/custom_text_field.dart';
import '../../../utils/buttons.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hijauTua,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  minimumSize: Size(40, 35),
                  padding: EdgeInsets.zero, // Menghilangkan padding default
                ),
                child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              ),
              Row(
                children: [
                  Text(
                    "Lelang ",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "ID",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.hijauTua,
                    ),
                  ),
                  SizedBox(width: 10),
                  Assets.svg.logoLelangV2.svg(width: 40),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Lupa Password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Pilih metode untuk menerima metode reset password',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              SizedBox(height: 12),
              Obx(() => _buildResetOption(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: 'Kirim link reset ke email Anda',
                    isSelected: controller.isEmailSelected.value,
                    onTap: controller.toggleResetMethod,
                  )),
              SizedBox(height: 16),
              Obx(() => _buildResetOption(
                    icon: Icons.phone,
                    title: 'Nomor Telepon',
                    subtitle: 'Kirim OTP ke nomor telepon Anda',
                    isSelected: !controller.isEmailSelected.value,
                    onTap: controller.toggleResetMethod,
                  )),
              SizedBox(height: 24),
              Obx(
                () => controller.isEmailSelected.value
                    ? CustomTextField(
                        controller: controller.emailController,
                        labelText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(Icons.email),
                        height: 60,
                        focusNode: emailFocus,
                      )
                    : CustomTextField(
                        controller: controller.phoneController,
                        labelText: 'Nomor Telepon',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icon(Icons.phone),
                        height: 60,
                        focusNode: phoneFocus,
                      ),
              ),
              SizedBox(height: 16),
              Obx(() => Button.filled(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            if (controller.isEmailSelected.value) {
                              await controller.passwordReset();
                            } else {
                              await controller.resetPasswordWithPhone(
                                  controller.phoneController.text);
                            }
                            if (controller.message.value.isNotEmpty) {
                              Get.snackbar('Info', controller.message.value);
                            }
                          },
                    label: controller.isLoading.value
                        ? 'Mengirim...'
                        : 'Lanjutkan',
                    color: AppColors.hijauTua,
                  )),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Ingat password Anda? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextSpan(
                          text: 'Masuk',
                          style: TextStyle(
                            color: AppColors.hijauTua,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Button.outlined(
      onPressed: onTap,
      label: title,
      borderColor: isSelected ? AppColors.hijauTua : Colors.grey,
      borderWidth: isSelected ? 3.0 : 1.0,
      height: 70,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.hijauTua.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.hijauTua : Colors.grey,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.hijauTua : Colors.grey,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.hijauTua.withOpacity(0.7)
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSelected)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle, color: AppColors.hijauTua),
            ),
        ],
      ),
    );
  }
}
