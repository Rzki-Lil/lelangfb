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

  @override
  void onInit() {
    super.onInit();
    setupFavoritesStream();
  }

  @override
  void onClose() {
    _favoritesSubscription?.cancel();
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
          .orderBy('addedAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        favoriteItems.value = snapshot.docs.map((doc) {
          final data = doc.data();
          return {...data, 'id': doc.id};
        }).toList();
        isLoading.value = false;
      }, onError: (error) {
        print('Error in favorites stream: $error');
        isLoading.value = false;
      });
    }
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
      print('Error removing favorite: $e');
      Get.snackbar('Error', 'Failed to remove from favorites');
    }
  }

  Future<void> navigateToDetail(Map<String, dynamic> item) async {
    try {
      final itemDoc =
          await _firestore.collection('items').doc(item['id']).get();

      if (itemDoc.exists) {
        final fullItemData = {
          ...itemDoc.data()!,
          'id': itemDoc.id,
        };

        Get.toNamed(Routes.DETAIL_ITEM, arguments: fullItemData);
      } else {
        Get.snackbar('Error', 'Item no longer exists',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error navigating to detail: $e');
      Get.snackbar('Error', 'Could not load item details');
    }
  }
}
