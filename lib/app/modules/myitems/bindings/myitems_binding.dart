import 'package:get/get.dart';

import '../controllers/myitems_controller.dart';

class MyitemsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyitemsController>(
      () => MyitemsController(),
    );
  }
}
