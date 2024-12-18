import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/home/controllers/home_controller.dart';

import '../../addItem/views/add_item_view.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchingController> {
  const SearchView({super.key});
  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    Get.put(SearchingController());
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: appbarSearch(
            controllerHome: homeController,
          )),
      body: const Center(
        child: Text(
          'SearchView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
