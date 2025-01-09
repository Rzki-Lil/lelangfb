import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/assets/assets.gen.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => controller.widgetOptions.elementAt(controller.selectedPage.value),
      ),
      bottomNavigationBar: Obx(() {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 215, 55, 55),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.green,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white60,
                currentIndex: controller.selectedPage.value,
                onTap: (index) {
                  if (index != 2) {
                    controller.selectedPage.value = index;
                  }
                },
                items: <BottomNavigationBarItem>[
                  bottomNavbaritem(
                      Assets.icons.home.path, 'Home', Assets.icons.home.path),
                  bottomNavbaritem(Assets.icons.search.path, 'Search',
                      Assets.icons.searchfilled.path),
                  BottomNavigationBarItem(
                    icon: SizedBox.shrink(), // Empty for floating button
                    label: '',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.favorite_outline),
                      label: 'List',
                      activeIcon: Icon(Icons.favorite_sharp)),
                  bottomNavbaritem(Assets.icons.profileoutline.path, "Profile",
                      Assets.icons.profilefilled.path)
                ],
              ),
            ),
            Positioned(
              bottom: 3, 
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: FloatingActionButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    Get.toNamed('/login');
                    return;
                  }

                  try {
                    final docSnapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();

                    if (!docSnapshot.exists ||
                        !(docSnapshot.data()?['verified_user'] ?? false)) {
                      Get.snackbar(
                        'Access Denied',
                        '',
                        messageText: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Verification Required",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Follow these steps to become a verified user:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildInstructionRow(
                              icon: Icons.person,
                              text: "Go to Profile tab",
                              color: Colors.blue,
                            ),
                            SizedBox(height: 8),
                            _buildInstructionRow(
                              icon: Icons.settings,
                              text: "Open Profile Settings",
                              color: Colors.orange,
                            ),
                            SizedBox(height: 8),
                            _buildInstructionRow(
                              icon: Icons.info_rounded,
                              text: "Complete Your information",
                              color: Colors.green,
                            ),
                          ],
                        ),
                        backgroundColor: Colors.white,
                        colorText: Colors.black87,
                        duration: Duration(seconds: 5),
                        margin: EdgeInsets.all(8),
                        borderRadius: 10,
                        snackPosition: SnackPosition.TOP,
                        boxShadows: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      );
                      return;
                    }

                    controller.selectedPage.value = 2;
                  } catch (e) {
                    print('Error checking verification status: $e');
                    Get.snackbar(
                      'Error',
                      'Unable to verify seller status',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: const Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  BottomNavigationBarItem bottomNavbaritem(
      String asset, String label, String activeIcon) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        asset,
        width: 20,
        color: Colors.white60,
      ),
      label: label,
      activeIcon: Image.asset(
        activeIcon,
        width: 20,
      ),
    );
  }

  Widget _buildInstructionRow({
    required IconData icon,
    required String text,
    Color color = Colors.green,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
