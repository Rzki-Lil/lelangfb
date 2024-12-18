import 'package:get/get.dart';

import '../controllers/list_favorite_controller.dart';

class ListFavoriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListFavoriteController>(
      () => ListFavoriteController(),
    );
  }
}
