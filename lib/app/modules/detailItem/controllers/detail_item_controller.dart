import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../list_favorite/controllers/list_favorite_controller.dart';

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
}
