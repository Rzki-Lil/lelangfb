import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/assets/assets.gen.dart';

class TransactionController extends GetxController
    with SingleGetTickerProviderMixin {
  late TabController tabController;
  var selectedTab = 0.obs;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final ongoingBids = <Map<String, dynamic>>[].obs;
  final successfulBids = <Map<String, dynamic>>[].obs;
  final failedBids = <Map<String, dynamic>>[].obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final ongoingCount = 0.obs;
  final successCount = 0.obs;
  final failedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      selectedTab.value = tabController.index;
    });
    fetchBiddingHistory();
    updateCounts();
  }

  String _extractProvince(String location) {
    final parts = location.split(',');
    if (parts.length > 1) {
      return parts[1].trim(); 
    }
    return location.trim();
  }

  Future<void> fetchBiddingHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      ongoingBids.clear();
      successfulBids.clear();
      failedBids.clear();

      final itemsQuery = await _firestore.collection('items').get();

      for (var itemDoc in itemsQuery.docs) {
        final bidsQuery = await itemDoc.reference
            .collection('bids')
            .where('bidder_id', isEqualTo: userId)
            .get();

        if (bidsQuery.docs.isNotEmpty) {
          final itemData = itemDoc.data();
          final userHighestBid = bidsQuery.docs
              .map((bid) => bid.data()['amount'] as num)
              .reduce((max, amount) => amount > max ? amount : max);

          final currentHighestBid = itemData['current_price'] ?? 0;
          final isAuctionEnded = itemData['status'] == 'closed';
          final isWinner = itemData['winner_id'] == userId;

          String? winnerName;
          double? winningBid;
          if (itemData['status'] == 'closed' &&
              itemData['winner_id'] != userId) {
            final winnerDoc = await _firestore
                .collection('users')
                .doc(itemData['winner_id'])
                .get();
            winnerName = winnerDoc.data()?['displayName'] ?? 'Unknown User';
            winningBid = itemData['current_price']?.toDouble() ?? 0.0;
          }

          final bidData = {
            'itemId': itemDoc.id,
            'itemName': itemData['name'],
            'imageUrl': itemData['imageURL'][0],
            'currentPrice': currentHighestBid,
            'userBid': userHighestBid,
            'status': itemData['status'],
            'location':
                _extractProvince(itemData['lokasi'] ?? 'Unknown Province'),
            'tanggal': itemData['tanggal'],
            'jamMulai': itemData['jamMulai'],
            'jamSelesai': itemData['jamSelesai'],
            'category': itemData['category'],
            'rarity': itemData['rarity'],
            'description': itemData['description'],
            'sellerId': itemData['seller_id'],
            'winnerName': winnerName,
            'winningBid': winningBid,
          };

          if (!isAuctionEnded) {
            ongoingBids.add(bidData);
          } else if (isWinner) {
            successfulBids.add(bidData);
          } else if (isAuctionEnded && !isWinner) {
            failedBids.add(bidData);
          }
        }
      }

      updateCounts();
    } catch (e) {
      print('Error fetching bidding history: $e');
    }
  }

  Future<void> deleteBid(Map<String, dynamic> bid) async {
    try {
      final String title =
          selectedTab.value == 0 ? 'Delete Ongoing Bid' : 'Delete Failed Bid';
      final String message = selectedTab.value == 0
          ? 'Are you sure you want to delete this bid? You can still participate in this auction again.'
          : 'Are you sure you want to delete this bid from your history?';


      final bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      await _firestore
          .collection('items')
          .doc(bid['itemId'])
          .collection('bids')
          .where('bidder_id', isEqualTo: userId)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      if (selectedTab.value == 0) {
        ongoingBids.removeWhere((item) => item['itemId'] == bid['itemId']);
      } else {
        failedBids.removeWhere((item) => item['itemId'] == bid['itemId']);
      }

      updateCounts();

      if (Get.isDialogOpen!) Get.back();
      Get.snackbar(
        'Success',
        'Bid deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar(
        'Error',
        'Failed to delete bid: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void updateCounts() {
    ongoingCount.value = ongoingBids.length;
    successCount.value = successfulBids.length;
    failedCount.value = failedBids.length;

    print(
        'Counts updated - Ongoing: ${ongoingCount.value}, Success: ${successCount.value}, Failed: ${failedCount.value}');
  }

  List<Map<String, dynamic>> getFilteredBids() {
    final query = searchQuery.value.toLowerCase();
    final currentList = _getItemsForCurrentTab();

    if (query.isEmpty) return currentList;

    return currentList.where((bid) {
      return bid['itemName']?.toString().toLowerCase().contains(query) ??
          false || bid['location']!.toString().toLowerCase().contains(query) ??
          false;
    }).toList();
  }

  List<Map<String, dynamic>> _getItemsForCurrentTab() {
    switch (selectedTab.value) {
      case 0:
        return ongoingBids;
      case 1:
        return successfulBids;
      case 2:
        return failedBids;
      default:
        return [];
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
    super.onClose();
  }
}

class Ticket {
  final String gambar;
  final String name;
  final String price;
  final String date;
  final String location;
  final String status;

  Ticket(
    this.gambar,
    this.name,
    this.price,
    this.date,
    this.location,
    this.status,
  );
}
