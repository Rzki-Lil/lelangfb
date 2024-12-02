import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () =>
            controller.widgetOptions.elementAt(controller.selectedIndex.value),
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
                currentIndex: controller.selectedIndex.value,
                onTap: (index) {
                  if (index != 2) {
                    controller.selectedIndex.value = index;
                  }
                  if (index == 1) {
                    FocusScope.of(context).requestFocus(controller.search);
                  }
                },
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: SizedBox.shrink(), // Empty for floating button
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_outline),
                    label: 'List',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 3, // Adjust the height of the floating button
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: FloatingActionButton(
                onPressed: () {
                  controller.selectedIndex.value = 2; // Navigate to Add page
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
}
