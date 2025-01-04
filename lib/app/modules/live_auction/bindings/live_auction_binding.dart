import 'package:get/get.dart';

import '../controllers/live_auction_controller.dart';

class LiveAuctionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveAuctionController>(
      () => LiveAuctionController(),
    );
  }
}
