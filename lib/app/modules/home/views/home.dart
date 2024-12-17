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

import '../../../routes/app_pages.dart';
import '../../../utils/event_card.dart';

import '../controllers/home_controller.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

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

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final carouselController =
        CarouselSliderController(); // Changed from CarouselController

    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 10), // Replace Space with SizedBox
                // Carousel Section
                Stack(
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
                      carouselController: carouselController, // Use it here
                      itemCount: controller.listNew.length,
                      itemBuilder: (context, index, realIndex) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.asset(
                                width: double.infinity,
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
                          children:
                              List.generate(controller.listNew.length, (i) {
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
                SizedBox(height: 20), // Replace Space with SizedBox
                // Menu Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: controller.menuItems,
                ),
                SizedBox(height: 10), // Replace Space with SizedBox
                // Auction Schedule Section
              ]),
            ),
          ),
          // Add red section outside SliverPadding

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
}
