import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lelang_fb/app/modules/home/controllers/home_controller.dart';
import 'package:lelang_fb/core/constants/color.dart';
import '../controllers/list_favorite_controller.dart';
import '../../../widgets/header.dart';
import 'package:lelang_fb/app/utils/live_auction_card.dart';
import 'package:lelang_fb/app/utils/upcoming_auction_card.dart';
import 'package:lelang_fb/app/services/auction_service.dart';

class ListFavoriteView extends GetView<ListFavoriteController> {
  const ListFavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ListFavoriteController());

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: Header(
        title: 'My Favorites',
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.hijauTua),
          onPressed: () {
              Get.find<HomeController>().changePage(0);
              Get.back();
            }
        ),
      ),
      body: Column(
        children: [
          // card intruksi
          Container(
            margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Your Favorite Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.hijauTua,
                  ),
                ),
                SizedBox(height: 16),
                _buildInstructionRow(
                  icon: Icons.swipe,
                  color: Colors.red,
                  text: "Swipe left to remove from favorites",
                ),
                SizedBox(height: 12),
                _buildInstructionRow(
                  icon: Icons.touch_app,
                  color: AppColors.hijauTua,
                  text: "Tap on items to see auction details",
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search favorites...',
                prefixIcon: Icon(Icons.search, color: AppColors.hijauTua),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) => controller.searchQuery.value = value,
            ),
          ),
          // favorite items
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              final items = controller.getFilteredItems();
              if (items.isEmpty) {
                return _buildEmptyState(
                  isSearching: controller.searchQuery.value.isNotEmpty,
                );
              }

              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final status =
                      item['status']?.toString().toLowerCase() ?? 'upcoming';
                  final itemDate = (item['tanggal'] as Timestamp).toDate();

                  Widget card;
                  if (status == 'live') {
                    final jamSelesai = item['jamSelesai']?.toString() ?? '';
                    final endTimeParts = jamSelesai.split(':');
                    final endTime = DateTime(
                      itemDate.year,
                      itemDate.month,
                      itemDate.day,
                      int.parse(endTimeParts[0]),
                      int.parse(endTimeParts[1]),
                    );

                    card = LiveAuctionCard(
                      imageUrl: item['imageURL'] is List
                          ? item['imageURL'][0]
                          : item['imageURL'],
                      name: item['name'] ?? 'Unnamed Item',
                      price: (item['current_price'] ?? 0.0).toDouble(),
                      location: item['lokasi'] ?? 'No location',
                      rarity: item['rarity'] ?? 'Common',
                      id: item['id'],
                      endTime: endTime,
                      bidCount: item['bid_count'] ?? 0,
                      onTap: () => controller.navigateToDetail(item),
                      onStatusChange: (itemId) {
                        AuctionService.checkAndUpdateStatus(
                          FirebaseFirestore.instance
                              .collection('items')
                              .doc(itemId),
                        );
                      },
                    );
                  } else {
                    card = UpcomingAuctionCard(
                      imageUrl: item['imageURL'] is List
                          ? item['imageURL'][0]
                          : item['imageURL'],
                      name: item['name'] ?? 'Unnamed Item',
                      price: (item['starting_price'] ?? 0.0).toDouble(),
                      location: item['lokasi'] ?? 'No location',
                      rarity: item['rarity'] ?? 'Common',
                      date: itemDate,
                      startTime: item['jamMulai'] ?? '',
                      category: item['category'] ?? 'Others',
                      onTap: () => controller.navigateToDetail(item),
                      id: item['id'],
                      onStatusChange: (itemId) {
                        AuctionService.checkAndUpdateStatus(
                          FirebaseFirestore.instance
                              .collection('items')
                              .doc(itemId),
                        );
                      },
                    );
                  }

                  return Slidable(
                    key: ValueKey(item['id']),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.5,
                      children: [
                        CustomSlidableAction(
                          flex: 1,
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          onPressed: (_) =>
                              controller.removeFromFavorites(item['id']),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete),
                              SizedBox(height: 4),
                              Text('Remove', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    child: card,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({required bool isSearching}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.favorite_border,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            isSearching
                ? 'No items match your search.'
                : 'No favorite items yet!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(Timestamp date, String start, String end) {
    final dateTime = date.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}\n$start - $end';
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final status = item['status']?.toString().toLowerCase() ?? 'upcoming';
    final itemDate = (item['tanggal'] as Timestamp).toDate();
    final jamMulai = item['jamMulai']?.toString() ?? '';
    final jamSelesai = item['jamSelesai']?.toString() ?? '';

    final startTimeParts = jamMulai.split(':');
    final endTimeParts = jamSelesai.split(':');

    if (startTimeParts.length != 2 || endTimeParts.length != 2) {
      return SizedBox(); 
    }

    final endTime = DateTime(
      itemDate.year,
      itemDate.month,
      itemDate.day,
      int.parse(endTimeParts[0]),
      int.parse(endTimeParts[1]),
    );

    if (status == 'live') {
      return Container(
        height: 160, 
        child: LiveAuctionCard(
          imageUrl:
              item['imageURL'] is List ? item['imageURL'][0] : item['imageURL'],
          name: item['name'] ?? 'Unnamed Item',
          price: (item['current_price'] ?? 0.0).toDouble(),
          location: item['lokasi'] ?? 'No location',
          rarity: item['rarity'] ?? 'Common',
          id: item['id'],
          endTime: endTime,
          bidCount: item['bid_count'] ?? 0,
          onTap: () => controller.navigateToDetail(item),
          onStatusChange: (itemId) {
            AuctionService.checkAndUpdateStatus(
              FirebaseFirestore.instance.collection('items').doc(itemId),
            );
          },
        ),
      );
    } else {
      return Container(
        height: 180,
        child: UpcomingAuctionCard(
          imageUrl:
              item['imageURL'] is List ? item['imageURL'][0] : item['imageURL'],
          name: item['name'] ?? 'Unnamed Item',
          price: (item['starting_price'] ?? 0.0).toDouble(),
          location: item['lokasi'] ?? 'No location',
          rarity: item['rarity'] ?? 'Common',
          date: itemDate,
          startTime: jamMulai,
          category: item['category'] ?? 'Others',
          onTap: () => controller.navigateToDetail(item),
          id: item['id'],
          onStatusChange: (itemId) {
            AuctionService.checkAndUpdateStatus(
              FirebaseFirestore.instance.collection('items').doc(itemId),
            );
          },
        ),
      );
    }
  }
}
