import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/signup/controllers/signup_controller.dart';
import 'package:lelang_fb/app/utils/buttons.dart';
import 'package:lelang_fb/app/utils/custom_text_field.dart';
import 'package:lelang_fb/core/assets/assets.gen.dart';
import 'package:lelang_fb/core/constants/color.dart';

class SignupView extends GetView<SignupController> {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  void _submitForm() {
    controller.signUp(nameC.text, emailC.text, passwordC.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.hijauTua),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Lelang ", style: TextStyle(color: Colors.black)),
            Text("ID", style: TextStyle(color: AppColors.hijauTua)),
          ],
        ),
        actions: [
          Assets.svg.logoLelangV2.svg(width: 40),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sign Up",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Create your Account", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 20),
              CustomTextField(
                controller: nameC,
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
                focusNode: nameFocus,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(emailFocus),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: emailC,
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                focusNode: emailFocus,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(passwordFocus),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: passwordC,
                labelText: 'Password',
                isPassword: true,
                prefixIcon: Icon(Icons.lock_outline),
                onChanged: (value) => controller.checkPasswordStrength(value),
                focusNode: passwordFocus,
                onSubmitted: (_) => _submitForm(),
              ),
              SizedBox(height: 10),
              Obx(() => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPasswordCriteriaRow('Minimum character 7',
                                controller.hasMinLength.value),
                            _buildPasswordCriteriaRow('One-uppercase character',
                                controller.hasUppercase.value),
                            _buildPasswordCriteriaRow('One-lowercase character',
                                controller.hasLowercase.value),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPasswordCriteriaRow(
                                'One-number', controller.hasNumber.value),
                            _buildPasswordCriteriaRow('One-special character',
                                controller.hasSpecialChar.value),
                          ],
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey[300],
                          ),
                        ),
                        Obx(() => Container(
                              height: 10,
                              width: MediaQuery.of(context).size.width *
                                  controller.passwordStrength.value,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: controller.passwordStrengthColor.value,
                              ),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Obx(() => Text(
                        controller.passwordStrengthText.value,
                        style: TextStyle(
                            color: controller.passwordStrengthColor.value),
                      )),
                ],
              ),
              SizedBox(height: 20),
              Button.filled(
                onPressed: _submitForm,
                label: 'Sign Up',
                color: AppColors.hijauTua,
                width: double.infinity,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have Account? ",
                      style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text("Sign in Now",
                        style: TextStyle(
                            color: AppColors.hijauTua,
                            decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordCriteriaRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_box : Icons.check_box_outline_blank,
            size: 16,
            color: isMet ? AppColors.hijauTua : Colors.grey,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
