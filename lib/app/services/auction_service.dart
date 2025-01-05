import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AuctionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> handleAuctionEnd(
      DocumentReference itemRef, Map<String, dynamic> item) async {
    try {
      print('Starting auction end process for item: ${item['name']}');
      await _firestore.runTransaction((transaction) async {
        final latestDoc = await transaction.get(itemRef);
        final latestData = latestDoc.data() as Map<String, dynamic>;

        if (latestData['status'] == 'closed') {
          print('Auction already ended, skipping process');
          return;
        }

        final bidsSnapshot = await itemRef
            .collection('bids')
            .orderBy('amount', descending: true)
            .limit(1)
            .get();

        if (bidsSnapshot.docs.isNotEmpty) {
          final highestBid = bidsSnapshot.docs.first;
          final winnerId = highestBid.data()['bidder_id'];
          final winningAmount = latestData['current_price'];

          print('Winner found: $winnerId with amount: $winningAmount');

          final winnerRef = _firestore.collection('users').doc(winnerId);
          final sellerRef =
              _firestore.collection('users').doc(item['seller_id']);

          transaction.update(winnerRef, {
            'balance': FieldValue.increment(-winningAmount),
          });

          transaction.update(sellerRef, {
            'balance': FieldValue.increment(winningAmount),
          });

          transaction.update(itemRef, {
            'status': 'closed',
            'winner_id': winnerId,
            'current_price': winningAmount,
            'updated_at': FieldValue.serverTimestamp(),
          });

          _createTransactionRecords(
              transaction, itemRef, item, winnerId, winningAmount);

          await _sendAuctionNotifications(transaction, winnerRef, sellerRef,
              itemRef.id, item['name'], winningAmount);
        } else {
          await _handleNoBidsAuction(transaction, itemRef, item);
        }
      });

      print('Auction end process completed successfully');
    } catch (e) {
      print('Error in handleAuctionEnd: $e');
      throw e;
    }
  }

  static Future<void> placeBid({
    required String itemId,
    required String userId,
    required double amount,
    required String userName,
    String? userPhoto,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final itemRef = _firestore.collection('items').doc(itemId);
        final itemDoc = await transaction.get(itemRef);

        if (!itemDoc.exists) throw 'Item not found';
        if (itemDoc.data()!['seller_id'] == userId) {
          throw 'Cannot bid on your own item';
        }
        if (itemDoc.data()!['current_price'] >= amount) {
          throw 'Bid must be higher than current price';
        }

        final bidCountSnapshot = await itemRef.collection('bids').count().get();
        final newBidCount = bidCountSnapshot.count! + 1;

        // Update item with new price
        transaction.update(itemRef, {
          'current_price': amount,
          'bid_count': newBidCount,
          'last_bidder': userId,
          'updated_at': FieldValue.serverTimestamp(),
        });

        // Add new bid
        transaction.set(
          itemRef.collection('bids').doc(),
          {
            'amount': amount,
            'bidder_id': userId,
            'bidder_name': userName,
            'bidder_photo': userPhoto,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );

        final previousHighestBid = await itemRef
            .collection('bids')
            .orderBy('amount', descending: true)
            .limit(1)
            .get();

        if (previousHighestBid.docs.isNotEmpty) {
          final previousBidderId =
              previousHighestBid.docs.first.data()['bidder_id'];
          if (previousBidderId != userId) {
            await _notifyOutbid(
              userId: previousBidderId,
              itemName: itemDoc.data()!['name'],
              newAmount: amount,
            );
          }
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> checkAndUpdateStatus(DocumentReference itemRef) async {
    try {
      final doc = await itemRef.get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final now = DateTime.now();

      if (data['status'] == 'closed') {
        return;
      }

      final itemDate = (data['tanggal'] as Timestamp).toDate();
      final startTime = data['jamMulai'] as String;
      final endTime = data['jamSelesai'] as String;

      final startDateTime = _getDateTime(itemDate, startTime);
      final endDateTime = _getDateTime(itemDate, endTime);

      if (now.isAfter(endDateTime)) {
        await handleAuctionEnd(itemRef, data);
      } else if (now.isAfter(startDateTime) && data['status'] == 'upcoming') {
        await _updateToLive(itemRef, data);
      }
    } catch (e) {
      print('Error in checkAndUpdateStatus: $e');
    }
  }

  static DateTime _getDateTime(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  static Future<void> _updateToLive(
      DocumentReference itemRef, Map<String, dynamic> data) async {
    await itemRef.update({
      'status': 'live',
      'updated_at': FieldValue.serverTimestamp(),
    });

    await _sendNotification(
      userId: data['seller_id'],
      title: 'Auction Started',
      message: 'Your auction for ${data['name']} has started!',
      type: 'auction_start',
      itemId: itemRef.id,
    );
  }

  static Future<void> _notifyOutbid({
    required String userId,
    required String itemName,
    required double newAmount,
  }) async {
    await _sendNotification(
      userId: userId,
      title: 'Outbid Notice',
      message:
          'Someone placed a higher bid of Rp ${NumberFormat('#,###').format(newAmount)} on $itemName',
      type: 'outbid',
      itemId: '',
    );
  }

  static Future<void> _sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    required String itemId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': title,
        'message': message,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'itemId': itemId,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static Future<void> _sendAuctionNotifications(
    Transaction transaction,
    DocumentReference winnerRef,
    DocumentReference sellerRef,
    String itemId,
    String itemName,
    double amount,
  ) async {
    // Winner notification
    transaction.set(winnerRef.collection('notifications').doc(), {
      'title': 'Auction Won!',
      'message':
          'Congratulations! You won the auction for $itemName with a bid of Rp ${NumberFormat('#,###').format(amount)}',
      'type': 'auction_won',
      'itemId': itemId,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    // Seller notification
    transaction.set(sellerRef.collection('notifications').doc(), {
      'title': 'Auction Completed',
      'message':
          'Your item $itemName has been sold for Rp ${NumberFormat('#,###').format(amount)}',
      'type': 'auction_sold',
      'itemId': itemId,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  static Future<void> _updateUserStatistics(
    Transaction transaction,
    DocumentReference winnerRef,
    DocumentReference sellerRef,
    double amount,
  ) async {
    // Update seller
    transaction.update(sellerRef, {
      'balance': FieldValue.increment(amount),
      'total_sales': FieldValue.increment(1),
    });
  }

  static Future<void> _handleNoBidsAuction(
    Transaction transaction,
    DocumentReference itemRef,
    Map<String, dynamic> item,
  ) async {
    transaction.update(itemRef, {
      'status': 'closed',
      'updated_at': FieldValue.serverTimestamp(),
    });

    final sellerNotifRef = _firestore
        .collection('users')
        .doc(item['seller_id'])
        .collection('notifications')
        .doc();

    transaction.set(sellerNotifRef, {
      'title': 'Auction Ended',
      'message': 'Your auction for ${item['name']} has ended with no bids',
      'type': 'auction_closed',
      'itemId': itemRef.id,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  static Future<void> handleTransactionAndNotification({
    required String type,
    required double amount,
    required String userId,
    required String itemId,
    String? description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Update user balance
        final userRef = _firestore.collection('users').doc(userId);
        transaction.update(userRef, {
          'balance': FieldValue.increment(
              type.contains('withdraw') || type.contains('payment')
                  ? -amount
                  : amount),
        });

        // buat transaction record
        final transactionRef = _firestore.collection('transactions').doc();
        transaction.set(transactionRef, {
          'userId': userId,
          'amount': amount,
          'type': type,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
          'description': description ?? '',
          'itemId': itemId,
          ...?additionalData,
        });

        // Send notification
        await _sendNotification(
          userId: userId,
          title: _getNotificationTitle(type),
          message: _getNotificationMessage(type, amount),
          type: type,
          itemId: itemId,
        );
      });
    } catch (e) {
      print('Error handling transaction: $e');
      rethrow;
    }
  }

  static String _getNotificationTitle(String type) {
    switch (type) {
      case 'topup':
        return 'Top Up Successful';
      case 'withdraw':
        return 'Withdrawal Processed';
      case 'transfer':
        return 'Transfer Complete';
      case 'auction_payment':
        return 'Auction Payment';
      default:
        return 'Transaction Complete';
    }
  }

  static String _getNotificationMessage(String type, double amount) {
    final formattedAmount = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);

    switch (type) {
      case 'topup':
        return 'Your account has been credited with $formattedAmount';
      case 'withdraw':
        return 'Withdrawal of $formattedAmount has been processed';
      case 'transfer':
        return 'Transfer of $formattedAmount completed';
      case 'auction_payment':
        return 'Payment of $formattedAmount for auction completed';
      default:
        return 'Transaction of $formattedAmount has been processed';
    }
  }

  static Future<List<Map<String, dynamic>>> getTransactionHistory(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching transaction history: $e');
      rethrow;
    }
  }

  static Future<void> processWinningBidPayment(
      String itemId, String winnerId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final winnerRef = _firestore.collection('users').doc(winnerId);
        final winnerDoc = await transaction.get(winnerRef);

        if (!winnerDoc.exists) throw 'Winner account not found';
        final currentBalance = winnerDoc.data()?['balance'] ?? 0.0;
        if (currentBalance < amount) throw 'Insufficient balance';

        // Deduct from winner's balance
        transaction.update(winnerRef, {
          'balance': FieldValue.increment(-amount),
        });

        // Create transaction record
        transaction.set(_firestore.collection('transactions').doc(), {
          'userId': winnerId,
          'amount': -amount,
          'type': 'auction_payment',
          'itemId': itemId,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
          'description': 'Auction payment for item #$itemId',
        });
      });
    } catch (e) {
      print('Error processing winning bid payment: $e');
      rethrow;
    }
  }

  static Future<void> processTopUp(String userId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);

        transaction.update(userRef, {
          'balance': FieldValue.increment(amount),
        });

        transaction.set(_firestore.collection('transactions').doc(), {
          'userId': userId,
          'amount': amount,
          'type': 'topup',
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
          'description': 'Top up via payment gateway',
        });
      });
    } catch (e) {
      print('Error processing top up: $e');
      rethrow;
    }
  }

  static Future<void> processWithdrawal(
    String userId,
    double amount,
    String bankCode,
    String accountNumber,
    String accountName,
    String transactionId,
  ) async {
    try {
      if (amount <= 0) throw 'Invalid amount';
      if (bankCode.isEmpty) throw 'Invalid bank code';
      if (accountNumber.isEmpty) throw 'Invalid account number';
      if (accountName.isEmpty) throw 'Invalid account name';
      if (transactionId.isEmpty) {
        transactionId = 'WD-${DateTime.now().millisecondsSinceEpoch}';
      }

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) throw 'User not found';
        final currentBalance = userDoc.data()?['balance'] ?? 0.0;
        if (currentBalance < amount) throw 'Insufficient balance';

        transaction.update(userRef, {
          'balance': FieldValue.increment(-amount),
        });

        final withdrawalRef = _firestore.collection('transactions').doc();
        transaction.set(withdrawalRef, {
          'userId': userId,
          'amount': -amount,
          'type': 'withdraw',
          'bankCode': bankCode,
          'bankAccount': accountNumber,
          'accountName': accountName,
          'transaction_id': transactionId,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
        });
      });
    } catch (e) {
      print('Error processing withdrawal: $e');
      rethrow;
    }
  }

  static void _createTransactionRecords(
    Transaction transaction,
    DocumentReference itemRef,
    Map<String, dynamic> item,
    String winnerId,
    int winningAmount,
  ) {
    transaction.set(_firestore.collection('transactions').doc(), {
      'userId': winnerId,
      'amount': -winningAmount,
      'type': 'auction_payment',
      'itemId': itemRef.id,
      'item_name': item['name'],
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'completed',
    });

    transaction.set(_firestore.collection('transactions').doc(), {
      'userId': item['seller_id'],
      'amount': winningAmount,
      'type': 'auction_sale',
      'itemId': itemRef.id,
      'item_name': item['name'],
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'completed',
    });
  }
}
