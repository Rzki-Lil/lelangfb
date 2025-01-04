import 'dart:io';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/utils/live_auction_card.dart';
import 'package:lelang_fb/app/utils/space.dart';
import 'package:lelang_fb/app/utils/upcoming_auction_card.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../routes/app_pages.dart';

import '../../../utils/event_card.dart';
import '../../../utils/text.dart';
import '../controllers/home_controller.dart';
import '../../../widgets/home_header.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          HomeHeader(
            onPageChange: controller.changePage,
            notificationCount: 3,
            onNotificationTap: () {
              Get.toNamed(Routes.NOTIFICATIONS);
            },
          ),
          Space(height: 10, width: 0),
          // caraousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                children: [
                  Obx(() {
                    if (controller.carouselImages.isEmpty) {
                      return Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.hijauTua),
                          ),
                        ),
                      );
                    }

                    return CarouselSlider.builder(
                      options: CarouselOptions(
                        height: 220,
                        autoPlay: controller.carouselImages.length > 1,
                        autoPlayInterval: Duration(seconds: 5),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.easeInOut,
                        initialPage: 0,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          controller.currentPage.value = index;
                        },
                      ),
                      itemCount: controller.carouselImages.length,
                      itemBuilder: (context, index, realIndex) {
                        final imageUrl = controller.carouselImages[index];
                        return Container(
                          width: 600,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.hijauTua),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  Obx(() => controller.carouselImages.length > 1
                      ? Positioned(
                          bottom: 15,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: controller.carouselImages
                                .asMap()
                                .entries
                                .map((entry) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                width: controller.currentPage.value == entry.key
                                    ? 20
                                    : 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color:
                                      controller.currentPage.value == entry.key
                                          ? AppColors.hijauTua
                                          : Colors.white.withOpacity(0.5),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : SizedBox.shrink()),
                ],
              ),
            ),
          ),
          Space(height: 20, width: 0),
          // Balance and Transaction Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Balance Section with History
                  InkWell(
                    onTap: () => _showHistoryDialog(context, controller),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.hijauTua.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.hijauTua,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Obx(() {
                                final balance = controller.userBalance.value;
                                return Text(
                                  'Rp ${balance.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppColors.hijauTua,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'Tap to view history',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Transaction Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTransactionButton(
                        'Top Up',
                        Icons.add_circle_outline,
                        AppColors.hijauTua,
                        () => _showTopUpDialog(context),
                      ),
                      SizedBox(width: 16),
                      _buildTransactionButton(
                        'Transfer',
                        Icons.send_outlined,
                        AppColors.hijauTua,
                        () => _showTransferDialog(context),
                      ),
                      SizedBox(width: 16),
                      _buildTransactionButton(
                        'Withdraw',
                        Icons.account_balance,
                        AppColors.hijauTua,
                        () => _showWithdrawDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Space(height: 20, width: 0),
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
                          ],
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(
                            Routes.SEARCH,
                            arguments: {
                              'filter': 'live',
                              'fromSection': 'liveAuctions',
                            },
                          ),
                          child: Text(
                            "View All",
                            style: TextStyle(color: Colors.white),
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
                              final doc = controller.liveAuctions[index];
                              final data = doc.data();

                              final endTimeStr = data['jamSelesai'] as String;
                              final endTimeParts = endTimeStr.split(':');
                              final itemDate =
                                  (data['tanggal'] as Timestamp).toDate();

                              final endTime = DateTime(
                                itemDate.year,
                                itemDate.month,
                                itemDate.day,
                                int.parse(endTimeParts[0]),
                                int.parse(endTimeParts[1]),
                              );

                              return StreamBuilder<int>(
                                stream: Stream.periodic(
                                    Duration(seconds: 1), (i) => i),
                                builder: (context, snapshot) {
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    margin: EdgeInsets.only(right: 10),
                                    child: LiveAuctionCard(
                                      imageUrl: data['imageURL'][0],
                                      name: data['name'],
                                      price: (data['current_price'] ?? 0)
                                          .toDouble(),
                                      location: data['lokasi'],
                                      rarity: data['rarity'],
                                      id: doc.id,
                                      endTime: endTime,
                                      bidCount: data['bid_count'] ?? 0,
                                      onTap: () => Get.toNamed(
                                        Routes.LIVE_AUCTION,
                                        arguments: {
                                          'itemId': doc.id,
                                          'itemName': data['name'],
                                          'currentPrice':
                                              (data['current_price'] ?? 0)
                                                  .toDouble(),
                                          'tanggal': data['tanggal'],
                                          'jamMulai': data['jamMulai'],
                                          'jamSelesai': data['jamSelesai'],
                                          'imageUrls': data['imageURL'],
                                          'location': data['lokasi'],
                                          'category': data['category'],
                                          'rarity': data['rarity'],
                                          'description': data['description'],
                                          'sellerId': data['seller_id'],
                                          'bidCount': data['bid_count'] ?? 0,
                                        },
                                      ),
                                    ),
                                  );
                                },
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
                        onPressed: () => Get.toNamed(
                          Routes.SEARCH,
                          arguments: {
                            'filter': 'upcoming',
                            'fromSection': 'upcomingAuctions',
                          },
                        ),
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
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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
                          category: item['category'] ?? 'Others',
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
        imageUrl: event["imageURL"]!,
      );
    },
  );
}

Widget _buildTransactionButton(
    String label, IconData icon, Color color, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    ),
  );
}

void _showTopUpDialog(BuildContext context) {
  final amountController = TextEditingController();
  final homeController = Get.find<HomeController>();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Top Up Balance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (amountController.text.isNotEmpty) {
                      Get.back();
                      homeController.topUp(double.parse(amountController.text));
                    }
                  },
                  child: Text('Top Up', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hijauTua,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showTransferDialog(BuildContext context) {
  final recipientController = TextEditingController();
  final amountController = TextEditingController();
  final homeController = Get.find<HomeController>();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Transfer Balance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: recipientController,
              decoration: InputDecoration(
                labelText: 'Recipient Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (recipientController.text.isNotEmpty &&
                        amountController.text.isNotEmpty) {
                      Get.back();
                      homeController.transfer(
                        recipientController.text,
                        double.parse(amountController.text),
                      );
                    }
                  },
                  child: Text(
                    'Transfer',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hijauTua,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showWithdrawDialog(BuildContext context) {
  final amountController = TextEditingController();
  final accountNumberController = TextEditingController();
  final accountNameController = TextEditingController();
  final homeController = Get.find<HomeController>();
  String selectedBank = 'bca';

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Withdraw Balance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // VA banks
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Virtual Account Bank',
                border: OutlineInputBorder(),
              ),
              value: selectedBank,
              items: [
                DropdownMenuItem(
                    value: 'bca', child: Text('BCA Virtual Account')),
                DropdownMenuItem(
                    value: 'bni', child: Text('BNI Virtual Account')),
                DropdownMenuItem(
                    value: 'bri', child: Text('BRI Virtual Account')),
                DropdownMenuItem(
                    value: 'mandiri', child: Text('Mandiri Virtual Account')),
              ],
              onChanged: (value) => selectedBank = value!,
            ),
            SizedBox(height: 15),
            TextField(
              controller: accountNumberController,
              keyboardType: TextInputType.number,
              maxLength: 19, 
              decoration: InputDecoration(
                labelText: 'Account Number',
                border: OutlineInputBorder(),
                counterText:
                    '', 
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
              ],
            ),
            SizedBox(height: 15),
            TextField(
              controller: accountNameController,
              decoration: InputDecoration(
                labelText: 'Account Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (amountController.text.isNotEmpty &&
                        accountNumberController.text.isNotEmpty &&
                        accountNameController.text.isNotEmpty) {
                      Get.back();
                      homeController.withdraw(
                        double.parse(amountController.text),
                        selectedBank,
                        accountNumberController.text,
                        accountNameController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hijauTua,
                  ),
                  child:
                      Text('Withdraw', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showHistoryDialog(BuildContext context, HomeController controller) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        height: Get.height * 0.7,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .where('userId',
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No transactions found'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final transaction = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      final amount = transaction['amount'] ?? 0.0;
                      final type = transaction['type'] ?? 'Unknown';
                      final status = transaction['status'] ?? 'unknown';
                      final isSuccess =
                          status == 'success' || status == 'completed';
                      final timestamp = transaction['timestamp'] as Timestamp;
                      final date = timestamp.toDate();

                      return ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.hijauTua.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getTransactionIcon(type),
                            color: isSuccess ? AppColors.hijauTua : Colors.red,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Icon(Icons.chevron_right, size: 16),
                          ],
                        ),
                        subtitle: Text(
                          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
                        ),
                        trailing: Text(
                          'Rp ${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: AppColors.hijauTua,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _showTransactionDetails(transaction),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

IconData _getTransactionIcon(String type) {
  switch (type.toLowerCase()) {
    case 'topup':
      return Icons.add_circle;
    case 'transfer':
      return Icons.send;
    case 'withdraw':
      return Icons.account_balance;
    default:
      return Icons.swap_horiz;
  }
}

void _showTransactionDetails(Map<String, dynamic> transaction) {
  final type = transaction['type'];
  final status = transaction['status'] ?? 'unknown';

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Divider(),
            _buildDetailRow('Type', type.toUpperCase()),
            _buildDetailRow(
                'Amount', 'Rp ${transaction['amount']?.toString() ?? '0'}'),
            _buildDetailRow('Status', status.toUpperCase()),
            if (transaction['timestamp'] != null)
              _buildDetailRow(
                  'Date & Time',
                  _formatDateTime(
                      (transaction['timestamp'] as Timestamp).toDate())),
            if (type == 'transfer' && transaction['recipientEmail'] != null)
              _buildDetailRow('Recipient', transaction['recipientEmail']),
            if (type == 'withdraw') ...[
              if (transaction['bankCode'] != null)
                _buildDetailRow(
                    'Bank', transaction['bankCode'].toString().toUpperCase()),
              if (transaction['accountName'] != null)
                _buildDetailRow('Account Name', transaction['accountName']),
              if (transaction['bankAccount'] != null)
                _buildDetailRow('Account Number', transaction['bankAccount']),
            ],
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _formatDateTime(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
}

List<Widget> _buildTransactionDetails(Map<String, dynamic> transaction) {
  final List<Widget> details = [];
  final type = transaction['type'];

  details.add(_buildDetailRow('Type', type.toUpperCase()));
  details.add(_buildDetailRow(
      'Amount', 'Rp ${transaction['amount']?.toString() ?? '0'}'));

  if (transaction['timestamp'] != null) {
    final date = (transaction['timestamp'] as Timestamp).toDate();
    details.add(_buildDetailRow('Date & Time',
        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}'));
  }

  switch (type.toLowerCase()) {
    case 'transfer':
      if (transaction['recipientEmail'] != null) {
        details
            .add(_buildDetailRow('Recipient', transaction['recipientEmail']));
      }
      break;
    case 'withdraw':
      if (transaction['bankCode'] != null) {
        details.add(_buildDetailRow(
            'Bank', transaction['bankCode'].toString().toUpperCase()));
      }
      if (transaction['accountName'] != null) {
        details
            .add(_buildDetailRow('Account Name', transaction['accountName']));
      }
      if (transaction['bankAccount'] != null) {
        details
            .add(_buildDetailRow('Account Number', transaction['bankAccount']));
      }
      if (transaction['status'] != null) {
        details.add(_buildDetailRow(
            'Status', transaction['status'].toString().toUpperCase()));
      }
      break;
  }

  return details;
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}
