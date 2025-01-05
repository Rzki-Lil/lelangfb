import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lelang_fb/app/modules/home/controllers/home_controller.dart';
import 'package:lelang_fb/app/utils/text.dart';
import 'package:lelang_fb/app/widgets/header.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:get/get.dart';

import '../controllers/detail_item_controller.dart';

class DetailItemView extends GetView<DetailItemController> {
  const DetailItemView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> item = Get.arguments ?? {};

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkFavoriteStatus(item['id']);
    });

    String safeGetString(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      return value.toString();
    }

    DateTime itemDate;
    try {
      if (item['tanggal'] is Timestamp) {
        itemDate = (item['tanggal'] as Timestamp).toDate();
      } else {
        itemDate = DateTime.now();
      }
    } catch (e) {
      print('Error parsing date: $e');
      itemDate = DateTime.now();
    }

    String formattedDate =
        "${itemDate.day} ${_getMonthName(itemDate.month)} ${itemDate.year}";

    List<String> getCarouselImages(Map<String, dynamic> item) {
      List<String> images = [];

      var imageURLs = item['imageURL'];
      if (imageURLs is List) {
        images.addAll(imageURLs.map((e) => e.toString()));
      }

      if (images.isEmpty) {
        images.add('assets/logo/lelangv2.png');
      }

      return images;
    }

    final List<String> allImages = getCarouselImages(item);

    final sellerId = item['seller_id'];
    if (sellerId != null) {
      controller.fetchSellerData(sellerId);
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: Header(
        title: 'Detail Item',
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.hijauTua),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Carousel Section with Indicators
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 1,
                    enableInfiniteScroll: allImages.length > 1,
                    autoPlay: allImages.length > 1,
                    onPageChanged: (index, reason) {
                      controller.currentCarouselIndex.value = index;
                    },
                  ),
                  items: allImages.map((imageUrl) {
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
                if (allImages.length > 1)
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: allImages.asMap().entries.map((entry) {
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
                        )),
                  ),
              ],
            ),

            // Item Details and Price Section
            Container(
              padding: EdgeInsets.all(16),
              color: AppColors.hijauTua,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          safeGetString(item['name'], 'No Name'),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Updated favorite button with white background
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() => IconButton(
                              onPressed: () => controller.toggleFavorite(item),
                              icon: Icon(
                                controller.isFavorite.value
                                    ? Icons.favorite
                                    : Icons.favorite_border_outlined,
                                color: controller.isFavorite.value
                                    ? Colors.white
                                    : Colors.white,
                                size: 23,
                              ),
                            )),
                      ),
                    ],
                  ),
                  Text(
                    'Starting Price',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Rp ${safeGetString(item['starting_price'], '0')}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Details Sections
            Container(
              margin: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Item Details Card
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
                                  _extractProvince(
                                      item['lokasi'] ?? 'Unknown Province'),
                                ),
                                _buildDetailRow(
                                  Icons.calendar_today_outlined,
                                  'Auction Date',
                                  formattedDate,
                                ),
                                _buildDetailRow(
                                  Icons.access_time,
                                  'Start Time',
                                  safeGetString(item['jamMulai'], '--:--'),
                                ),
                                _buildDetailRow(
                                  Icons.category_outlined,
                                  'Category',
                                  safeGetString(item['category'], 'Others'),
                                ),
                                _buildDetailRow(
                                  Icons.star_outline,
                                  'Rarity',
                                  safeGetString(item['rarity'], 'Common'),
                                  color: _getRarityColor(
                                      safeGetString(item['rarity'], 'Common')),
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
                                          controller.isExpanded.toggle(),
                                      child: Obx(() => Text(
                                            controller.isExpanded.value
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
                                      safeGetString(item['description'],
                                          'No description available'),
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        height: 1.5,
                                      ),
                                      maxLines: controller.isExpanded.value
                                          ? null
                                          : 3,
                                      overflow: controller.isExpanded.value
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

                  SizedBox(height: 16),

                  // Seller Information Card
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Obx(() => CircleAvatar(
                                        radius: 24,
                                        backgroundImage: controller.userData
                                                    .value?['photoURL'] !=
                                                null
                                            ? NetworkImage(controller
                                                .userData.value!['photoURL'])
                                            : null,
                                        child: controller.userData
                                                    .value?['photoURL'] ==
                                                null
                                            ? Icon(Icons.person,
                                                color: Colors.grey[400])
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
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                )),
                                            SizedBox(width: 4),
                                            Obx(() => controller
                                                    .isVerifiedSeller.value
                                                ? Icon(Icons.verified,
                                                    color: AppColors.hijauTua,
                                                    size: 16)
                                                : SizedBox()),
                                          ],
                                        ),
                                        Obx(() => Text(
                                              controller.sellerEmail.value,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // ...rest of the seller card code...
                            ],
                          ),
                          Divider(height: 24, color: Colors.grey[200]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Obx(() => _buildSellerStat(
                                    'Items',
                                    controller.totalItems.value.toString(),
                                    Icons.inventory_2_outlined,
                                  )),
                              Container(
                                height: 24,
                                width: 1,
                                color: Colors.grey.shade200,
                              ),
                              Obx(() => _buildSellerStat(
                                    'Rating',
                                    '${(controller.userData.value?['rating'] ?? 0.0).toStringAsFixed(1)}',
                                    Icons.star_outline,
                                  )),
                              Container(
                                height: 24,
                                width: 1,
                                color: Colors.grey.shade200,
                              ),
                              Obx(() => _buildSellerStat(
                                    'Joined',
                                    controller.sellerJoinDate.value,
                                    Icons.calendar_today_outlined,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red),
          SizedBox(height: 8),
          Text('Failed to load image',
              style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

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

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _extractProvince(String location) {
    final parts = location.split(',');
    if (parts.length > 1) {
      return parts[1].trim();
    }
    return location.trim();
  }

  Widget _buildSellerInfo(String? sellerId) {
    if (sellerId == null) {
      return const SizedBox();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(sellerId)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (userSnapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Error loading seller info'),
              ],
            ),
          );
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        if (userData == null) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.person_off_outlined),
                SizedBox(width: 8),
                Text('Seller not found'),
              ],
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('items')
              .where('seller_id', isEqualTo: sellerId)
              .snapshots(),
          builder: (context, itemsSnapshot) {
            int totalItems = 0;
            if (itemsSnapshot.hasData) {
              totalItems = itemsSnapshot.data!.docs.length;
            }

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: userData['photoURL'] != null
                              ? CachedNetworkImageProvider(userData['photoURL'])
                              : null,
                          child: userData['photoURL'] == null
                              ? Icon(Icons.person,
                                  size: 35, color: Colors.grey[400])
                              : null,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    userData['displayName'] ??
                                        'Anonymous Seller',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (userData['isVerified'] == true)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.verified,
                                        color: AppColors.hijauTua,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                userData['email'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Divider(
                      color: Colors.green.shade200,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSellerStat(
                          'Items',
                          totalItems.toString(),
                          Icons.inventory_2_outlined,
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        Obx(() => _buildSellerStat(
                              'Rating',
                              '${(controller.userData.value?['rating'] ?? 0.0).toStringAsFixed(1)}',
                              Icons.star_outline,
                            )),
                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        Obx(() => _buildSellerStat(
                              'Joined',
                              _getJoinedDate(
                                  controller.userData.value?['createdAt']),
                              Icons.calendar_today_outlined,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

  String _getJoinedDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'N/A';
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
