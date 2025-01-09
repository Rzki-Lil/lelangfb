import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';

class ListFavoriteController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final favoriteItems = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  StreamSubscription<QuerySnapshot>? _favoritesSubscription;
  Map<String, StreamSubscription<DocumentSnapshot>> _itemStatusSubscriptions =
      {};

  @override
  void onInit() {
    super.onInit();
    setupFavoritesStream();
  }

  @override
  void onClose() {
    _favoritesSubscription?.cancel();
    for (var sub in _itemStatusSubscriptions.values) {
      sub.cancel();
    }
    _itemStatusSubscriptions.clear();
    searchController.dispose();
    super.onClose();
  }

  void setupFavoritesStream() {
    final user = _auth.currentUser;
    if (user != null) {
      _favoritesSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .snapshots()
          .listen((snapshot) async {
        List<Map<String, dynamic>> updatedItems = [];

        for (var sub in _itemStatusSubscriptions.values) {
          sub.cancel();
        }
        _itemStatusSubscriptions.clear();

        for (var doc in snapshot.docs) {
          final itemId = doc.id;
          _setupItemStatusListener(itemId);

          final itemDoc =
              await _firestore.collection('items').doc(itemId).get();

          if (itemDoc.exists) {
            final itemData = itemDoc.data()!;
            final status = itemData['status']?.toString().toLowerCase() ?? '';

            if (status != 'closed') {
              updatedItems.add({
                ...itemData,
                'id': itemId,
                'status': status,
              });
            }
          }
        }

        favoriteItems.value = updatedItems;
        isLoading.value = false;
      }, onError: (error) {
        print('Error in favorites stream: $error');
        isLoading.value = false;
      });
    }
  }

  void _setupItemStatusListener(String itemId) {
    _itemStatusSubscriptions[itemId] = _firestore
        .collection('items')
        .doc(itemId)
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final currentStatus = data['status']?.toString().toLowerCase() ?? '';

        if (currentStatus == 'closed') {
          // Silently remove from favorites without showing dialog
          removeFromFavorites(itemId);
          return;
        }

        final index = favoriteItems.indexWhere((item) => item['id'] == itemId);
        if (index != -1) {
          final updatedItem = {
            ...favoriteItems[index],
            ...data,
            'id': itemId,
            'status': currentStatus,
          };
          favoriteItems[index] = updatedItem;
          favoriteItems.refresh();
        }
      }
    });
  }

  String getProvinceOnly(String? location) {
    if (location == null || location.isEmpty) return 'No location';

    final parts = location.split(',');
    if (parts.length > 1) {
      return parts.last.trim();
    }

    return location.trim();
  }

  List<Map<String, dynamic>> getFilteredItems() {
    final itemsWithFormattedLocation = favoriteItems.map((item) {
      final displayLocation = getProvinceOnly(item['lokasi']);
      return {
        ...item,
        'displayLocation': displayLocation,
        'formattedDate': _formatDateTime(item['tanggal'] as Timestamp),
      };
    }).toList();

    if (searchQuery.isEmpty) {
      return itemsWithFormattedLocation;
    }

    return itemsWithFormattedLocation.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      final location = item['displayLocation'].toString().toLowerCase();
      final search = searchQuery.value.toLowerCase();

      return name.contains(search) || location.contains(search);
    }).toList();
  }

  String _formatDateTime(Timestamp date) {
    final dateTime = date.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<void> removeFromFavorites(String itemId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(itemId)
            .delete();

        Get.snackbar('Success', 'Removed from favorites');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove from favorites');
    }
  }

  Future<void> navigateToDetail(Map<String, dynamic> item) async {
    try {
      final itemDoc =
          await _firestore.collection('items').doc(item['id']).get();

      if (itemDoc.exists) {
        final data = itemDoc.data()!;
        final firestoreStatus = data['status']?.toString().toLowerCase() ?? '';

        if (firestoreStatus == 'closed') {
          await removeFromFavorites(item['id']);
          return;
        }

        final fullItemData = {
          ...data,
          'id': itemDoc.id,
          'itemId': itemDoc.id,
          'itemName': data['name'],
          'currentPrice': (data['current_price'] ?? 0.0).toDouble(),
          'tanggal': data['tanggal'],
          'jamSelesai': data['jamSelesai'],
          'jamMulai': data['jamMulai'],
          'imageUrls': data['imageURL'],
          'location': data['lokasi'],
          'category': data['category'],
          'rarity': data['rarity'],
          'description': data['description'],
          'sellerId': data['seller_id'],
          'status': firestoreStatus,
          'bid_count': data['bid_count'] ?? 0,
        };

        if (firestoreStatus == 'live') {
          Get.toNamed(Routes.LIVE_AUCTION, arguments: fullItemData);
        } else {
          Get.toNamed(Routes.DETAIL_ITEM, arguments: fullItemData);
        }
      }
    } catch (e) {
      print('Error navigating to detail: $e');
      Get.snackbar('Error', 'Could not load item details');
    }
  }

  String _determineRealTimeStatus(
      DateTime itemDate, String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return 'upcoming';

    final now = DateTime.now();
    final startTimeParts = startTime.split(':');
    final endTimeParts = endTime.split(':');

    if (startTimeParts.length != 2 || endTimeParts.length != 2)
      return 'upcoming';

    final auctionStart = DateTime(
      itemDate.year,
      itemDate.month,
      itemDate.day,
      int.parse(startTimeParts[0]),
      int.parse(startTimeParts[1]),
    );

    final auctionEnd = DateTime(
      itemDate.year,
      itemDate.month,
      itemDate.day,
      int.parse(endTimeParts[0]),
      int.parse(endTimeParts[1]),
    );

    if (now.isBefore(auctionStart)) {
      return 'upcoming';
    } else if (now.isAfter(auctionStart) && now.isBefore(auctionEnd)) {
      return 'live';
    } else {
      return 'closed';
    }
  }
}
