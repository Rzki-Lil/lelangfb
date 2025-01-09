import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/myitems/views/myitems_view.dart';
import 'package:lelang_fb/app/widgets/header.dart';
import 'package:lelang_fb/core/constants/color.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../controllers/auth_controller.dart';
import '../../admin/views/admin_view.dart';
import '../controllers/profile_controller.dart';
import 'profile_setting_view.dart';
import 'transaction_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: Header(
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                color: AppColors.hijauTua,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        leading: Container(
          margin: EdgeInsets.only(left: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    controller.profileUrl.value.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(37.5),
                            child: Image.network(
                              controller.profileUrl.value,
                              width: 75,
                              height: 75,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/icons/profile.png',
                                width: 75,
                                height: 75,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/icons/profile.png',
                            width: 75,
                            height: 75,
                            fit: BoxFit.contain,
                          ),
                    SizedBox(width: 17),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.displayName.value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: controller.isVerified.value
                                ? AppColors.hijauTua
                                : AppColors.red,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              controller.isVerified.value
                                  ? Icon(Icons.verified,
                                      size: 16, color: Colors.white)
                                  : Icon(Icons.error_outline,
                                      size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                controller.isVerified.value
                                    ? 'Verified'
                                    : 'Unverified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            SizedBox(height: 20),
            Buttonn(
              image: Assets.icons.profile2.path,
              text: 'Profile Settings',
              onPressed: () {
                Get.to(ProfileSettingView());
              },
            ),
            Buttonn(
              image: Assets.icons.items.path,
              text: 'My Items',
              onPressed: () {
                Get.to(MyitemsView());
              },
            ),
            Buttonn(
              image: Assets.icons.transaction.path,
              text: 'Transaction',
              onPressed: () {
                Get.to(TransactionView());
              },
            ),
            Buttonn(
              icon: Icons.settings,
              text: 'Admin',
              onPressed: () {
                Get.to(AdminView());
              },
            ),
            Buttonn(
              image: Assets.icons.log.path,
              text: 'Logout',
              onPressed: () {
                print("logout");
                Get.defaultDialog(
                  title: "Logout",
                  middleText: "Are you sure you want to logout?",
                  textCancel: "Cancel",
                  textConfirm: "Logout",
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    authC.logout();
                    Get.offAllNamed('/login');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Buttonn extends StatelessWidget {
  IconData? icon;
  String? image;
  String text;
  Function()? onPressed;
  Buttonn({
    super.key,
    this.icon,
    this.image,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(Colors.white),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: image != null
                        ? Image.asset(
                            image!,
                            width: 10,
                            color: AppColors.hijauTua,
                          )
                        : Icon(
                            icon!,
                            color: AppColors.hijauTua,
                          ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    text,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
