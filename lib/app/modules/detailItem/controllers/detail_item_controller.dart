import 'package:get/get.dart';

class DetailItemController extends GetxController {
  //TODO: Implement DetailItemController
  var currentPage = 0.obs;
  var isClicked = false.obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
