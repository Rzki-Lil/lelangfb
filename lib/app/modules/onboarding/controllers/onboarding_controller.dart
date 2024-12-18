import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/assets/assets.gen.dart';
import '../views/onboarding_view.dart';

class OnboardingController extends GetxController {
  //TODO: Implement OnboardingController

  final count = 0.obs;
  @override
  void onInit() {
    pageController = PageController(initialPage: 0);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void increment() => count.value++;

  var currentPage = 0.obs;
  late PageController pageController;

  final pages = [
    OnboardingPageModel(
      title: 'Welcome to Lelang ID',
      description: 'The Most Trusted and Safest Auction Platform in Indonesia',
      image: Assets.images.onboarding1.path,
    ),
    OnboardingPageModel(
      title: 'Easy Auction Process',
      description: 'Make offers in real-time and transparently',
      image: Assets.images.onboarding2.path,
    ),
    OnboardingPageModel(
      title: 'Guaranteed Transaction Security',
      description: 'Auctions from Verified Sellers.',
      image: Assets.images.onboarding3.path,
    ),
    OnboardingPageModel(
      title: 'Enjoy Discounts & Special Offers',
      description: 'Get Quality Products at the Best Prices',
      image: Assets.images.onboarding4.path,
    ),
  ];

  void changePage(int index) {
    currentPage.value = index;
  }

  void nextPage(int totalPages) {
    if (currentPage.value < totalPages - 1) {
      pageController.animateToPage(currentPage.value + 1,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic);
    }
  }

  void skipOnboarding() {
    // Handle skip onboarding logic
  }
}
