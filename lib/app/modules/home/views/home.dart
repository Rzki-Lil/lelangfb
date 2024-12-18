import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/utils/live_auction_card.dart';
import 'package:lelang_fb/app/utils/space.dart';
import 'package:lelang_fb/app/utils/upcoming_auction_card.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Added import

import '../../../../core/assets/assets.gen.dart';
import '../../../routes/app_pages.dart';

import '../../../utils/event_card.dart';
import '../../../utils/text.dart';
import '../controllers/home_controller.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final carouselController =
        CarouselSliderController(); // Changed from CarouselController

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          //appbar
          SliverAppBar(
              pinned: false,
              title: GestureDetector(
                onTap: () {
                  controller.changePage(1);
                },
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: Colors.grey),
                  ),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Assets.icons.search
                              .image(width: 28, color: Colors.grey),
                        ),
                        TextCust(
                          text: "Search",
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: InkWell(
                    onTap: () {
                      // Get.to(NotifictaionsView());
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      // color: Colors.black,
                      child: Image.asset(
                        Assets.icons.notifhighres.path,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
              ]),
          Space(height: 10, width: 0),
          // caraousel image
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      autoPlay:
                          controller.bannerPromo.length > 1 ? true : false,
                      autoPlayInterval: Duration(seconds: 3),
                      initialPage: 0,
                      viewportFraction: 1,
                      enableInfiniteScroll:
                          controller.bannerPromo.length > 1 ? true : false,
                      onPageChanged: (index, reason) {
                        controller.currentPage.value = index;
                      },
                    ),
                    carouselController: carouselController,
                    itemCount: controller.bannerPromo.length,
                    itemBuilder: (context, index, realIndex) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              width: double.infinity,
                              controller.bannerPromo[index],
                              fit: BoxFit.fill,
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
                        children:
                            List.generate(controller.bannerPromo.length, (i) {
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
                                    ? AppColors.hijauMuda
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
          // menu section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  menuSection(70, 'Antiques', Assets.icons.antiques.path,
                      AppColors.antiques.withOpacity(0.2), () {
                    print("antiques");
                  }),
                  menuSection(70, 'Auction', Assets.icons.auction.path,
                      AppColors.auction.withOpacity(0.2), () {
                    print("auction");
                  }),
                  menuSection(70, 'Buy', Assets.icons.keranjang.path,
                      AppColors.buy.withOpacity(0.2), () {
                    print("buy");
                  }),
                  menuSection(70, 'Sell', Assets.icons.sell.path,
                      Colors.lightBlue.withOpacity(0.2), () {
                    print("sell");
                  }),
                ],
              ),
            ),
          ),
          Space(height: 10, width: 0),
          // Live Auctions Section
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.hijauTua,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Live Auctions",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Image.asset(
                              'assets/gif/live-now.gif',
                              height: 45,
                              width: 45,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(Routes.DETAIL_ITEM),
                          child: Text(
                            "View All",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() => controller.liveAuctions.isEmpty
                      ? _buildEmptyState(
                          message:
                              "No live auctions at the moment\nCheck back later!",
                          color: Colors.white,
                          icon: Icons.live_tv_outlined,
                        )
                      : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: controller.liveAuctions.length,
                            itemBuilder: (context, index) {
                              final item = controller.liveAuctions[index];
                              return Container(
                                width: MediaQuery.of(context).size.width *
                                    0.4, // Adjusted width
                                margin: EdgeInsets.only(
                                    right: 10), // Reduced margin
                                child: LiveAuctionCard(
                                  imageUrl: item['imageURL'][0],
                                  name: item['name'],
                                  price: item['current_price'],
                                  location: item['lokasi'],
                                  rarity: item['rarity'],
                                  onTap: () => Get.toNamed(
                                    Routes.DETAIL_ITEM,
                                    arguments: item,
                                  ),
                                ),
                              );
                            },
                          ),
                        )),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Upcoming Auctions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Upcoming Auctions",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "View All",
                          style: TextStyle(color: AppColors.hijauTua),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    final items = controller.upcomingAuctions;
                    if (items.isEmpty) {
                      return _buildEmptyState(
                        message:
                            "No upcoming auctions yet\nStay tuned for new items!",
                        color: Colors.grey[600]!,
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true, // Important!
                      physics: NeverScrollableScrollPhysics(), // Important!
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return UpcomingAuctionCard(
                          imageUrl: item['imageURL'][0],
                          name: item['name'],
                          price: item['starting_price'],
                          location: item['lokasi'],
                          rarity: item['rarity'],
                          date: (item['tanggal'] as Timestamp).toDate(),
                          startTime: item['jamMulai'],
                          onTap: () => Get.toNamed(
                            Routes.DETAIL_ITEM,
                            arguments: item,
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column menuSection(
      double width, String title, String asset, Color color, Function? ontap) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            ontap!();
          },
          child: Container(
            width: width,
            height: width,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              asset,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

Widget _buildEmptyState({
  required String message,
  required Color color,
  IconData icon = Icons.hourglass_empty,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 48,
          color: color,
        ),
        SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class titleTextFieldAppbar extends StatelessWidget {
  titleTextFieldAppbar({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: TextField(
        onTap: () {
          controller.changePage(1);
        },
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
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Image.asset(
              Assets.icons.search.path,
              color: Colors.grey,
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            maxWidth: 50,
            maxHeight: 50,
          ),
          contentPadding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}

Widget buildEventList(List<Map<String, String>> events) {
  return ListView.builder(
    padding: EdgeInsets.only(left: 20, right: 0),
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
