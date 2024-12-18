import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              bottom: 3, // Adjust the height of the floating button
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: FloatingActionButton(
                onPressed: () {
                  controller.selectedPage.value = 2; // Navigate to Add page
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
}
