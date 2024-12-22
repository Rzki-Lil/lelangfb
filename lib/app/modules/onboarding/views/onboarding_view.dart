import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/login/views/login_view.dart';
import 'package:lelang_fb/core/constants/color.dart';

import '../../../../core/assets/assets.gen.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  OnboardingView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());
    return Scaffold(
      body: Obx(
        () => SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.pages.length,
                  onPageChanged: (idx) {
                    controller.changePage(idx);
                  },
                  itemBuilder: (context, idx) {
                    final item = controller.pages[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Assets.icons.logoLelangText.image(width: 150),
                          SizedBox(height: 40),
                          Center(
                            child: Container(
                              height: 300,
                              width: 300,
                              child: Image.asset(
                                item.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 200,
                            width: double.infinity,
                            child: Column(
                              children: [
                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.hijauTua,
                                  ),
                                ),
                                Text(
                                  item.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  if (controller.currentPage.value ==
                      controller.pages.length - 1) {
                    Get.to(LoginView());
                  } else {
                    controller.nextPage(controller.pages.length);
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: AppColors.hijauTua,
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
              SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(
                      controller.pages.length,
                      (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 40,
                          height: 15,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: controller.currentPage == index
                                ? AppColors.hijauTua
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        );
                      },
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
}

class OnboardingPageModel {
  final String title;
  final String description;
  final String image;

  OnboardingPageModel({
    required this.title,
    required this.description,
    required this.image,
  });
}
