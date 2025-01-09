import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lelang_fb/app/modules/home/views/home.dart';
import 'package:lelang_fb/app/modules/list_favorite/views/list_favorite_view.dart';
import 'package:lelang_fb/app/modules/search/views/search_view.dart';
import 'package:lelang_fb/app/services/auction_service.dart';
import 'package:lelang_fb/core/assets/assets.gen.dart';
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
  final transactions = <Map<String, dynamic>>[].obs;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;
  StreamSubscription<DocumentSnapshot>? _balanceSubscription;

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

    print('HomeController onInit called');
    Get.lazyPut(() => AddItemController());
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
    setupBalanceStream();
    setupTransactionStream();
  }

  void setupItemsListener() {
    try {
      print('Setting up items listener...');

      _firestore.collection('items').snapshots().listen(
        (snapshot) async {
          print('Received snapshot with ${snapshot.docs.length} documents');
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

            // Process items and check status
            items.value = await Future.wait(snapshot.docs.map((doc) async {
              final data = doc.data();
              final itemRef = _firestore.collection('items').doc(doc.id);

              // Use checkAndUpdateStatus which now uses _updateToLive internally
              if (data['status'] == 'upcoming' || data['status'] == 'live') {
                await AuctionService.checkAndUpdateStatus(itemRef);
                // Get fresh data after status update
                final updatedDoc = await itemRef.get();
                if (updatedDoc.exists) {
                  data.addAll(updatedDoc.data() ?? {});
                }
              }

              return processItemData(doc.id, data, bidCounts[doc.id] ?? 0);
            }));

            liveAuctions.value = snapshot.docs.where((doc) {
              final data = doc.data();
              return data['status'] == 'live';
            }).toList();

            upcomingAuctions.value =
                items.where((item) => item['status'] == 'upcoming').toList();
          } catch (e) {
            print('Error processing documents: $e');
          }
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
    _transactionSubscription?.cancel();
    _balanceSubscription?.cancel();

    super.dispose();
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
    try {
      final querySnapshot = await _firestore
          .collection('items')
          .where('status', whereIn: ['upcoming', 'live']).get();

      print('Found ${querySnapshot.docs.length} active auctions to check');

      for (var doc in querySnapshot.docs) {
        print('Checking auction: ${doc.id}');
        await AuctionService.checkAndUpdateStatus(doc.reference);
      }
    } catch (e) {
      print('Error checking auction status: $e');
    }
  }

  Future<void> _handleAuctionEnd(
      DocumentReference itemRef, Map<String, dynamic> item) async {
    await AuctionService.handleAuctionEnd(itemRef, item);
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

  Future<void> topUp(double amount) async {
    final orderId = 'TOP-${DateTime.now().millisecondsSinceEpoch}';
    final user = _auth.currentUser;

    if (user == null) {
      Get.snackbar('Error', 'Please login first');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.7:3000/create-payment'),
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
          Uri.parse('http://192.168.1.7:3000/status/$orderId'),
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

      await AuctionService.processTopUp(user.uid, amount);
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

      // Use AuctionService to handle transaction
      await AuctionService.handleTransactionAndNotification(
        type: 'transfer',
        amount: -amount, // Negative for sender
        userId: _auth.currentUser!.uid,
        itemId: '',
        description: 'Transfer to $recipientEmail',
        additionalData: {
          'recipientEmail': recipientEmail,
          'recipientId': recipientDoc.docs.first.id,
        },
      );

      // Create recipient's transaction record
      await AuctionService.handleTransactionAndNotification(
        type: 'transfer_received',
        amount: amount, // Positive for recipient
        userId: recipientDoc.docs.first.id,
        itemId: '',
        description: 'Transfer from ${_auth.currentUser!.email}',
        additionalData: {
          'senderEmail': _auth.currentUser!.email,
          'senderId': _auth.currentUser!.uid,
        },
      );

      await fetchUserBalance();
      Get.snackbar('Success', 'Transfer completed');
    } catch (e) {
      print('Error transferring: $e');
      Get.snackbar('Error', 'Transfer failed');
    }
  }

  Future<void> withdraw(double amount, String bankCode, String accountNumber, String accountName) async {
    try {
      if (amount > userBalance.value) {
        Get.snackbar('Error', 'Insufficient balance');
        return;
      }

      Get.dialog(Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final user = _auth.currentUser;
      if (user == null) return;

      // Create one-time listener for balance update
      StreamSubscription<DocumentSnapshot>? withdrawalListener;
      withdrawalListener = _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final newBalance = (snapshot.data()?['balance'] ?? 0.0).toDouble();
          userBalance.value = newBalance;
          withdrawalListener?.cancel(); // Cancel after first update
        }
      });

      // Update balance immediately in Firestore
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(_firestore.collection('users').doc(user.uid));
        final currentBalance = userDoc.data()?['balance'] ?? 0.0;
        
        if (currentBalance < amount) {
          throw 'Insufficient balance';
        }

        // Deduct from user's balance
        transaction.update(_firestore.collection('users').doc(user.uid), {
          'balance': FieldValue.increment(-amount)
        });

        // Create withdrawal transaction
        final transactionRef = _firestore.collection('transactions').doc();
        transaction.set(transactionRef, {
          'userId': user.uid,
          'amount': -amount,
          'type': 'withdraw',
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
          'bankCode': bankCode,
          'bankAccount': accountNumber,
          'accountName': accountName,
          'description': 'Withdrawal to $bankCode'
        });
      });

      Get.back(); // Close loading dialog

      await Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 20),
                Text('Withdrawal Success',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(
                  'Amount: Rp ${amount.toStringAsFixed(0)}\nBank: ${bankCode.toUpperCase()}\nAccount: $accountNumber',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Obx(() => Text(
                  'Current Balance: Rp ${userBalance.value.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.hijauTua,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    withdrawalListener?.cancel(); // Clean up listener when closing dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hijauTua,
                    minimumSize: Size(double.infinity, 45),
                  ),
                  child: Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

    } catch (e) {
      print('Error processing withdrawal: $e');
      Get.back(); // Close loading dialog
      Get.snackbar('Error', 'Failed to process withdrawal: $e');
    }
  }

  void showTransactionHistory() {
    // Cancel existing subscription if any
    _transactionSubscription?.cancel();

    // Setup new subscription
    _transactionSubscription = _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      transactions.value = snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }).toList();
    }, onError: (error) {
      print('Error in transaction stream: $error');
    });

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: Get.width * 0.95,
          height: Get.height * 0.7,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      _transactionSubscription?.cancel();
                      Get.back();
                    },
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: Obx(() {
                  if (transactions.isEmpty) {
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
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionItem(transactions[index], context);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> data, BuildContext context) {
    final amount = data['amount'] ?? 0.0;
    final type = data['type'] ?? 'Unknown';
    final timestamp = data['timestamp'] as Timestamp;
    final date = timestamp.toDate();

    IconData icon;
    Color color;
    switch (type) {
      case 'topup':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'withdraw':
        icon = Icons.money_off;
        color = Colors.red;
        break;
      case 'transfer':
        icon = Icons.send;
        color = Colors.blue;
        break;
      case 'transfer_received':
        icon = Icons.call_received;
        color = Colors.green;
        break;
      default:
        icon = Icons.swap_horiz;
        color = Colors.grey;
    }

    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        _getTransactionTitle(type),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
      ),
      trailing: Text(
        'Rp ${amount.abs().toStringAsFixed(0)}',
        style: TextStyle(
          color: amount >= 0 ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () => _showTransactionDetails(data),
    );
  }

  String _getTransactionTitle(String type) {
    switch (type) {
      case 'topup':
        return 'Top Up';
      case 'withdraw':
        return 'Withdrawal';
      case 'transfer':
        return 'Transfer Sent';
      case 'transfer_received':
        return 'Transfer Received';
      default:
        return type.toUpperCase();
    }
  }

  void setupBalanceStream() {
    final user = _auth.currentUser;
    if (user != null) {
      _balanceSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          userBalance.value = (snapshot.data()?['balance'] ?? 0.0).toDouble();
        }
      });
    }
  }

  void setupTransactionStream() {
    final user = _auth.currentUser;
    if (user != null) {
      _transactionSubscription = _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        transactions.value = snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList();
      });
    }
  }

  void _showTransactionDetails(Map<String, dynamic> data) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Divider(),
              _buildDetailRow('Type', _getTransactionTitle(data['type'] ?? 'Unknown')),
              _buildDetailRow('Amount', 'Rp ${(data['amount'] ?? 0.0).abs().toStringAsFixed(0)}'),
              _buildDetailRow('Status', (data['status'] ?? 'completed').toUpperCase()),
              if (data['timestamp'] != null)
                _buildDetailRow(
                  'Date & Time',
                  _formatDateTime((data['timestamp'] as Timestamp).toDate()),
                ),
              if (data['type'] == 'transfer') ...[
                if (data['recipientEmail'] != null)
                  _buildDetailRow('To', data['recipientEmail']),
                if (data['senderEmail'] != null)
                  _buildDetailRow('From', data['senderEmail']),
              ],
              if (data['type'] == 'withdraw') ...[
                if (data['bankCode'] != null)
                  _buildDetailRow('Bank', data['bankCode'].toString().toUpperCase()),
                if (data['accountName'] != null)
                  _buildDetailRow('Account Name', data['accountName']),
                if (data['bankAccount'] != null)
                  _buildDetailRow('Account Number', data['bankAccount']),
              ],
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  void onClose() {
    _timer?.cancel();
    _statusCheckTimer?.cancel();
    _transactionSubscription?.cancel();
    _balanceSubscription?.cancel();
    super.onClose();
  }
}
