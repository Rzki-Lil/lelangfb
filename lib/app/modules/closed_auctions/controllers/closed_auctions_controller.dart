import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClosedAuctionsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final wonAuctions = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final tempRating = 0.obs;
  final isRatingSubmitting = false.obs;
  final singleAuction = Rxn<Map<String, dynamic>>();
  final isSingleView = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['itemId'] != null) {
      isSingleView.value = true;
      fetchSingleAuction(args['itemId']);
    } else {
      fetchWonAuctions();
    }
  }

  Future<void> fetchWonAuctions() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final querySnapshot = await _firestore
          .collection('items')
          .where('status', isEqualTo: 'closed')
          .where('winner_id', isEqualTo: userId)
          .get();

      wonAuctions.value = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data();
          final sellerId = data['seller_id'];

          final sellerDoc =
              await _firestore.collection('users').doc(sellerId).get();
          final sellerData = sellerDoc.data() ?? {};

          final ratingDoc = await _firestore
              .collection('seller_ratings')
              .where('auction_id', isEqualTo: doc.id)
              .where('user_id', isEqualTo: userId)
              .get();

          return {
            'id': doc.id,
            'seller_id': sellerId,
            'name': data['name'] ?? 'Unnamed Item',
            'imageUrl': data['imageURL']?[0] ?? '',
            'winning_bid': data['current_price'] ?? 0.0,
            'location': data['lokasi'] ?? '',
            'seller_name': sellerData['displayName'] ?? 'Unknown Seller',
            'seller_photo': sellerData['photoURL'] ?? '',
            'seller_phone': sellerData['phone'] ?? '',
            'seller_email': sellerData['email'] ?? '',
            'seller_joinDate': sellerData['createdAt'],
            'completion_date': data['updated_at'],
            'category': data['category'] ?? '',
            'description': data['description'] ?? '',
            'hasRated': ratingDoc.docs.isNotEmpty,
            'seller_rating': sellerData['rating'] ?? 0.0,
            'seller_ratingCount': sellerData['ratingCount'] ?? 0,
            'seller_totalItems': await getSellerTotalItems(sellerId),
            'seller_successfulSales': await getSellerSuccessfulSales(sellerId),
          };
        }),
      );

      isLoading.value = false;
    } catch (e) {
      print('Error fetching won auctions: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchSingleAuction(String itemId) async {
    try {
      isLoading.value = true;
      final doc = await _firestore.collection('items').doc(itemId).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final sellerId = data['seller_id'];
      final sellerDoc =
          await _firestore.collection('users').doc(sellerId).get();
      final sellerData = sellerDoc.data() ?? {};

      final userId = _auth.currentUser?.uid;
      final ratingDoc = await _firestore
          .collection('seller_ratings')
          .where('auction_id', isEqualTo: itemId)
          .where('user_id', isEqualTo: userId)
          .get();

      singleAuction.value = {
        'id': doc.id,
        'seller_id': sellerId,
        'name': data['name'] ?? 'Unnamed Item',
        'imageUrl': data['imageURL']?[0] ?? '',
        'winning_bid': data['current_price'] ?? 0.0,
        'location': data['lokasi'] ?? '',
        'seller_name': sellerData['displayName'] ?? 'Unknown Seller',
        'seller_photo': sellerData['photoURL'] ?? '',
        'seller_phone': sellerData['phoneNumber'] ?? '',
        'seller_email': sellerData['email'] ?? '',
        'seller_joinDate': sellerData['createdAt'],
        'completion_date': data['updated_at'],
        'category': data['category'] ?? '',
        'description': data['description'] ?? '',
        'hasRated': ratingDoc.docs.isNotEmpty,
        'seller_rating': sellerData['rating'] ?? 0.0,
        'seller_ratingCount': sellerData['ratingCount'] ?? 0,
        'seller_totalItems': await getSellerTotalItems(sellerId),
        'seller_successfulSales': await getSellerSuccessfulSales(sellerId),
      };
    } catch (e) {
      print('Error fetching single auction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<int?> getSellerTotalItems(String sellerId) async {
    final itemsQuery = await _firestore
        .collection('items')
        .where('seller_id', isEqualTo: sellerId)
        .count()
        .get();
    return itemsQuery.count;
  }

  Future<int?> getSellerSuccessfulSales(String sellerId) async {
    final salesQuery = await _firestore
        .collection('items')
        .where('seller_id', isEqualTo: sellerId)
        .where('status', isEqualTo: 'closed')
        .count()
        .get();
    return salesQuery.count;
  }

  Future<void> submitSellerRating(
      String sellerId, String auctionId, int rating) async {
    try {
      if (sellerId.isEmpty || auctionId.isEmpty) {
        Get.snackbar(
          'Error',
          'Invalid seller or auction information',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      if (rating == 0) {
        Get.snackbar(
          'Error',
          'Please select a rating',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      isRatingSubmitting.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.runTransaction((transaction) async {
        final sellerRef = _firestore.collection('users').doc(sellerId);
        final sellerDoc = await transaction.get(sellerRef);

        if (!sellerDoc.exists) {
          throw 'Seller not found';
        }

        final currentRating = sellerDoc.data()?['rating'] ?? 0.0;
        final currentRatingCount = sellerDoc.data()?['ratingCount'] ?? 0;
        final newRatingCount = currentRatingCount + 1;
        final newRating =
            ((currentRating * currentRatingCount) + rating) / newRatingCount;

        transaction.update(sellerRef, {
          'rating': newRating,
          'ratingCount': newRatingCount,
        });

        final ratingRef = _firestore.collection('seller_ratings').doc();
        transaction.set(ratingRef, {
          'auction_id': auctionId,
          'seller_id': sellerId,
          'user_id': userId,
          'rating': rating,
          'timestamp': FieldValue.serverTimestamp(),
        });

        final auctionRef = _firestore.collection('items').doc(auctionId);
        transaction.update(auctionRef, {
          'rated_by_winner': true,
        });
      });

      if (isSingleView.value) {
        if (singleAuction.value != null) {
          final updatedAuction =
              Map<String, dynamic>.from(singleAuction.value!);
          updatedAuction['hasRated'] = true;
          updatedAuction['seller_rating'] = (updatedAuction['seller_rating'] *
                      updatedAuction['seller_ratingCount'] +
                  rating) /
              (updatedAuction['seller_ratingCount'] + 1);
          updatedAuction['seller_ratingCount'] =
              updatedAuction['seller_ratingCount'] + 1;
          singleAuction.value = updatedAuction;
        }
      } else {
        final index =
            wonAuctions.indexWhere((auction) => auction['id'] == auctionId);
        if (index != -1) {
          final updatedAuction = Map<String, dynamic>.from(wonAuctions[index]);
          updatedAuction['hasRated'] = true;
          updatedAuction['seller_rating'] = (updatedAuction['seller_rating'] *
                      updatedAuction['seller_ratingCount'] +
                  rating) /
              (updatedAuction['seller_ratingCount'] + 1);
          updatedAuction['seller_ratingCount'] =
              updatedAuction['seller_ratingCount'] + 1;
          wonAuctions[index] = updatedAuction;
        }
      }

      Get.snackbar(
        'Success',
        'Thank you for rating the seller',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error submitting rating: $e');
      Get.snackbar(
        'Error',
        'Failed to submit rating: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isRatingSubmitting.value = false;
      tempRating.value = 0;
    }
  }
}
