import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lelang_fb/app/utils/event_card.dart';
import 'package:lelang_fb/app/utils/items_card.dart';

import '../controllers/home_controller.dart';
import 'package:lelang_fb/app/controllers/auth_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authC.logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 200,
                child: Stack(children: [
                  PageView.builder(
                    controller: controller.pageController,
                    itemCount: controller.container.length,
                    itemBuilder: (context, index) {
                      return controller.container[index];
                    },
                    onPageChanged: (index) {
                      controller.currentPage.value = index;
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10, right: 10),
                      child: Obx(() {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(controller.container.length,
                              (index) {
                            return Container(
                              width: 35,
                              height: 7,
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: controller.currentPage.value == index
                                    ? Colors.black
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ]),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: controller.menuItems,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Nearest Auction Schedule",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("see all");
                    },
                    child: Text(
                      "See All",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: controller.tabController,
                  indicatorColor: Colors.green,
                  indicatorWeight: 0,
                  indicator: UnderlineTabIndicator(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 4,
                      color: Colors.green,
                    ),
                  ),
                  labelColor: Colors.green,
                  labelPadding: EdgeInsets.only(right: 20, left: 4),
                  unselectedLabelColor: Colors.black,
                  dividerColor: Colors.transparent,
                  labelStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: "MOBIL"),
                    Tab(text: "MOTORCYCLE"),
                    Tab(text: "LIFESTYLE"),
                  ],
                ),
              ),
            ),
            Container(
              height: 170,
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  buildEventList(controller.carEvents),
                  buildEventList(controller.motorEvents),
                  buildEventList(controller.lifestyeEvents),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.grey),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Currently Trending",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                        Text(
                          "See all",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 280,
                    child: buildItemsList(controller.items),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget buildEventList(List<Map<String, String>> events) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: events.length,
    itemBuilder: (context, index) {
      final event = events[index];
      return EventCard(
        date: event["date"]!,
        month: event["month"]!,
        time: event["time"]!,
        location: event["location"]!,
        imageUrl: event["imageURL"]!, // Ganti dengan path aset gambar Anda
      );
    },
  );
}

Widget buildItemsList(List<Map<String, String>> items) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return ItemsCard(
        grade: item["grade"]!,
        imageURL: item["imageURL"]!,
        judul: item["judul"]!,
        tahunMobil: item["tahunMobil"]!,
        tipe: item["tipe"]!,
        platNomor: item["platNomor"]!,
        harga: item["harga"]!,
        tanggal: item["tanggal"]!,
        bulan: item["bulan"]!,
        tahun: item["tahun"]!,
        lokasi: item["lokasi"]!,
        jamBidding: item["jamBidding"]!,
      );
    },
  );
}
