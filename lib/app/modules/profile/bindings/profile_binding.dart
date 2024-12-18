import 'package:get/get.dart';

import 'package:lelang_fb/app/modules/profile/controllers/transaction_controller.dart';

import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionController>(
      () => TransactionController(),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}
