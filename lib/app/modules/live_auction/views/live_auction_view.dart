import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color.dart';
import '../controllers/live_auction_controller.dart';
import '../../../widgets/header.dart';

class LiveAuctionView extends GetView<LiveAuctionController> {
  const LiveAuctionView({super.key});

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      case 'mythic':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: Header(
        title: 'Live Auction',
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.hijauTua),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1,
                      enableInfiniteScroll: controller.itemImages.length > 1,
                      autoPlay: controller.itemImages.length > 1,
                      onPageChanged: (index, reason) {
                        controller.currentCarouselIndex.value = index;
                      },
                    ),
                    items: controller.itemImages.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  if (controller.itemImages.length > 1)
                    Positioned(
                      bottom: 15,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            controller.itemImages.asMap().entries.map((entry) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: controller.currentCarouselIndex.value ==
                                    entry.key
                                ? 20
                                : 8,
                            height: 8,
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: controller.currentCarouselIndex.value ==
                                      entry.key
                                  ? AppColors.hijauTua
                                  : Colors.white.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),

              // Item Details Section
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                color: AppColors.hijauTua,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.itemName.value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Bid:',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'id',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(controller.currentPrice.value),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.timer, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                controller.timeRemaining.value,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Balance:',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(controller.userBalance.value),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Item Details Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          title: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: AppColors.hijauTua, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Item Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                    Icons.location_on_outlined,
                                    'Location',
                                    controller.itemLocation.value,
                                  ),
                                  _buildDetailRow(
                                    Icons.category_outlined,
                                    'Category',
                                    controller.itemCategory.value,
                                  ),
                                  _buildDetailRow(
                                    Icons.star_outline,
                                    'Rarity',
                                    controller.itemRarity.value,
                                    color: _getRarityColor(
                                        controller.itemRarity.value),
                                  ),
                                  Divider(color: Colors.grey.shade200),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Description',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            controller.toggleDescription(),
                                        child: Obx(() => Text(
                                              controller.isDescriptionExpanded
                                                      .value
                                                  ? 'Show Less'
                                                  : 'Show More',
                                              style: TextStyle(
                                                color: AppColors.hijauTua,
                                                fontSize: 12,
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Obx(() => Text(
                                        controller.itemDescription.value,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          height: 1.5,
                                        ),
                                        maxLines: controller
                                                .isDescriptionExpanded.value
                                            ? null
                                            : 3,
                                        overflow: controller
                                                .isDescriptionExpanded.value
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Seller Information Card - Updated Design
                    SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Obx(() => CircleAvatar(
                                      radius: 24,
                                      backgroundImage: controller
                                              .sellerPhotoUrl.value.isNotEmpty
                                          ? NetworkImage(
                                              controller.sellerPhotoUrl.value)
                                          : null,
                                      child: controller
                                              .sellerPhotoUrl.value.isEmpty
                                          ? Icon(Icons.person, size: 24)
                                          : null,
                                    )),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Obx(() => Text(
                                                controller.sellerName.value,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )),
                                          SizedBox(width: 4),
                                          Obx(() =>
                                              controller.isVerifiedSeller.value
                                                  ? Icon(Icons.verified,
                                                      color: AppColors.hijauTua,
                                                      size: 16)
                                                  : SizedBox()),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.star,
                                              color: Colors.amber, size: 16),
                                          SizedBox(width: 4),
                                          Obx(() => Text(
                                                '${controller.sellerRating.value.toStringAsFixed(1)} (${controller.totalReviews.value} reviews)',
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 24,
                              color: Colors.grey[200],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSellerStat(
                                  'Total Items',
                                  controller.sellerTotalItems.value.toString(),
                                  Icons.inventory_2_outlined,
                                ),
                                _buildSellerStat(
                                  'Member Since',
                                  controller.sellerJoinDate.value,
                                  Icons.calendar_today_outlined,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top Bidders Section
                    SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Bidders',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: controller.topBidders.length,
                              itemBuilder: (context, index) {
                                final bidder = controller.topBidders[index];
                                return Card(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: bidder['bidder_photo'] !=
                                              null
                                          ? CachedNetworkImageProvider(bidder['bidder_photo'])
                                          : null,
                                      child: bidder['bidder_photo'] == null
                                          ? Icon(Icons.person)
                                          : null,
                                    ),
                                    title: Text(
                                        bidder['bidder_name'] ?? 'Anonymous'),
                                    subtitle: Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(
                                        (bidder['timestamp'] as DateTime),
                                      ),
                                    ),
                                    trailing: Text(
                                      NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp ',
                                        decimalDigits: 0,
                                      ).format(bidder['amount']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.hijauTua,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (!controller.isAuctionEnded.value) ...[
                      SizedBox(height: 16),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Place Your Bid',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Minimum bid: Rp ${NumberFormat('#,###').format(controller.currentPrice.value + 10000)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 12),
                              TextField(
                                controller: controller.bidController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Bid Amount',
                                  prefixText: 'Rp ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: AppColors.hijauTua),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.send,
                                        color: AppColors.hijauTua),
                                    onPressed: () {
                                      if (controller
                                          .bidController.text.isNotEmpty) {
                                        final bidAmount = double.parse(
                                            controller.bidController.text);
                                        if (bidAmount <=
                                            controller.userBalance.value) {
                                          controller.placeBid(bidAmount);
                                        } else {
                                          Get.snackbar(
                                            'Insufficient Balance',
                                            'Please top up your balance to place this bid',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSellerStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.hijauTua, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.hijauTua),
          SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: color ?? Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

}
