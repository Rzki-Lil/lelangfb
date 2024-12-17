import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lelang_fb/app/modules/home/views/home.dart';
import 'package:lelang_fb/app/modules/home/views/profile_view.dart';
import 'package:lelang_fb/core/assets/assets.gen.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../addItem/views/add_item_view.dart';
import '../../../modules/addItem/controllers/add_item_controller.dart';

class HomeController extends GetxController with SingleGetTickerProviderMixin {
  final selectedPage = 0.obs;
  final count = 0.obs;
  final search = FocusNode();
  final pageController = PageController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> carEvents = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> motorEvents = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> lifestyleEvents =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> liveAuctions =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> upcomingAuctions =
      <Map<String, dynamic>>[].obs;

  @override
  void onReady() {
    super.onReady();
  }

  final double width = 70;
  List<Widget> get menuItems {
    return [
      Column(
        children: [
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Assets.logo.logoMobil.image(),
          ),
          SizedBox(height: 8),
          Text(
            "Car",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
      Column(
        children: [
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(Assets.logo.logoMotor.path),
          ),
          SizedBox(height: 8),
          Text(
            "Motorcycle",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
      Column(
        children: [
          Container(
              width: width,
              height: width,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(Assets.logo.logoLifestyle.path)),
          SizedBox(height: 8),
          Text(
            "Lifestyle",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
      Column(
        children: [
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(Assets.logo.logoAuction.path),
          ),
          SizedBox(height: 8),
          Text(
            "Auction",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    ];
  }

  var currentPage = 0.obs;
  Timer? _timer;
  Timer? _statusCheckTimer;

  final listNew = [
    Assets.images.banner1.path,
    Assets.logo.logoBanner.path,
  ];

  final List<Widget> widgetOptions = [
    Home(),
    AddItemView(),
    Text("List"),
    ProfileView(),
  ];

  void changePage(int index) {
    selectedPage.value = index;
  }

  @override
  void onInit() {
    super.onInit();

    initializeDateFormatting('id_ID', null).then((_) {
      print('Date formatting initialized');
    });
    print('HomeController onInit called');
    Get.lazyPut(() => AddItemController());
    tabController = TabController(length: 3, vsync: this);
    fetchEvents();
    setupItemsListener();

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
  }

  void setupItemsListener() {
    try {
      print('Setting up items listener...');

      _firestore.collection('items').snapshots().listen(
        (snapshot) {
          print('Received snapshot with ${snapshot.docs.length} documents');

          if (snapshot.docs.isEmpty) {
            print('No documents found in items collection');
            return;
          }

          try {
            items.value = snapshot.docs.map((doc) {
              final data = doc.data();
              return processItemData(doc.id, data);
            }).toList();

            liveAuctions.value =
                items.where((item) => item['status'] == 'live').toList();
            upcomingAuctions.value =
                items.where((item) => item['status'] == 'upcoming').toList();

            print('Processed ${items.length} items successfully');
            if (items.isNotEmpty) {
              print('Sample item: ${items.first}');
            }
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
      String docId, Map<String, dynamic> data) {
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
      'bid_count': data['bid_count'] ?? 0,
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

  void checkAndUpdateAuctionStatus() async {
    final now = DateTime.now();
    final batch = _firestore.batch();
    bool hasChanges = false;

    for (var item in items) {
      try {
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

        final docRef = _firestore.collection('items').doc(item['id']);

        if (item['status'] == 'upcoming' &&
            (now.isAfter(itemStartDateTime) ||
                now.isAtSameMomentAs(itemStartDateTime))) {
          batch.update(docRef, {
            'status': 'live',
            'updated_at': Timestamp.now(),
          });
          hasChanges = true;
          print('Starting auction: ${item['name']}');
        } else if (item['status'] == 'live' && now.isAfter(itemEndDateTime)) {
          batch.update(docRef, {
            'status': 'closed',
            'updated_at': Timestamp.now(),
          });
          hasChanges = true;
          print('Closing auction: ${item['name']}');
        }
      } catch (e) {
        print('Error checking auction status for item ${item['name']}: $e');
      }
    }

    if (hasChanges) {
      try {
        await batch.commit();
        print('Successfully updated auction statuses');
        setupItemsListener();
      } catch (e) {
        print('Error updating auction statuses: $e');
      }
    }
  }
}
