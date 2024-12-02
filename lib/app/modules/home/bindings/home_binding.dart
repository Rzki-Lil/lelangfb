import 'package:get/get.dart';

import 'package:lelang_fb/app/modules/home/controllers/profile_controller.dart';
import 'package:lelang_fb/app/modules/home/controllers/profile_controller.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
