import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:lelang_fb/app/modules/home/views/home_view.dart';
import 'package:lelang_fb/app/services/auction_service.dart';

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
  final totalSales = 0.obs;
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

    // Setup initial values
    itemId.value = args['itemId'] ?? '';
    itemName.value = args['itemName'] ?? '';
    currentPrice.value = args['currentPrice'] ?? 0.0;

    // Fix the end time calculation
    if (args['tanggal'] != null && args['jamSelesai'] != null) {
      try {
        final itemDate = (args['tanggal'] as Timestamp).toDate();
        final endTimeStr = args['jamSelesai'] as String;
        final endTimeParts = endTimeStr.split(':');
        final now = DateTime.now();

        // Create end time
        endTime.value = DateTime(
          itemDate.year,
          itemDate.month,
          itemDate.day,
          int.parse(endTimeParts[0]),
          int.parse(endTimeParts[1]),
        );

        // If end time is in the past on the same day, move to next day
        if (endTime.value.isBefore(now) &&
            itemDate.year == now.year &&
            itemDate.month == now.month &&
            itemDate.day == now.day) {
          endTime.value = endTime.value.add(Duration(days: 1));
        }

        // Check if auction is ended
        isAuctionEnded.value = now.isAfter(endTime.value);
        if (isAuctionEnded.value) {
          timeRemaining.value = 'Auction Ended';
        } else {
          startTimer();
        }

        print('Item date: $itemDate');
        print('End time string: $endTimeStr');
        print('Calculated end time: ${endTime.value}');
        print('Now: $now');
        print('Is ended: ${isAuctionEnded.value}');
      } catch (e) {
        print('Error setting end time: $e');
      }
    }

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

    if (itemId.isNotEmpty) {
      setupStreams();
      startTimer();
      fetchUserBalance();
      if (args['sellerId'] != null) {
        fetchSellerDetails(args['sellerId']);
      }
    }

    isLoading.value = false;
    checkAuctionStatus();
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

    // Listen to item changes
    itemStream.listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        currentPrice.value = data['current_price'] ?? 0.0;

        // Check if auction just ended
        if (data['status'] == 'closed' && !hasShownWinnerDialog.value) {
          hasShownWinnerDialog.value = true;
          showWinnerDialog(); // Tampilkan dialog tanpa cek winner_id
        }
      }
    });

    // Listen to bids
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

    if (remaining.isNegative) {
      if (!isAuctionEnded.value) {
        isAuctionEnded.value = true;
        timeRemaining.value = 'Auction Ended';
        _timer?.cancel();

        final itemRef =
            FirebaseFirestore.instance.collection('items').doc(itemId.value);
        AuctionService.checkAndUpdateStatus(itemRef);
      }
      return;
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    timeRemaining.value = hours > 0
        ? '${hours}h ${minutes}m ${seconds}s'
        : minutes > 0
            ? '${minutes}m ${seconds}s'
            : '${seconds}s';
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

      // Firestore user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw 'User profile not found';
      }

      final userData = userDoc.data()!;
      final userPhotoUrl = userData['photoURL'];
      final userName = userData['displayName'] ?? 'Anonymous';

      // Check item and place bid
      final itemDoc = await FirebaseFirestore.instance
          .collection('items')
          .doc(itemId.value)
          .get();

      if (!itemDoc.exists) {
        throw 'Item not found';
      }

      final itemData = itemDoc.data()!;

      if (itemData['last_bidder'] == user.uid) {
        Get.snackbar(
          'Bid Rejected',
          'You are already the highest bidder',
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

      await AuctionService.placeBid(
        itemId: itemId.value,
        userId: user.uid,
        amount: amount,
        userName: userName,
        userPhoto: userPhotoUrl, // Use photo from Firestore
      );

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

    if (isAuctionEnded.value && !hasShownWinnerDialog.value) {
      FirebaseFirestore.instance
          .collection('items')
          .doc(itemId.value)
          .get()
          .then((doc) {
        if (doc.exists && Get.currentRoute.contains('live-auction')) {
          hasShownWinnerDialog.value = true;
          showWinnerDialog(); // Tampilkan dialog untuk semua bidder
        }
      });
    }
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
        totalSales.value = data['total_sales'] ?? 0;
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
      final itemRef =
          FirebaseFirestore.instance.collection('items').doc(itemId.value);
      final itemData = {
        'name': itemName.value,
        'seller_id': sellerId,
        'current_price': winningAmount,
        'winner_id': winnerId,
      };

      await AuctionService.handleAuctionEnd(itemRef, itemData);

      fetchUserBalance();
    } catch (e) {
      print('Error handling auction end: $e');
      Get.snackbar('Error', 'Failed to complete auction');
    }
  }

  Future<String> _getWinnerName(String winnerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(winnerId)
        .get();
    return doc.data()?['displayName'] ?? 'Anonymous';
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

      final currentUser = FirebaseAuth.instance.currentUser;

      if (winningBid.docs.isNotEmpty) {
        final winnerData = winningBid.docs.first.data();
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

        // Tentukan pesan berdasarkan status user (winner/non-winner)
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

        // Show dialog with barrier color
        await Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Colors.white,
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
                      Get.offAll(() => HomeView());
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
          barrierColor: Colors.black.withOpacity(0.5),
          useSafeArea: true,
        );
      } else {
        await Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Colors.white,
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
                      Get.to(HomeView());
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
          barrierColor: Colors.black.withOpacity(0.5),
          useSafeArea: true,
        );
      }
    } catch (e) {
      print('Error showing winner dialog: $e');
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    bidController.dispose();
    super.onClose();
  }
}
