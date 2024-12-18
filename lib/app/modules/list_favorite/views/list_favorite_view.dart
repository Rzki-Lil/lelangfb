import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/addItem/views/add_item_view.dart';
import 'package:lelang_fb/app/modules/home/controllers/home_controller.dart';
import 'package:lelang_fb/app/utils/text.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../detailItem/controllers/detail_item_controller.dart';
import '../controllers/list_favorite_controller.dart';

class ListFavoriteView extends GetView<ListFavoriteController> {
  const ListFavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    final controllerHome = Get.put(HomeController());
    final controllerDetail = Get.put(
        DetailItemController()); // Mendapatkan controller DetailItemController
    controllerDetail
        .loadFavoriteItems(); // ambil item favorit dari DetailItemController

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: appbarSearch(
          controllerHome: controllerHome,
          widget: true,
        ),
      ),
      body: Obx(() {
        // Jika tidak ada item favorit
        if (controllerDetail.favoriteItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Vertikal di tengah

              children: [
                Assets.icons.nofavorite.image(width: 150), // Ikon No favorite
                SizedBox(height: 10), // Jarak antara ikon dan teks
                TextCust(
                  text: "No Favorite Items Yet!",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 10), // Jarak antara ikon dan teks
                TextCust(
                  text:
                      "You haven't added any items to your favorites. \nExplore auctions and add items you love to this list!",
                  fontSize: 14,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        // Jika ada item favorit, tampilkan daftar item
        return SingleChildScrollView(
          child: Text("List Favorite"),
          // child: Padding(
          //   padding: const EdgeInsets.only(top: 10),
          //   child: Column(
          //     children: [
          //       BuildItems(items: controllerDetail.favoriteItems),
          //     ],
          //   ),
          // ),
        );
      }),
    );
  }
}
