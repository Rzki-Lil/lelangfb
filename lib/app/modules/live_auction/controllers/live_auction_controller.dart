import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class LiveAuctionController extends GetxController {
  final itemId = ''.obs;
  final itemName = ''.obs;
  final currentPrice = 0.0.obs;
  final timeRemaining = ''.obs;
  final imageUrl = ''.obs;
  final isLoading = true.obs;
  final topBidders = <Map<String, dynamic>>[].obs;
  final endTime = DateTime.now().obs;
  final bidController = TextEditingController();
  Timer? _timer;

  late Stream<DocumentSnapshot> itemStream;
  late Stream<QuerySnapshot> bidsStream;

  final itemImages = <String>[].obs;
  final itemLocation = ''.obs;
  final itemCategory = ''.obs;
  final itemRarity = ''.obs;
  final sellerName = ''.obs;
  final itemDescription = ''.obs;
  final userBalance = 0.0.obs;
  final isAuctionEnded = false.obs;

  final currentCarouselIndex = 0.obs;
  final sellerPhotoUrl = ''.obs;
  final isVerifiedSeller = false.obs;
  final sellerRating = 0.0.obs;
  final totalReviews = 0.obs;
  final sellerTotalItems = 0.obs;
  final successfulSales = 0.obs;
  final sellerJoinDate = ''.obs;

  final isDetailsExpanded = false.obs;
  final isSellerExpanded = false.obs;
  final isDescriptionExpanded = false.obs;
  final hasShownWinnerDialog = false.obs;

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
    final args = Get.arguments;
    itemId.value = args['itemId'] ?? '';
    itemName.value = args['itemName'] ?? '';
    currentPrice.value = args['currentPrice'] ?? 0.0;

    if (args['imageUrls'] != null) {
      if (args['imageUrls'] is List) {
        itemImages.value = List<String>.from(args['imageUrls']);
      } else {
        itemImages.value = [args['imageUrls'].toString()];
      }
    }

    itemLocation.value =
        _extractProvince(args['location'] ?? 'Unknown Province');
    itemCategory.value = args['category'] ?? 'Uncategorized';
    itemRarity.value = args['rarity'] ?? 'Common';
    itemDescription.value = args['description'] ?? 'No description available';

    if (args['tanggal'] != null && args['jamSelesai'] != null) {
      try {
        final itemDate = (args['tanggal'] as Timestamp).toDate();
        final endTimeStr = args['jamSelesai'] as String;
        final endTimeParts = endTimeStr.split(':');

        final calculatedEndTime = DateTime(
          itemDate.year,
          itemDate.month,
          itemDate.day,
          int.parse(endTimeParts[0]),
          int.parse(endTimeParts[1]),
        );

        if (calculatedEndTime.isBefore(DateTime.now())) {
          endTime.value = calculatedEndTime.add(Duration(days: 1));
        } else {
          endTime.value = calculatedEndTime;
        }

        print('Item date: $itemDate');
        print('End time string: $endTimeStr');
        print('Calculated end time: ${endTime.value}');

        isAuctionEnded.value = false;
        checkAuctionStatus();
      } catch (e) {
        print('Error setting end time: $e');
        endTime.value = DateTime.now().add(Duration(hours: 24));
      }
    }

    if (itemId.isNotEmpty) {
      setupStreams();
      startTimer();
      fetchUserBalance();
      if (args['sellerId'] != null) {
        fetchSellerDetails(args['sellerId']);
      }
    }

    isLoading.value = false;
  }

  void setupStreams() {
    itemStream = FirebaseFirestore.instance
        .collection('items')
        .doc(itemId.value)
        .snapshots();

    bidsStream = FirebaseFirestore.instance
        .collection('items')
        .doc(itemId.value)
        .collection('bids')
        .orderBy('amount', descending: true)
        .limit(10)
        .snapshots();

    listenToStreams();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateTimeRemaining();
    });
  }

  void listenToStreams() {
    itemStream.listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        currentPrice.value = data['current_price'] ?? 0.0;
        if (data['end_time'] != null) {
          endTime.value = (data['end_time'] as Timestamp).toDate();
        }
      }
    });

    bidsStream.listen((snapshot) {
      topBidders.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['timestamp'] != null) {
          data['timestamp'] = (data['timestamp'] as Timestamp).toDate();
        }
        topBidders.add(data);
      }
    });
  }

  void updateTimeRemaining() {
    final now = DateTime.now();
    final remaining = endTime.value.difference(now);

    print('Current time: $now');
    print('End time: ${endTime.value}');
    print('Time difference in minutes: ${remaining.inMinutes}');

    if (remaining.isNegative && endTime.value.isBefore(now)) {
      isAuctionEnded.value = true;
      timeRemaining.value = 'Auction Ended';
      _timer?.cancel();

      if (!hasShownWinnerDialog.value) {
        hasShownWinnerDialog.value = true;
        showWinnerDialog();
      }
      return;
    }

    isAuctionEnded.value = false;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    if (hours > 0) {
      timeRemaining.value = '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      timeRemaining.value = '${minutes}m ${seconds}s';
    } else {
      timeRemaining.value = '${seconds}s';
    }
  }

  Future<void> placeBid(double amount) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'Sign In Required',
          'Please sign in to place a bid',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final itemDoc = await FirebaseFirestore.instance
          .collection('items')
          .doc(itemId.value)
          .get();

      if (itemDoc.data()?['seller_id'] == user.uid) {
        Get.snackbar(
          'Cannot Bid',
          'You cannot bid on your own item',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final highestBid = await FirebaseFirestore.instance
          .collection('items')
          .doc(itemId.value)
          .collection('bids')
          .orderBy('amount', descending: true)
          .limit(1)
          .get();

      if (highestBid.docs.isNotEmpty &&
          highestBid.docs.first.data()['bidder_id'] == user.uid) {
        Get.snackbar(
          'Already Highest Bidder',
          'You already have the highest bid on this item',
          backgroundColor: Colors.amber,
          colorText: Colors.black87,
        );
        return;
      }

      if (amount <= currentPrice.value) {
        Get.snackbar(
          'Invalid Bid',
          'Your bid must be higher than the current price',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw 'User profile not found';
      }

      final userData = userDoc.data()!;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final itemRef =
            FirebaseFirestore.instance.collection('items').doc(itemId.value);

        final itemDoc = await transaction.get(itemRef);

        if (!itemDoc.exists) {
          throw 'Item not found';
        }

        if (itemDoc.data()!['current_price'] >= amount) {
          throw 'Someone has already placed a higher bid';
        }

        final bidCountSnapshot = await FirebaseFirestore.instance
            .collection('items')
            .doc(itemId.value)
            .collection('bids')
            .count()
            .get();

        final newBidCount = bidCountSnapshot.count! + 1;

        transaction.update(itemRef, {
          'current_price': amount,
          'bid_count': newBidCount,
        });

        transaction.set(
          itemRef.collection('bids').doc(),
          {
            'amount': amount,
            'bidder_id': user.uid,
            'bidder_name': userData['displayName'] ?? 'Anonymous',
            'bidder_photo': userData['photoURL'],
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      bidController.clear();
      Get.snackbar(
        'Success',
        'Your bid has been placed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void checkAuctionStatus() {
    final now = DateTime.now();
    final remaining = endTime.value.difference(now);

    isAuctionEnded.value = remaining.isNegative && endTime.value.isBefore(now);

    print('Now: $now');
    print('End time: ${endTime.value}');
    print('Time remaining: ${remaining.inMinutes} minutes');
    print('Is ended: ${isAuctionEnded.value}');
  }

  Future<void> fetchUserBalance() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          userBalance.value = (doc.data()?['balance'] ?? 0.0).toDouble();
        }
      }
    } catch (e) {
      print('Error fetching user balance: $e');
    }
  }

  Future<void> fetchSellerDetails(String sellerId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        sellerName.value = data['displayName'] ?? 'Anonymous';
        sellerPhotoUrl.value = data['photoURL'] ?? '';
        isVerifiedSeller.value = data['isVerified'] ?? false;
        sellerRating.value = (data['rating'] ?? 0.0).toDouble();
        totalReviews.value = data['ratingCount'] ?? 0;

        if (data['createdAt'] != null) {
          final joinDate = (data['createdAt'] as Timestamp).toDate();
          sellerJoinDate.value = DateFormat('MMM yyyy').format(joinDate);
        }

        final itemsQuery = await FirebaseFirestore.instance
            .collection('items')
            .where('seller_id', isEqualTo: sellerId)
            .get();
        sellerTotalItems.value = itemsQuery.docs.length;
      }
    } catch (e) {
      print('Error fetching seller details: $e');
    }
  }

  void toggleDescription() {
    isDescriptionExpanded.toggle();
  }

  Future<void> handleAuctionEnd(
      String winnerId, double winningAmount, String sellerId) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final winnerRef =
            FirebaseFirestore.instance.collection('users').doc(winnerId);
        final sellerRef =
            FirebaseFirestore.instance.collection('users').doc(sellerId);
        final itemRef =
            FirebaseFirestore.instance.collection('items').doc(itemId.value);

        final winnerDoc = await transaction.get(winnerRef);
        final sellerDoc = await transaction.get(sellerRef);
        final itemDoc = await transaction.get(itemRef);

        if (!winnerDoc.exists || !sellerDoc.exists || !itemDoc.exists) {
          throw 'Required documents not found';
        }

        transaction.update(
            winnerRef, {'balance': FieldValue.increment(-winningAmount)});
        transaction.update(
            sellerRef, {'balance': FieldValue.increment(winningAmount)});

        final winnerTransRef =
            FirebaseFirestore.instance.collection('transactions').doc();
        transaction.set(winnerTransRef, {
          'userId': winnerId,
          'type': 'auction_payment',
          'amount': -winningAmount,
          'itemId': itemId.value,
          'itemName': itemName.value,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
          'description': 'Payment for winning auction: ${itemName.value}',
          'transactionId': winnerTransRef.id
        });

        final sellerTransRef =
            FirebaseFirestore.instance.collection('transactions').doc();
        transaction.set(sellerTransRef, {
          'userId': sellerId,
          'type': 'auction_received',
          'amount': winningAmount,
          'itemId': itemId.value,
          'itemName': itemName.value,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
          'description': 'Payment received for auction: ${itemName.value}',
          'transactionId': sellerTransRef.id
        });

        transaction.update(itemRef, {
          'status': 'closed',
          'winner_id': winnerId,
          'completed_at': FieldValue.serverTimestamp(),
        });

        // Winner notification
        await _sendAuctionNotification(
          userId: winnerId,
          title: 'Auction Won & Payment Processed',
          message: 'You won ${itemName.value} for ${NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(winningAmount)}',
          type: 'auction_won',
        );

        // Seller notification
        await _sendAuctionNotification(
          userId: sellerId,
          title: 'Auction Ended',
          message:
              'Your item ${itemName.value} was sold for ${NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(winningAmount)}',
          type: 'auction_sold',
        );
      });
    } catch (e) {
      print('Error handling auction end: $e');
    }
  }

  Future<void> showWinnerDialog() async {
    try {
      final winningBid = await FirebaseFirestore.instance
          .collection('items')
          .doc(itemId.value)
          .collection('bids')
          .orderBy('amount', descending: true)
          .limit(1)
          .get();

      if (winningBid.docs.isNotEmpty) {
        final winnerData = winningBid.docs.first.data();
        final currentUser = FirebaseAuth.instance.currentUser;
        final winnerId = winnerData['bidder_id'];
        final winningAmount = winnerData['amount'];
        final itemRef =
            FirebaseFirestore.instance.collection('items').doc(itemId.value);
        final itemDoc = await itemRef.get();
        final sellerId = itemDoc.data()?['seller_id'];

        await handleAuctionEnd(winnerId, winningAmount, sellerId);

        String message = '';
        String title = '';
        Color backgroundColor;

        if (currentUser?.uid == winnerId) {
          title = 'Congratulations! 🎉';
          message =
              'You won the auction for ${itemName.value} with a bid of ${NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(winningAmount)}';
          backgroundColor = Colors.green;
        } else {
          title = 'Auction Ended';
          message =
              'The winner is ${winnerData['bidder_name']} with a bid of ${NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(winningAmount)}';
          backgroundColor = Colors.blue;
        }

        await Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      minimumSize: Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.back();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      } else {
        await Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Auction Ended',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No bids were placed on this item.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      minimumSize: Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.back();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print('Error showing winner dialog: $e');
    }
  }

  Future<void> _sendAuctionNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': title,
        'message': message,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'itemId': itemId.value,
        'actionUrl': '',
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    bidController.dispose();
    super.onClose();
  }
}
