import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/home/controllers/home_controller.dart';
import 'package:lelang_fb/app/modules/home/views/home.dart';
import 'package:lelang_fb/app/modules/home/views/home_view.dart';
import 'package:lelang_fb/app/widgets/header.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:intl/intl.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchingController> {
  const SearchView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(SearchingController());

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: Header(
        title: 'Search Items',
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.hijauTua),
            onPressed: () {
              Get.find<HomeController>().changePage(0);
              Get.back();
            }),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: Icon(Icons.search, color: AppColors.hijauTua),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),
          Obx(() => controller.hasActiveFilters
              ? Container(
                  height: 40,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (controller.selectedStatus.value.isNotEmpty)
                        _buildFilterChip(
                          label: controller.selectedStatus.value,
                          onDeleted: () => controller.clearStatusFilter(),
                        ),
                      if (controller.selectedPriceRange.value != null)
                        _buildFilterChip(
                          label:
                              'Rp${controller.selectedPriceRange.value!.start.toStringAsFixed(0)} - Rp${controller.selectedPriceRange.value!.end.toStringAsFixed(0)}',
                          onDeleted: () => controller.clearPriceFilter(),
                        ),
                      if (controller.selectedCategory.value.isNotEmpty)
                        _buildFilterChip(
                          label: controller.selectedCategory.value,
                          onDeleted: () => controller.clearCategoryFilter(),
                        ),
                    ],
                  ),
                )
              : SizedBox()),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildStatusTab('All', null),
                      SizedBox(width: 8),
                      _buildStatusTab('Live', 'live'),
                      SizedBox(width: 8),
                      _buildStatusTab('Upcoming', 'upcoming'),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list, color: AppColors.hijauTua),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              final items = controller.filteredItems;

              if (items.isEmpty) {
                return _buildEmptyState();
              }

              return GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return controller.buildItemCard(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String label, String? status) {
    return Obx(() => InkWell(
          onTap: () => controller.setStatusFilter(status),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: controller.selectedStatus.value == (status ?? '')
                  ? AppColors.hijauTua
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: controller.selectedStatus.value == (status ?? '')
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ));
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: Icon(Icons.close, size: 18),
        onDeleted: onDeleted,
        backgroundColor: AppColors.hijauTua.withOpacity(0.1),
        labelStyle: TextStyle(color: AppColors.hijauTua),
        deleteIconColor: AppColors.hijauTua,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'No items match your search'
                : 'No items found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/detail-item', arguments: item),
        child: Container(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['imageURL'] is List
                      ? item['imageURL'][0]
                      : (item['imageURL'] ?? ''),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item['status'] ?? ''),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (item['status'] ?? 'upcoming').toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      item['name'] ?? 'Unnamed Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rp ${NumberFormat.currency(
                        locale: 'id',
                        symbol: '',
                        decimalDigits: 0,
                      ).format(item['current_price'] ?? 0)}',
                      style: TextStyle(
                        color: AppColors.hijauTua,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['lokasi'] ?? 'No location',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'ended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

void _showFilterBottomSheet(BuildContext context) {
  final controller = Get.find<SearchingController>();
  final scrollController = ScrollController();

  Get.bottomSheet(
    Container(
      height: Get.height * 0.8,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => controller.resetFilters(),
                    child: Text('Reset',
                        style: TextStyle(color: Colors.grey[600])),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Price Range'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => _showPriceInputDialog(
                                    context,
                                    isMin: true,
                                    currentValue:
                                        controller.priceRange.value.start,
                                    onChanged: (value) {
                                      if (value <=
                                          controller.priceRange.value.end) {
                                        controller.updatePriceRange(RangeValues(
                                          value,
                                          controller.priceRange.value.end,
                                        ));
                                      }
                                    },
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Min: Rp ${NumberFormat('#,###').format(controller.priceRange.value.start.toInt())}',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showPriceInputDialog(
                                    context,
                                    isMin: false,
                                    currentValue:
                                        controller.priceRange.value.end,
                                    onChanged: (value) {
                                      if (value >=
                                          controller.priceRange.value.start) {
                                        controller.updatePriceRange(RangeValues(
                                          controller.priceRange.value.start,
                                          value,
                                        ));
                                      }
                                    },
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Max: Rp ${NumberFormat('#,###').format(controller.priceRange.value.end.toInt())}',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(height: 20),
                      Obx(() => RangeSlider(
                            values: controller.priceRange.value,
                            min: 0,
                            max: 100000000,
                            divisions: 1000,
                            onChanged: controller.updatePriceRange,
                            activeColor: AppColors.hijauTua,
                            inactiveColor: Colors.grey[300],
                          )),
                    ],
                  ),
                  _buildSectionTitle('Category'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.categories.map((category) {
                      return Obx(() => FilterChip(
                            selected:
                                controller.selectedCategory.value == category,
                            label: Text(category),
                            onSelected: (selected) {
                              controller.selectedCategory.value =
                                  selected ? category : '';
                            },
                            selectedColor: AppColors.hijauTua.withOpacity(0.2),
                            checkmarkColor: AppColors.hijauTua,
                          ));
                    }).toList(),
                  ),
                  _buildSectionTitle('Status'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Live', 'Upcoming'].map((status) {
                      return Obx(() => ChoiceChip(
                            selected: controller.selectedStatus.value ==
                                status.toLowerCase(),
                            label: Text(status),
                            onSelected: (selected) {
                              controller.setStatusFilter(
                                  selected ? status.toLowerCase() : null);
                            },
                            selectedColor: AppColors.hijauTua.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: controller.selectedStatus.value ==
                                      status.toLowerCase()
                                  ? AppColors.hijauTua
                                  : Colors.black87,
                            ),
                          ));
                    }).toList(),
                  ),
                  _buildSectionTitle('Sort By'),
                  Obx(() => Column(
                        children: [
                          _buildSortOption('Price: Low to High', 'price_asc'),
                          _buildSortOption('Price: High to Low', 'price_desc'),
                          _buildSortOption('Newest First', 'date_desc'),
                          _buildSortOption('Oldest First', 'date_asc'),
                        ],
                      )),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.applyFilters();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.hijauTua,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    ),
  );
}

Widget _buildSortOption(String label, String value) {
  final controller = Get.find<SearchingController>();
  return RadioListTile<String>(
    value: value,
    groupValue: controller.sortBy.value,
    onChanged: (val) => controller.sortBy.value = val!,
    title: Text(label),
    activeColor: AppColors.hijauTua,
    contentPadding: EdgeInsets.zero,
  );
}

void _showPriceInputDialog(
  BuildContext context, {
  required bool isMin,
  required double currentValue,
  required Function(double) onChanged,
}) {
  final controller = TextEditingController(
    text: NumberFormat('#,###').format(currentValue.toInt()),
  );

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isMin ? "Minimum" : "Maximum"} Price',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                value = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (value.isNotEmpty) {
                  final numValue = double.parse(value);

                  controller.text = NumberFormat('#,###').format(numValue);
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final value = double.tryParse(
                      controller.text.replaceAll(RegExp(r'[^0-9]'), ''),
                    );
                    if (value != null) {
                      onChanged(value);
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hijauTua,
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
