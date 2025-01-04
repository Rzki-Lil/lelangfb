import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lelang_fb/app/modules/home/controllers/home_controller.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';
import 'package:lelang_fb/core/constants/color.dart';
import '../controllers/list_favorite_controller.dart';
import '../../../widgets/header.dart';

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
            Get.back();
            final homeController = Get.find<HomeController>();
            homeController.selectedPage.value = 0;
          },
        ),
      ),
      body: Column(
        children: [
          // Instructions Card
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

          // List of Favorites
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

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  print('Item data: $item'); // Add this debug line

                  return Slidable(
                    key: ValueKey(item['id']),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.25,
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
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => controller.navigateToDetail(item),
                        child: Stack(
                          children: [
                            // Background gradient with time and date badges
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 35,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      AppColors.hijauTua.withOpacity(0.0),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(24),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: AppColors.hijauTua,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          item['formattedDate'] ?? '',
                                          style: TextStyle(
                                            color: AppColors.hijauTua,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time_filled,
                                          size: 12,
                                          color: AppColors.hijauTua,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${item['jamMulai'] ?? ''}',
                                          style: TextStyle(
                                            color: AppColors.hijauTua,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Main content
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['imageURL'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: Colors.grey[200],
                                        width: 80,
                                        height: 80,
                                        child: Icon(Icons.error_outline,
                                            color: Colors.grey[400]),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] ?? 'No Name',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Rp ${NumberFormat.currency(
                                            locale: 'id',
                                            symbol: '',
                                            decimalDigits: 0,
                                          ).format(item['current_price'] ?? 0)}',
                                          style: TextStyle(
                                            color: AppColors.hijauTua,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item['displayLocation'] ??
                                                    'No location',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
}
