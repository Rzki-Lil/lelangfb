import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/utils/text.dart';
import '../../../../core/constants/color.dart';
import '../controllers/transaction_controller.dart';
import 'package:intl/intl.dart';
import '../../../widgets/header.dart';
import '../../../routes/app_pages.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TransactionView extends GetView<TransactionController> {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TransactionController());
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: Header(
        title: 'My Bids',
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Container(
          margin: EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.hijauTua),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.selectedTab.value == 0) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      'How to manage your ongoing bids',
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
                      text: "Swipe left to delete ongoing bids",
                    ),
                    SizedBox(height: 12),
                    _buildInstructionRow(
                      icon: Icons.touch_app,
                      color: AppColors.hijauTua,
                      text: "Tap on items to see auction details",
                    ),
                  ],
                ),
              );
            } else if (controller.selectedTab.value == 1) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      'Your Winning Bids',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInstructionRow(
                      icon: Icons.touch_app,
                      color: Colors.green,
                      text: "Tap on items to see complete auction details",
                    ),
                    SizedBox(height: 12),
                    _buildInstructionRow(
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                      text: "Congratulations on winning these auctions!",
                    ),
                  ],
                ),
              );
            } else if (controller.selectedTab.value == 2) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      'How to manage your failed bids',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[400],
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInstructionRow(
                      icon: Icons.swipe,
                      color: Colors.red,
                      text: "Swipe left to delete failed bid history",
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),

          // Search Bar
          Container(
            margin: EdgeInsets.fromLTRB(16, 5, 16, 10),
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
                hintText: 'Search bids...',
                prefixIcon: Icon(Icons.search, color: AppColors.hijauTua),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) => controller.searchQuery.value = value,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButtonWithCount('ONGOING', 0, controller.ongoingCount),
                _buildTabButtonWithCount('SUCCESS', 1, controller.successCount),
                _buildTabButtonWithCount('FAILED', 2, controller.failedCount),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              final filteredItems = controller.getFilteredBids();
              if (filteredItems.isEmpty) {
                return _buildEmptyState(
                    isSearching: controller.searchQuery.value.isNotEmpty);
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final bid = filteredItems[index];
                  // Only show Slidable for ongoing and failed bids
                  if (controller.selectedTab.value == 0 ||
                      controller.selectedTab.value == 2) {
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: 0.25,
                        children: [
                          CustomSlidableAction(
                            flex: 1,
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            onPressed: (_) => controller.deleteBid(bid),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete),
                                SizedBox(height: 4),
                                Text('Delete', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      child: _buildBidCard(bid),
                    );
                  }
                  return _buildBidCard(bid);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtonWithCount(String text, int index, RxInt count) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => controller.tabController.animateTo(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.hijauTua : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildTabButton(String text, int index) {
    return Obx(() => GestureDetector(
          onTap: () => controller.tabController.animateTo(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: controller.selectedTab.value == index
                  ? AppColors.hijauTua
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: controller.selectedTab.value == index
                    ? Colors.white
                    : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
  }

  List<Map<String, dynamic>> _getItemsForCurrentTab() {
    switch (controller.selectedTab.value) {
      case 0:
        return controller.ongoingBids;
      case 1:
        return controller.successfulBids;
      case 2:
        return controller.failedBids;
      default:
        return [];
    }
  }

  Widget _buildBidCard(Map<String, dynamic> bid) {
    return InkWell(
      onTap: () {
        if (controller.selectedTab.value == 2) {
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
                    Icon(
                      Icons.emoji_events,
                      size: 50,
                      color: Colors.amber,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Auction Winner',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      bid['winnerName'] ?? 'Unknown Winner',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.hijauTua,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Winning Bid: ${NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(bid['winningBid'] ?? 0)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.hijauTua,
                        minimumSize: Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (controller.selectedTab.value == 1) {
          Get.toNamed(Routes.CLOSED_AUCTION, arguments: {
            'itemId': bid['itemId'],
            'itemName': bid['itemName'],
            'winningBid': bid['userBid'],
            'imageUrl': bid['imageUrl'],
            'province': bid['province'],
            'sellerId': bid['sellerId'],
          });
        } else {
          Get.toNamed(Routes.LIVE_AUCTION, arguments: {
            'itemId': bid['itemId'],
            'itemName': bid['itemName'],
            'currentPrice': bid['currentPrice'],
            'imageUrls': [bid['imageUrl']],
            'location': bid['location'],
            'tanggal': bid['tanggal'],
            'jamMulai': bid['jamMulai'],
            'jamSelesai': bid['jamSelesai'],
            'category': bid['category'],
            'rarity': bid['rarity'],
            'description': bid['description'],
            'sellerId': bid['sellerId'],
          });
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  bid['imageUrl'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid['itemName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your bid: ${NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(bid['userBid'])}',
                      style: TextStyle(
                        color: AppColors.hijauTua,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          bid['location'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 30,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
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
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({bool isSearching = false}) {
    String message;
    if (isSearching) {
      message = 'No bids found matching your search';
    } else {
      switch (controller.selectedTab.value) {
        case 0:
          message = 'No ongoing bids';
          break;
        case 1:
          message = 'No successful bids yet';
          break;
        case 2:
          message = 'No failed bids';
          break;
        default:
          message = 'No bids found';
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.gavel,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
