import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:lelang_fb/app/services/auction_service.dart'; // Add this import
import '../../list_favorite/controllers/list_favorite_controller.dart';
import '../../../routes/app_pages.dart';

class DetailItemController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  var isExpanded = false.obs;
  var isFavorite = false.obs;
  final itemImages = <String>[].obs;
  final currentCarouselIndex = 0.obs;
  final userData = Rxn<Map<String, dynamic>>();
  final totalItems = 0.obs;
  final sellerName = ''.obs;
  final sellerEmail = ''.obs;
  final sellerJoinDate = ''.obs;
  final isVerifiedSeller = false.obs;
  final currentPrice = 0.0.obs;

  StreamSubscription<DocumentSnapshot>? _itemStatusSubscription;
  final itemStatus = ''.obs;
  String? itemId;
  DateTime? auctionDate;
  String? startTime;

  final itemData = Rxn<Map<String, dynamic>>();
  final isLiveDialogShown = false.obs;

  String _extractProvince(String location) {
    final parts = location.split(',');
    if (parts.length > 1) {
      return parts[1].trim();
    }
    return location.trim();
  }

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> item = Get.arguments ?? {};
    itemId = item['id'];
    itemData.value = item;
    currentPrice.value =
        (item['current_price'] ?? item['starting_price'])?.toDouble() ?? 0.0;

    if (item['tanggal'] is Timestamp) {
      auctionDate = (item['tanggal'] as Timestamp).toDate();
    }
    startTime = item['jamMulai'];

    if (item['lokasi'] != null) {
      item['location'] = item['province'] ?? _extractProvince(item['lokasi']);
    }

    final sellerId = item['seller_id'];
    if (sellerId != null) {
      fetchSellerData(sellerId);
    }

    if (item['imageURL'] != null) {
      if (item['imageURL'] is List) {
        itemImages.value = List<String>.from(item['imageURL']);
      } else {
        itemImages.value = [item['imageURL'].toString()];
      }
    }

    setupItemDataListener();
  }

  @override
  void onClose() {
    _itemStatusSubscription?.cancel();
    super.onClose();
  }

  Future<void> checkFavoriteStatus(String itemId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(itemId)
            .get();

        isFavorite.value = doc.exists;
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> toggleFavorite(Map<String, dynamic> item) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Please login to add favorites');
        return;
      }

      final favoriteRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(item['id']);

      if (isFavorite.value) {
        await favoriteRef.delete();
        Get.snackbar('Success', 'Removed from favorites');
      } else {
        await favoriteRef.set({
          'id': item['id'],
          'name': item['name'],
          'current_price': item['current_price'],
          'imageURL':
              item['imageURL'] is List ? item['imageURL'][0] : item['imageURL'],
          'lokasi': _extractProvince(item['lokasi'] ?? 'Unknown Province'),
          'tanggal': item['tanggal'],
          'jamMulai': item['jamMulai'],
          'jamSelesai': item['jamSelesai'],
          'status': item['status'],
          'seller_id': item['seller_id'],
          'rarity': item['rarity'],
          'description': item['description'],
          'addedAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar('Success', 'Added to favorites');
      }

      isFavorite.toggle();

      try {
        if (Get.isRegistered<ListFavoriteController>()) {
          final listFavoriteController = Get.find<ListFavoriteController>();
          listFavoriteController.setupFavoritesStream();
        }
      } catch (e) {
        print('ListFavoriteController not found: $e');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      Get.snackbar('Error', 'Failed to update favorites');
    }
  }

  Future<void> fetchSellerData(String sellerId) async {
    try {
      final doc = await _firestore.collection('users').doc(sellerId).get();
      if (doc.exists) {
        final data = doc.data()!;
        userData.value = data;

        sellerName.value = data['displayName'] ?? 'Anonymous';
        sellerEmail.value = data['email'] ?? '';
        isVerifiedSeller.value = data['isVerified'] ?? false;

        if (data['createdAt'] != null) {
          final joinDate = (data['createdAt'] as Timestamp).toDate();
          sellerJoinDate.value = DateFormat('MMM yyyy').format(joinDate);
        }

        final itemsQuery = await _firestore
            .collection('items')
            .where('seller_id', isEqualTo: sellerId)
            .count()
            .get();

        totalItems.value = itemsQuery.count ?? 0;
      }
    } catch (e) {
      print('Error fetching seller data: $e');
    }
  }

  void setupItemDataListener() {
    if (itemId == null) return;

    _itemStatusSubscription = _firestore
        .collection('items')
        .doc(itemId)
        .snapshots()
        .listen((docSnapshot) {
      if (!docSnapshot.exists) return;

      final data = docSnapshot.data()!;
      final oldStatus = itemStatus.value;
      final newStatus = data['status']?.toString().toLowerCase() ?? '';

      // Update full item data including location and seller info
      itemData.value = {
        ...data,
        'id': itemId,
        'current_price': (data['current_price'] ?? 0.0).toDouble(),
        'location': _extractProvince(data['lokasi'] ?? 'Unknown Province'),
        'category': data['category'] ?? 'Others',
        'rarity': data['rarity'] ?? 'Common',
      };

      itemStatus.value = newStatus;
      currentPrice.value =
          (data['current_price'] ?? data['starting_price'])?.toDouble() ?? 0.0;

      if (oldStatus != 'live' &&
          newStatus == 'live' &&
          !isLiveDialogShown.value) {
        // Update auction status with AuctionService
        AuctionService.checkAndUpdateStatus(
            _firestore.collection('items').doc(itemId));
        showAuctionStartDialog(itemData.value!);
        isLiveDialogShown.value = true;

        // Send notification to all users who favorited this item
        _notifyFavoriteUsers(itemData.value!);
      }
    });
  }

  // Add this new method
  Future<void> _notifyFavoriteUsers(Map<String, dynamic> itemData) async {
    try {
      final favoritesSnapshot = await _firestore
          .collectionGroup('favorites')
          .where('id', isEqualTo: itemId)
          .get();

      for (var doc in favoritesSnapshot.docs) {
        final userId = doc.reference.parent.parent?.id;
        if (userId != null && userId != itemData['seller_id']) {
          await AuctionService.sendNotification(
            userId: userId,
            title: 'Auction Started!',
            message: '${itemData['name']} auction is now live!',
            type: 'auction_start',
            itemId: itemId!,
          );
        }
      }
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  void showAuctionStartDialog(Map<String, dynamic> itemData) {
    final completeItemData = {
      ...itemData,
      'id': itemId,
      'itemId': itemId,
      'itemName': itemData['name'],
      'currentPrice': currentPrice.value,
      'imageUrls': itemData['imageURL'],
      'location': itemData['lokasi'],
      'category': itemData['category'],
      'rarity': itemData['rarity'],
      'description': itemData['description'],
      'tanggal': itemData['tanggal'],
      'jamMulai': itemData['jamMulai'],
      'jamSelesai': itemData['jamSelesai'],
      'sellerId': itemData['seller_id'],
    };

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Live Animation Container
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.live_tv,
                      color: Colors.red,
                      size: 40,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Auction is Live!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                itemData['name'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Starting Bid',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rp ${NumberFormat('#,###').format(currentPrice.value)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          _extractProvince(
                              itemData['lokasi'] ?? 'Unknown Location'),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Later',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.offNamed(
                          Routes.LIVE_AUCTION,
                          arguments: completeItemData,
                        );
                      },
                      child: Text(
                        'Join Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black87,
    );
  }
}
