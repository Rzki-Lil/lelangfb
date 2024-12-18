import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/profile/views/transaction_view.dart';
import 'package:lelang_fb/app/utils/custom_text_field.dart';
import 'package:lelang_fb/app/utils/text.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:lelang_fb/app/utils/buttons.dart';

import '../../../../core/assets/assets.gen.dart';
import '../controllers/profile_controller.dart';

class ProfileSettingView extends GetView<ProfileController> {
  const ProfileSettingView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 70),
        child: appbarCust(title: 'Profile Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Row(
                children: [
                  Obx(
                    () => Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: controller.profile.value != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.file(controller.profile.value!,
                                      fit: BoxFit.cover))
                              : Image.asset(
                                  Assets.icons.profile.path,
                                  fit: BoxFit.contain,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.green,
                            ),
                            child: IconButton(
                              onPressed: () async {
                                await controller.pickImage();
                              },
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCust(
                        text: "Dominic Toretto",
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      Row(
                        children: [
                          TextCust(
                            text: "70% ",
                            fontSize: 16,
                            color: AppColors.kuning,
                          ),
                          TextCust(
                            text: "Profile Completness",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                      TextCust(
                          text:
                              "Complete your profile to make it easier\nfor you to user application",
                          fontSize: 12)
                    ],
                  )
                ],
              ),
            ),
            Text(
              'Detailed Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: controller.name,
              labelText: 'Name',
              textColor: Colors.black,
              prefixIcon: Icon(
                Icons.person_outlined,
                size: 34,
              ),
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: controller.email,
              labelText: 'Email',
              textColor: Colors.black,
              prefixIcon: Icon(
                Icons.email_outlined,
                size: 34,
              ),
            ),
            SizedBox(height: 15),
            Obx(
              () => TextFormField(
                controller: controller.phone,
                onChanged: (value) => controller.updateCountryCode(value),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(color: Colors.grey),
                  floatingLabelStyle: TextStyle(color: AppColors.hijauTua),
                  hintText: '+62812312322',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                        left: 2, top: 6, bottom: 2, right: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.grey[100],
                        child: Image.asset(
                          'assets/flags/${controller.countryCode.value}.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Button.filled(
              onPressed: () {},
              label: 'Save',
              fontSize: 20,
              color: AppColors.hijauTua,
            )
          ],
        ),
      ),
    );
  }
}
