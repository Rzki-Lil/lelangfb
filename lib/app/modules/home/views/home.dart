import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/utils/space.dart';
import '../../../utils/event_card.dart';
import '../../../utils/items_card.dart';
import '../controllers/home_controller.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final CarouselSliderController carouselController =
        CarouselSliderController();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar to hide on scroll
          SliverAppBar(
              pinned: false,
              title: TextField(
                onTapOutside: (event) => controller.search.unfocus(),
                focusNode: controller.search,
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications),
                )
              ]),
          Space(height: 10, width: 0),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                children: [
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      initialPage: 0,
                      viewportFraction: 1,
                      enableInfiniteScroll: true,
                      onPageChanged: (index, reason) {
                        controller.currentPage.value = index;
                      },
                    ),
                    carouselController: carouselController,
                    itemCount: controller.listNew.length,
                    itemBuilder: (context, index, realIndex) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            clipBehavior: Clip.hardEdge,
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 0, 255, 76),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              controller.listNew[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Obx(() {
                    return Positioned(
                      right: 0,
                      bottom: 0,
                      child: Row(
                        children: List.generate(controller.listNew.length, (i) {
                          return GestureDetector(
                            onTap: () {
                              carouselController.animateToPage(
                                  i); // Navigate to specific page
                            },
                            child: Container(
                              width: 24,
                              height: 12,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: controller.currentPage.value == i
                                    ? Colors.black
                                    : Colors.grey.withOpacity(0.4),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Space(height: 20, width: 0),
          // Menu Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: controller.menuItems,
              ),
            ),
          ),
          Space(height: 10, width: 0),
          // Auction Schedule Section
          SliverToBoxAdapter(
            child: Padding(
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
          ),
          // TabBar Section
          SliverToBoxAdapter(
            child: Padding(
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
          ),
          // TabBarView Section
          SliverToBoxAdapter(
            child: Container(
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
          ),

          // Currently Trending Section
          SliverToBoxAdapter(
            child: Container(
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
                    height: 270,
                    child: buildItemsList(controller.items),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        imageUrl: event["imageURL"]!, // Replace with your image asset path
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
