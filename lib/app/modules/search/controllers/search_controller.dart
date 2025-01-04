import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lelang_fb/app/routes/app_pages.dart';
import 'package:lelang_fb/app/utils/live_auction_card.dart';
import 'package:lelang_fb/app/utils/upcoming_auction_card.dart';

class SearchingController extends GetxController {
  final searchController = TextEditingController();
  final items = <Map<String, dynamic>>[].obs;
  final filteredItems = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  final selectedStatus = ''.obs;
  final selectedCategory = ''.obs;
  final selectedPriceRange = Rx<RangeValues?>(null);
  final searchQuery = ''.obs;

  final sortBy = 'date_desc'.obs;
  final priceRange = RangeValues(0, 100000000).obs;
  final categories = [
    'Electronics',
    'Collectibles',
    'Art',
    'Antiques',
    'Fashion',
    'Others'
  ];

  bool get hasActiveFilters =>
      selectedStatus.value.isNotEmpty ||
      selectedCategory.value.isNotEmpty ||
      selectedPriceRange.value != null;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments != null) {
      if (arguments['filter'] != null) {
        selectedStatus.value = arguments['filter'];
      }
      if (arguments['fromSection'] != null) {
        switch (arguments['fromSection']) {
          case 'liveAuctions':
            sortBy.value = 'date_desc';
            selectedStatus.value = 'live';
            break;
          case 'upcomingAuctions':
            sortBy.value = 'date_asc';
            selectedStatus.value = 'upcoming';
            break;
        }
      }
    }
    setupItemsListener();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    applyFilters();
  }

  void setStatusFilter(String? status) {
    selectedStatus.value = status ?? '';
    applyFilters();
  }

  void clearStatusFilter() {
    selectedStatus.value = '';
    applyFilters();
  }

  void clearPriceFilter() {
    selectedPriceRange.value = null;
    priceRange.value = RangeValues(0, 100000000);
    applyFilters();
  }

  void clearCategoryFilter() {
    selectedCategory.value = '';
    applyFilters();
  }

  void resetFilters() {
    selectedStatus.value = '';
    selectedCategory.value = '';
    priceRange.value = RangeValues(0, 100000000);
    sortBy.value = 'date_desc';
    searchQuery.value = '';
    searchController.clear();
    applyFilters();
  }

  void updatePriceRange(RangeValues values) {
    final start = (values.start / 1000).round() * 1000.0;
    final end = (values.end / 1000).round() * 1000.0;
    priceRange.value = RangeValues(start, end);
    selectedPriceRange.value = priceRange.value;
    applyFilters();
  }

  void setupItemsListener() {
    try {
      isLoading.value = true;
      FirebaseFirestore.instance
          .collection('items')
          .where('status', whereIn: ['live', 'upcoming'])
          .snapshots()
          .listen((snapshot) {
            final fetchedItems = snapshot.docs
                .map((doc) => {
                      'id': doc.id,
                      ...doc.data(),
                    })
                .toList();

            items.value = fetchedItems;
            applyFilters();
            isLoading.value = false;
          }, onError: (e) {
            print('Error setting up items listener: $e');
            isLoading.value = false;
          });
    } catch (e) {
      print('Error in setupItemsListener: $e');
      isLoading.value = false;
    }
  }

  void applyFilters() {
    var filtered = List<Map<String, dynamic>>.from(items);

    if (selectedStatus.value.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item['status']?.toString().toLowerCase() ==
              selectedStatus.value.toLowerCase())
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((item) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        final description = item['description']?.toString().toLowerCase() ?? '';
        final query = searchQuery.value.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    if (selectedCategory.value.isNotEmpty) {
      filtered = filtered
          .where((item) => item['category'] == selectedCategory.value)
          .toList();
    }

    if (selectedPriceRange.value != null) {
      filtered = filtered.where((item) {
        final price = item['status'] == 'live'
            ? (item['current_price'] ?? 0.0).toDouble()
            : (item['starting_price'] ?? 0.0).toDouble();
        return price >= selectedPriceRange.value!.start &&
            price <= selectedPriceRange.value!.end;
      }).toList();
    }

    _sortItems(filtered);
    filteredItems.value = filtered;
  }

  void _sortItems(List<Map<String, dynamic>> items) {
    switch (sortBy.value) {
      case 'price_asc':
        items.sort((a, b) =>
            (a['current_price'] ?? 0).compareTo(b['current_price'] ?? 0));
        break;
      case 'price_desc':
        items.sort((a, b) =>
            (b['current_price'] ?? 0).compareTo(a['current_price'] ?? 0));
        break;
      case 'date_desc':
        items.sort((a, b) => (b['created_at'] ?? Timestamp.now())
            .compareTo(a['created_at'] ?? Timestamp.now()));
        break;
      case 'date_asc':
        items.sort((a, b) => (a['created_at'] ?? Timestamp.now())
            .compareTo(b['created_at'] ?? Timestamp.now()));
        break;
    }
  }

  Widget buildItemCard(Map<String, dynamic> item) {
    if (item['status'] == 'live') {
      if (item['jamSelesai'] != null && item['tanggal'] != null) {
        final tanggal = (item['tanggal'] as Timestamp).toDate();
        final jamSelesai = item['jamSelesai'].toString().split(':');
        final endTime = DateTime(
          tanggal.year,
          tanggal.month,
          tanggal.day,
          int.parse(jamSelesai[0]),
          int.parse(jamSelesai[1]),
        );

        return LiveAuctionCard(
          imageUrl:
              item['imageURL'] is List ? item['imageURL'][0] : item['imageURL'],
          name: item['name'] ?? 'Unnamed Item',
          price: (item['current_price'] ?? 0.0).toDouble(),
          location: item['lokasi'] ?? 'No location',
          rarity: item['rarity'] ?? 'Common',
          id: item['id'],
          endTime: endTime,
          bidCount: item['bid_count'] ?? 0,
          showLiveBadge: true,
          onTap: () => Get.toNamed(
            Routes.LIVE_AUCTION,
            arguments: {
              'itemId': item['id'],
              'itemName': item['name'],
              'currentPrice': item['current_price'] ?? 0.0,
              'tanggal': item['tanggal'],
              'jamMulai': item['jamMulai'],
              'jamSelesai': item['jamSelesai'],
              'imageUrls': item['imageURL'],
              'location': item['lokasi'],
              'category': item['category'],
              'rarity': item['rarity'],
              'description': item['description'],
              'sellerId': item['seller_id'],
              'bidCount': item['bid_count'] ?? 0,
              'province': item['province'],
              'status': item['status']
            },
          ),
        );
      }

      return Container();
    } else {
      return UpcomingAuctionCard(
        imageUrl:
            item['imageURL'] is List ? item['imageURL'][0] : item['imageURL'],
        name: item['name'] ?? 'Unnamed Item',
        price: (item['starting_price'] ?? 0.0).toDouble(),
        location: item['lokasi'] ?? 'No location',
        rarity: item['rarity'] ?? 'Common',
        date: (item['tanggal'] as Timestamp).toDate(),
        startTime: item['jamMulai'] ?? '',
        category: item['category'] ?? 'Others',
        onTap: () => Get.toNamed(Routes.DETAIL_ITEM, arguments: item),
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
