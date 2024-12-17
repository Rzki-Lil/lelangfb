import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lelang_fb/app/utils/text.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get_connect/connect.dart';
import 'package:get/get.dart';

import '../../../../core/assets/assets.gen.dart';
import '../controllers/detail_item_controller.dart';

class DetailItemView extends GetView<DetailItemController> {
  const DetailItemView({super.key});

  String safeConcat(String label, dynamic value) {
    return "$label${value?.toString() ?? 'N/A'}";
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> item = Get.arguments ?? {};
    final CarouselSliderController carouselController =
        CarouselSliderController();

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('Item Detail'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 300,
                      autoPlay: allImages.length > 1,
                      autoPlayInterval: Duration(seconds: 3),
                      initialPage: 0,
                      viewportFraction: 1,
                      enableInfiniteScroll: allImages.length > 1,
                      onPageChanged: (index, reason) {
                        controller.currentPage.value = index;
                      },
                    ),
                    carouselController: carouselController,
                    itemCount: allImages.length,
                    itemBuilder: (context, index, realIndex) {
                      final imageUrl = allImages[index];
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl.startsWith('http')
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading image: $error');
                                    return _buildErrorWidget();
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return _buildLoadingWidget();
                                  },
                                )
                              : Image.asset(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading asset: $error');
                                    return _buildErrorWidget();
                                  },
                                ),
                        ),
                      );
                    },
                  ),
                  if (allImages.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: allImages.asMap().entries.map((entry) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      controller.currentPage.value == entry.key
                                          ? AppColors.hijauTua
                                          : Colors.white,
                                ),
                              );
                            }).toList(),
                          )),
                    ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextCust(
                      fontSize: 24,
                      color: AppColors.black,
                      text: safeGetString(item['name'], 'No Name'),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColors.grey,
                    ),
                    width: 40,
                    height: 40,
                    child: Obx(
                      () {
                        return IconButton(
                          onPressed: () {
                            controller.isClicked.value =
                                !controller.isClicked.value;
                          },
                          icon: Icon(
                            controller.isClicked.value
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                            color: controller.isClicked.value
                                ? Colors.green
                                : Colors.white,
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
              TextCust(
                fontSize: 12,
                color: AppColors.grey,
                text: "Current Price",
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextCust(
                    fontSize: 24,
                    color: AppColors.hijauMuda,
                    text: "Rp ${safeGetString(item['current_price'], '0')}",
                    fontWeight: FontWeight.bold,
                  ),
                  _buildBadge(
                    safeGetString(item['rarity'], 'Common'),
                    _getRarityColor(safeGetString(item['rarity'], 'Common')),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextCust(
                fontSize: 16,
                color: AppColors.black,
                text: "Schedule   : $formattedDate",
              ),
              TextCust(
                fontSize: 16,
                color: AppColors.black,
                text:
                    "Location    : ${safeGetString(item['lokasi'], 'No location')}",
              ),
              SizedBox(height: 16),
              Card(
                margin: EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppColors.hijauTua,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            TextCust(
                              fontSize: 18,
                              text: "Item Description",
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.green.shade200,
                          thickness: 1,
                          height: 24,
                        ),
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedCrossFade(
                                  firstChild: TextCust(
                                    fontSize: 14,
                                    text: safeGetString(item['description'],
                                        'No description available'),
                                    color: AppColors.black,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  secondChild: TextCust(
                                    fontSize: 14,
                                    text: safeGetString(item['description'],
                                        'No description available'),
                                    color: AppColors.black,
                                  ),
                                  crossFadeState: controller.isExpanded.value
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: Duration(milliseconds: 300),
                                ),
                                if ((safeGetString(item['description'], '')
                                        .length >
                                    100))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Center(
                                      child: InkWell(
                                        onTap: () =>
                                            controller.isExpanded.toggle(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              controller.isExpanded.value
                                                  ? 'Show Less'
                                                  : 'Show More',
                                              style: TextStyle(
                                                color: AppColors.hijauTua,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            AnimatedRotation(
                                              turns: controller.isExpanded.value
                                                  ? 0.5
                                                  : 0,
                                              duration:
                                                  Duration(milliseconds: 300),
                                              child: Icon(
                                                Icons.keyboard_arrow_down,
                                                color: AppColors.hijauTua,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ),
//title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: AppColors.hijauTua,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    TextCust(
                      fontSize: 18,
                      text: "Seller Information",
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildSellerInfo(item['seller_id']?.toString()),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            color: AppColors.hijauTua,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Auction Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item['status'] ?? 'upcoming')
                              .withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (item['status'] ?? 'upcoming').toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [],
              )
            ],
          ),
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
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
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
                        IconButton(
                          icon: Icon(Icons.message_outlined),
                          color: AppColors.hijauTua,
                          onPressed: () => _handleChatWithSeller(sellerId),
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
                        _buildSellerStat(
                          'Rating',
                          '${(userData['rating'] ?? 0.0).toStringAsFixed(1)}',
                          Icons.star_outline,
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        _buildSellerStat(
                          'Joined',
                          _getJoinedDate(userData['createdAt']),
                          Icons.calendar_today_outlined,
                        ),
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

  void _handleChatWithSeller(String sellerId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Sign in Required',
        'Please sign in to chat with the seller',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (currentUser.uid == sellerId) {
      Get.snackbar(
        'Note',
        'This is your own listing',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return Colors.green;
      case 'ended':
        return Colors.red;
      case 'upcoming':
      default:
        return Colors.blue;
    }
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class TextImageColumn extends StatelessWidget {
  final String image;
  final String text;
  final double width;
  final double height;
  final double? fontSize;
  const TextImageColumn({
    super.key,
    required this.text,
    required this.image,
    required this.width,
    required this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Image.asset(
            image,
            width: width,
          ),
          TextCust(
              textAlign: TextAlign.center,
              text: text,
              fontSize: fontSize ?? 14),
        ],
      ),
    );
  }
}
