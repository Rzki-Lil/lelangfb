import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/myitems/views/myitems_view.dart';
import 'package:lelang_fb/core/constants/color.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../controllers/auth_controller.dart';
import '../../notifications/views/notifications_view.dart';
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
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Iconnn(
              icon: Assets.icons.settings.path,
            ),
            Iconnn(
              icon: Assets.icons.notif.path,
              onPressed: () {
                Get.to(NotifictaionsView());
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile picture
                Image.asset(
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
                      'Dominic Toretto', // User name
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
                        color: controller.verify
                            ? AppColors.hijauTua
                            : AppColors.red,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        controller.verify ? 'Verified Seller' : 'Unverified',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20), // Space between profile and settings menu
            Buttonn(
              icon: Assets.icons.profile2.path,
              text: 'Profile Settings',
              onPressed: () {
                Get.to(ProfileSettingView());
              },
            ),
            Buttonn(
              icon: Assets.icons.items.path,
              text: 'My Items',
              onPressed: () {
                Get.to(MyitemsView());
              },
            ),
            Buttonn(
              icon: Assets.icons.transaction.path,
              text: 'Transaction',
              onPressed: () {
                Get.to(TransactionView());
              },
            ),
            Buttonn(
              icon: Assets.icons.security.path,
              text: 'Security',
              onPressed: () {},
            ),
            Buttonn(
              icon: Assets.icons.help.path,
              text: 'Help Center',
              onPressed: () {},
            ),
            Buttonn(
              icon: Assets.icons.log.path,
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

class Iconnn extends StatelessWidget {
  String icon;
  double width;
  double height;
  VoidCallback? onPressed;
  Iconnn({
    super.key,
    required this.icon,
    this.height = 24,
    this.width = 24,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Image.asset(
        icon, // Icon for settings
        width: width,
        height: height,
      ),
    );
  }
}

class Buttonn extends StatelessWidget {
  String icon;
  String text;
  Function()? onPressed;
  Buttonn({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(
            Colors.grey[100],
          ),
          shape: WidgetStatePropertyAll(
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
                  child: Image.asset(
                    icon,
                    width: 10,
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
              Icons.arrow_forward_ios, // Ikon di sebelah kanan
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
