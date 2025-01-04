import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lelang_fb/app/modules/home/views/home.dart';
import 'package:lelang_fb/app/modules/list_favorite/views/list_favorite_view.dart';
import 'package:lelang_fb/app/modules/search/views/search_view.dart';
import 'package:lelang_fb/core/assets/assets.gen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:lelang_fb/core/constants/color.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';

import '../../addItem/views/add_item_view.dart';
import '../../../modules/addItem/controllers/add_item_controller.dart';
import '../../profile/views/profile_view.dart';

class HomeController extends GetxController with SingleGetTickerProviderMixin {
  final selectedPage = 0.obs;
  final count = 0.obs;
  final search = FocusNode();
  final pageController = PageController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxList<Map<String, dynamic>> carEvents = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> motorEvents = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> lifestyleEvents =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final liveAuctions = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  final RxList<Map<String, dynamic>> upcomingAuctions =
      <Map<String, dynamic>>[].obs;
  RxList<String> carouselImages = <String>[].obs;
  final userBalance = 0.0.obs;

  @override
  void onReady() {
    super.onReady();
  }

  var currentPage = 0.obs;
  Timer? _timer;
  Timer? _statusCheckTimer;

  var bannerPromo = <String>[].obs;

  final List<Widget> widgetOptions = [
    Home(),
    SearchView(),
    AddItemView(),
    ListFavoriteView(),
    ProfileView(),
  ];

  void changePage(int index) async {
    if (index == 2) {
      try {
        final user = _auth.currentUser;
        if (user == null) {
          Get.toNamed('/login');
          return;
        }

        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();

        if (!docSnapshot.exists ||
            !(docSnapshot.data()?['verified_buyer_seller'] ?? false)) {
          Get.snackbar(
            'Access Denied',
            'Only verified users can add items. Please complete your profile to get verified.',
            backgroundColor: Colors.amber,
            colorText: Colors.black87,
            duration: Duration(seconds: 3),
            icon: Icon(Icons.warning_amber_rounded, color: Colors.black87),
          );
          Get.toNamed('/profile-setting');
          return;
        }
      } catch (e) {
        print('Error checking verification status: $e');
        Get.snackbar(
          'Error',
          'Unable to verify user status',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    selectedPage.value = index;

    if (index == 1) {
      search.requestFocus();
    } else {
      search.unfocus();
    }
  }

  @override
  void onInit() {
    super.onInit();
    bannerPromo.add(Assets.images.banner2.path);

    initializeDateFormatting('id_ID', null).then((_) {
      print('Date formatting initialized');
    });
    print('HomeController onInit called');
    Get.lazyPut(() => AddItemController());
    tabController = TabController(length: 3, vsync: this);
    fetchEvents();
    setupItemsListener();
    fetchCarouselImages().then((_) {
      carouselImages.refresh();
    });

    _firestore.collection('items').get().then(
      (snapshot) {
        print(
            'Direct Firestore check: ${snapshot.docs.length} documents found');
      },
    ).catchError((error) {
      print('Error checking Firestore: $error');
    });

    _statusCheckTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      checkAndUpdateAuctionStatus();
    });

    fetchUserBalance();
    setupUserBalanceListener();
  }

  void setupItemsListener() {
    try {
      print('Setting up items listener...');

      _firestore.collection('items').snapshots().listen(
        (snapshot) async {
          print('Received snapshot with ${snapshot.docs.length} documents');

          if (snapshot.docs.isEmpty) {
            print('No documents found in items collection');
            return;
          }

          try {
            List<Future<QuerySnapshot>> bidCountFutures =
                snapshot.docs.map((doc) {
              return _firestore
                  .collection('items')
                  .doc(doc.id)
                  .collection('bids')
                  .get();
            }).toList();

            List<QuerySnapshot> bidSnapshots =
                await Future.wait(bidCountFutures);

            Map<String, int> bidCounts = {};
            for (int i = 0; i < snapshot.docs.length; i++) {
              bidCounts[snapshot.docs[i].id] = bidSnapshots[i].docs.length;
            }

            items.value = snapshot.docs.map((doc) {
              final data = doc.data();
              return processItemData(doc.id, data, bidCounts[doc.id] ?? 0);
            }).toList();

            liveAuctions.value = snapshot.docs.where((doc) {
              final data = doc.data();
              return data['status'] == 'live';
            }).toList();

            upcomingAuctions.value =
                items.where((item) => item['status'] == 'upcoming').toList();

            print('Processed ${items.length} items successfully');
          } catch (e) {
            print('Error processing documents: $e');
          }
        },
        onError: (error) {
          print('Error in Firestore listener: $error');
        },
      );
    } catch (e) {
      print('Error setting up listener: $e');
    }
  }

  Map<String, dynamic> processItemData(
      String docId, Map<String, dynamic> data, int bidCount) {
    return {
      'id': docId,
      'name': data['name'] ?? 'Unnamed Item',
      'category': data['category'] ?? 'Uncategorized',
      'current_price': data['current_price']?.toDouble() ?? 0.0,
      'starting_price': data['starting_price']?.toDouble() ?? 0.0,
      'lokasi': data['lokasi'] ?? 'No location',
      'description': data['description'] ?? '',
      'imageURL': data['imageURL'] is List
          ? List<String>.from(data['imageURL'])
          : data['imageURL'] != null
              ? [data['imageURL'].toString()]
              : [],
      'seller_id': data['seller_id'],
      'bid_count': bidCount,
      'tanggal': data['tanggal'] ?? Timestamp.now(),
      'jamMulai': data['jamMulai'] ?? '',
      'jamSelesai': data['jamSelesai'] ?? '',
      'status': data['status'] ?? 'upcoming',
      'rarity': data['rarity'] ?? 'Common',
      'created_at': data['created_at'] ?? Timestamp.now(),
      'updated_at': data['updated_at'] ?? Timestamp.now(),
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusCheckTimer?.cancel();
    tabController.dispose();

    super.dispose();
  }

  void increment() => count.value++;

  late TabController tabController;

  Future<void> fetchEvents() async {
    try {
      final carSnapshot = await _firestore
          .collection('events')
          .where('type', isEqualTo: 'car')
          .get();
      carEvents.value = carSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      final motorSnapshot = await _firestore
          .collection('events')
          .where('type', isEqualTo: 'motorcycle')
          .get();
      motorEvents.value = motorSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      final lifestyleSnapshot = await _firestore
          .collection('events')
          .where('type', isEqualTo: 'lifestyle')
          .get();
      lifestyleEvents.value = lifestyleSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> fetchCarouselImages() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('carousel')
          .orderBy('createdAt', descending: false)
          .get();

      carouselImages.clear();

      List<String> tempImages = [];

      for (var doc in snapshot.docs) {
        String imageUrl = doc.data()['imageUrl'] as String;
        tempImages.add(imageUrl);
        print("Added image URL: $imageUrl");
      }

      if (tempImages.isNotEmpty) {
        carouselImages.value = tempImages;
        print("Carousel loaded with ${carouselImages.length} images");
      }
    } catch (e) {
      print('Error fetching carousel images: $e');
    }
  }

  void checkAndUpdateAuctionStatus() async {
    final now = DateTime.now();

    try {
      final querySnapshot = await _firestore
          .collection('items')
          .where('status', whereIn: ['upcoming', 'live']).get();

      for (var doc in querySnapshot.docs) {
        final item = doc.data();
        final itemDate = (item['tanggal'] as Timestamp).toDate();

        final startTime = item['jamMulai'] as String;
        final endTime = item['jamSelesai'] as String;

        final startTimeParts = startTime.split(':');
        final endTimeParts = endTime.split(':');

        final itemStartDateTime = DateTime(
          itemDate.year,
          itemDate.month,
          itemDate.day,
          int.parse(startTimeParts[0]),
          int.parse(startTimeParts[1]),
        );

        final itemEndDateTime = DateTime(
          itemDate.year,
          itemDate.month,
          itemDate.day,
          int.parse(endTimeParts[0]),
          int.parse(endTimeParts[1]),
        );

        if (item['status'] == 'upcoming' && now.isAfter(itemStartDateTime)) {
          await doc.reference.update({
            'status': 'live',
            'updated_at': FieldValue.serverTimestamp(),
          });
          _sendNotification(
            userId: item['seller_id'],
            title: 'Auction Started',
            message: 'Your auction for ${item['name']} has started!',
            type: 'auction_start',
          );
        }

        if (item['status'] == 'live' && now.isAfter(itemEndDateTime)) {
          await _handleAuctionEnd(doc.reference, item);
        }
      }
    } catch (e) {
      print('Error in checkAndUpdateAuctionStatus: $e');
    }
  }

  Future<void> _handleAuctionEnd(
      DocumentReference itemRef, Map<String, dynamic> item) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final bidsSnapshot = await itemRef
            .collection('bids')
            .orderBy('amount', descending: true)
            .limit(1)
            .get();

        if (bidsSnapshot.docs.isNotEmpty) {
          final highestBid = bidsSnapshot.docs.first;
          final winnerId = highestBid.data()['bidder_id'];
          final winningAmount = highestBid.data()['amount'];

          final winnerRef = _firestore.collection('users').doc(winnerId);
          final sellerRef =
              _firestore.collection('users').doc(item['seller_id']);

          transaction.update(itemRef, {
            'status': 'closed',
            'winner_id': winnerId,
            'winning_bid': winningAmount,
            'updated_at': FieldValue.serverTimestamp(),
          });

          transaction.update(
              winnerRef, {'balance': FieldValue.increment(-winningAmount)});
          transaction.update(
              sellerRef, {'balance': FieldValue.increment(winningAmount)});
        }
      });
    } catch (e) {
      print('Error handling auction end: $e');
    }
  }

  Future<void> _sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.collection('notifications').add({
        'title': title,
        'message': message,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'itemId': '',
        'actionUrl': '',
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> fetchUserBalance() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          if (doc.data()!.containsKey('balance')) {
            userBalance.value = (doc.data()?['balance'] ?? 0.0).toDouble();
          } else {
            await _firestore.collection('users').doc(user.uid).set({
              'balance': 0.0,
            }, SetOptions(merge: true));
            userBalance.value = 0.0;
          }
        } else {
          await _firestore.collection('users').doc(user.uid).set({
            'balance': 0.0,
            'email': user.email,
            'displayName': user.displayName,
          });
          userBalance.value = 0.0;
        }
      }
    } catch (e) {
      print('Error fetching balance: $e');
    }
  }

  void setupUserBalanceListener() {
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).snapshots().listen((doc) {
        if (doc.exists && doc.data()!.containsKey('balance')) {
          userBalance.value = (doc.data()?['balance'] ?? 0.0).toDouble();
        } else {
          _firestore.collection('users').doc(user.uid).set({
            'balance': 0.0,
          }, SetOptions(merge: true));
          userBalance.value = 0.0;
        }
      }, onError: (e) => print('Error listening to balance: $e'));
    }
  }

  Future<void> topUp(double amount) async {
    final orderId = 'TOP-${DateTime.now().millisecondsSinceEpoch}';
    final user = _auth.currentUser;

    if (user == null) {
      Get.snackbar('Error', 'Please login first');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.3:3000/create-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'amount': amount,
          'userId': user.uid,
          'email': user.email,
          'name': user.displayName
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data['redirectUrl'];

        try {
          if (await canLaunchUrlString(url)) {
            await launchUrlString(
              url,
              mode: LaunchMode.externalApplication,
            );
            startCheckingPaymentStatus(orderId, amount);
          } else {
            Get.snackbar('Error', 'Could not launch payment URL');
          }
        } catch (e) {
          print('Error launching URL: $e');
          Get.snackbar('Error', 'Failed to open payment page');
        }
      }
    } catch (e) {
      print('Error creating payment: $e');
      Get.snackbar('Error', 'Failed to process payment');
    }
  }

  void startCheckingPaymentStatus(String orderId, double amount) {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      try {
        final response = await http.get(
          Uri.parse('http://192.168.1.3:3000/status/$orderId'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('Payment status response: $data');

          if (data['transaction_status'] == 'settlement' ||
              data['transaction_status'] == 'capture') {
            timer.cancel();
            final paymentAmount = double.parse(data['gross_amount'].toString());
            await updateUserBalance(paymentAmount);
            Get.snackbar('Success',
                'Payment of Rp ${paymentAmount.toStringAsFixed(0)} completed',
                backgroundColor: Colors.green.withOpacity(0.3));
          } else if (data['transaction_status'] == 'expire' ||
              data['transaction_status'] == 'cancel' ||
              data['transaction_status'] == 'deny') {
            timer.cancel();
            Get.snackbar('Failed', 'Payment failed or cancelled',
                backgroundColor: Colors.red.withOpacity(0.3));
          }
        }
      } catch (e) {
        print('Error checking payment status: $e');
        timer.cancel();
      }
    });
  }

  Future<void> updateUserBalance(double amount) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      final userRef = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          transaction.set(userRef, {
            'balance': amount,
            'email': user.email,
            'displayName': user.displayName,
          });
        } else {
          final currentBalance = (userDoc.data()?['balance'] ?? 0.0).toDouble();
          final newBalance = currentBalance + amount;

          print(
              'Updating balance: Current=$currentBalance, Adding=$amount, New=$newBalance');

          transaction.update(userRef, {
            'balance': newBalance,
          });
        }
      });

      await _firestore.collection('transactions').add({
        'userId': user.uid,
        'amount': amount,
        'type': 'topup',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'success',
        'details': 'Midtrans payment'
      });

      await fetchUserBalance();

      print('Balance updated successfully');
    } catch (e) {
      print('Error updating balance: $e');
      Get.snackbar('Error', 'Failed to update balance: $e',
          backgroundColor: Colors.red.withOpacity(0.3));
    }
  }

  Future<void> initializeUserBalance() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists || !userDoc.data()!.containsKey('balance')) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set({'balance': 0.0}, SetOptions(merge: true));
        }
      }
    } catch (e) {
      print('Error initializing balance: $e');
    }
  }

  Future<void> transfer(String recipientEmail, double amount) async {
    try {
      if (amount > userBalance.value) {
        Get.snackbar('Error', 'Insufficient balance');
        return;
      }

      final recipientDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: recipientEmail)
          .get();

      if (recipientDoc.docs.isEmpty) {
        Get.snackbar('Error', 'Recipient not found');
        return;
      }

      final batch = _firestore.batch();
      final user = _auth.currentUser;
      final recipientId = recipientDoc.docs.first.id;

      batch.update(_firestore.collection('users').doc(user?.uid),
          {'balance': FieldValue.increment(-amount)});

      batch.update(_firestore.collection('users').doc(recipientId),
          {'balance': FieldValue.increment(amount)});

      await batch.commit();

      await _firestore.collection('transactions').add({
        'userId': user?.uid,
        'amount': amount,
        'type': 'transfer',
        'recipientEmail': recipientEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed'
      });

      await fetchUserBalance();
      Get.snackbar('Success', 'Transfer completed');
    } catch (e) {
      print('Error transferring: $e');
      Get.snackbar('Error', 'Transfer failed');
    }
  }

  Future<void> showTransactionHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Please login first');
        return;
      }

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: Get.width * 0.95,
            height: Get.height * 0.7,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                Divider(),
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: _firestore
                        .collection('transactions')
                        .where('userId', isEqualTo: user.uid)
                        .orderBy('timestamp', descending: true)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No transactions found'),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final transaction = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                          final amount = transaction['amount'] ?? 0.0;
                          final type = transaction['type'] ?? 'Unknown';
                          final timestamp =
                              transaction['timestamp'] as Timestamp;
                          final date = timestamp.toDate();

                          return ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.hijauTua.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                type == 'topup' ? Icons.add_circle : Icons.send,
                                color: AppColors.hijauTua,
                              ),
                            ),
                            title: Text(
                              type.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
                            ),
                            trailing: Text(
                              'Rp ${amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: AppColors.hijauTua,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      print('Error showing transaction history: $e');
      Get.snackbar('Error', 'Failed to load transaction history');
    }
  }

  Future<void> withdraw(double amount, String bankCode, String accountNumber,
      String accountName) async {
    try {
      if (amount > userBalance.value) {
        Get.snackbar('Error', 'Insufficient balance');
        return;
      }

      Get.dialog(Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final response = await http.post(
        Uri.parse('http://192.168.1.3:3000/withdraw'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'bankCode': bankCode,
          'bankAccount': accountNumber,
          'accountName': accountName
        }),
      );

      Get.back();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        await _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .update({'balance': FieldValue.increment(-amount)});

        await _firestore.collection('transactions').add({
          'userId': _auth.currentUser?.uid,
          'amount': amount,
          'type': 'withdraw',
          'bankCode': bankCode,
          'bankAccount': accountNumber,
          'accountName': accountName,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'success',
          'transaction_id': responseData['transaction_id'],
        });

        Get.dialog(
          Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  SizedBox(height: 20),
                  Text('Withdrawal Initiated',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                    'Your withdrawal request is being processed.\nFunds will be transferred to:',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text('Virtual Account Number',
                            style: TextStyle(color: Colors.grey[600])),
                        SizedBox(height: 5),
                        Text(accountNumber,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            )),
                        Text(bankCode.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('OK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.hijauTua,
                      minimumSize: Size(double.infinity, 45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        throw Exception('Failed to process withdrawal');
      }
    } catch (e) {
      print('Error processing withdrawal: $e');
      Get.snackbar('Error', 'Failed to process withdrawal: $e',
          backgroundColor: Colors.red.withOpacity(0.3));
    }
  }

  void fetchLiveAuctions() {
    FirebaseFirestore.instance
        .collection('items')
        .where('status', isEqualTo: 'ongoing')
        .snapshots()
        .listen((snapshot) {
      liveAuctions.value = snapshot.docs;
    });
  }
}
