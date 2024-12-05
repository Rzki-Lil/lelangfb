import 'package:get/get.dart';

import '../controllers/detail_item_controller.dart';

class DetailItemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailItemController>(
      () => DetailItemController(),
    );
  }
}
