import 'package:get/get.dart';

import '../../../modules/addItem/controllers/add_item_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<AddItemController>(
      () => AddItemController(),
    );
  }
}
