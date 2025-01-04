import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../controllers/myitems_controller.dart';
import '../../../../core/constants/color.dart';
import 'package:intl/intl.dart';
import '../../../widgets/header.dart';

class MyitemsView extends GetView<MyitemsController> {
  const MyitemsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyitemsController());

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: Header(
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My Items',
              style: TextStyle(
                color: AppColors.hijauTua,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.inventory_2_outlined,
              color: AppColors.hijauTua,
              size: 24,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        leading: Container(
          margin: EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.hijauTua), // Changed to regular arrow_back
            onPressed: () => Get.back(),
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-item'),
        backgroundColor: AppColors.hijauTua,
        icon: Icon(Icons.add_photo_alternate, color: Colors.white),
        label: Text('Add New Item', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Instructions Card
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12), // Changed from EdgeInsets.all(16)
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to edit your Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.hijauTua,
                  ),
                ),
                SizedBox(height: 16),
                _buildInstructionRow(
                  icon: Icons.swipe,
                  color: AppColors.hijauTua,
                  text: "Swipe left to edit or delete items",
                ),
                SizedBox(height: 12),
                _buildInstructionRow(
                  icon: Icons.touch_app,
                  color: Colors.blue,
                  text: "Tap on images to manage them",
                ),
                SizedBox(height: 12),
                _buildInstructionRow(
                  icon: Icons.sort,
                  color: Colors.orange,
                  text: "Drag images to reorder them",
                ),
              ],
            ),
          ),
          // Existing List View
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No items found',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchUserItems(),
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
                  itemCount: controller.items.length,
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    final List<String> images =
                        List<String>.from(item['imageURL'] ?? []);

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Slidable(
                        endActionPane: ActionPane(
                          extentRatio: 0.5,
                          motion: const ScrollMotion(),
                          dragDismissible: false,
                          children: [
                            CustomSlidableAction(
                              flex: 1,
                              padding: EdgeInsets.zero,
                              onPressed: (_) =>
                                  controller.showEditItemDialog(item),
                              backgroundColor: AppColors.hijauTua,
                              foregroundColor: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(height: 4),
                                  Text('Edit', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            CustomSlidableAction(
                              flex: 1,
                              padding: EdgeInsets.zero,
                              onPressed: (_) =>
                                  controller.deleteItem(item['id'], images),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete),
                                  SizedBox(height: 4),
                                  Text('Delete',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (images.isNotEmpty)
                                      _buildImageGrid(images, item['id']),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildStatusBadge(
                                            item['status'] ?? 'upcoming'),
                                        _buildRarityBadge(
                                            item['rarity'] ?? 'Common'),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      item['name'] ?? 'Unnamed Item',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp ',
                                        decimalDigits: 0,
                                      ).format(item['current_price'] ?? 0),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.hijauTua,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    _buildTimeInfo(item),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'live':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        displayText = 'LIVE';
        break;
      case 'upcoming':
        backgroundColor = AppColors.hijauTua.withOpacity(0.1);
        textColor = AppColors.hijauTua;
        displayText = 'UPCOMING';
        break;
      case 'closed':
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        displayText = 'CLOSED';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        displayText = status.toUpperCase();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeInfo(Map<String, dynamic> item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
            SizedBox(width: 4),
            Text(
              '${item['jamMulai'] ?? '--:--'} - ${item['jamSelesai'] ?? '--:--'} WIB',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (item['status']?.toLowerCase() == 'closed' &&
            item['winner_id'] != null)
          GestureDetector(
            onTap: () => _showWinnerDetails(item),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, size: 14, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    item['winner_name'] ?? 'Winner',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showWinnerDetails(Map<String, dynamic> item) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Winner Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: item['winner_photo']?.isNotEmpty == true
                        ? NetworkImage(item['winner_photo'])
                        : null,
                    child: item['winner_photo']?.isNotEmpty != true
                        ? Icon(Icons.person)
                        : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['winner_name'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          item['winner_email'] ?? 'N/A',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 24),
              _buildDetailRow('Phone', item['winner_phone'] ?? 'N/A'),
              _buildDetailRow(
                'Final Bid',
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(item['final_price'] ?? item['current_price'] ?? 0),
              ),
              SizedBox(height: 16),
              Text(
                'Shipping Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['winner_address'] ?? 'N/A'),
                    if (item['winner_city'] != null) ...[
                      SizedBox(height: 4),
                      Text(
                          '${item['winner_city']}, ${item['winner_province']}'),
                      SizedBox(height: 4),
                      Text('${item['winner_postal_code']}'),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Close'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.hijauTua,
                  ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<String> images, String itemId) {
    return Container(
      height: 100,
      child: ReorderableListView(
        scrollDirection: Axis.horizontal,
        onReorder: (oldIndex, newIndex) {
          controller.reorderImages(itemId, images, oldIndex, newIndex);
        },
        children: [
          ...List.generate(images.length, (index) {
            return GestureDetector(
              key: Key('image_$index'),
              onTap: () => _showImageOptions(itemId, images, index),
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: images[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Thumbnail',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          if (images.length < 5)
            GestureDetector(
              key: Key('add_image'),
              onTap: () => controller.addImage(itemId, images),
              child: Container(
                width: 100,
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.hijauTua),
                  color: AppColors.hijauTua.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.add_photo_alternate,
                  color: AppColors.hijauTua,
                  size: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRarityBadge(String rarity) {
    Color color = _getRarityColor(rarity);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        rarity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      case 'mythic':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showImageOptions(String itemId, List<String> images, int index) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index != 0)
              ListTile(
                leading: Icon(Icons.push_pin),
                title: Text('Set as Thumbnail'),
                onTap: () {
                  Get.back();
                  controller.setAsThumbnail(itemId, images, index);
                },
              ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Replace Image'),
              onTap: () {
                Get.back();
                controller.editImageAtIndex(itemId, images, index);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Image', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                controller.removeImage(itemId, images, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showEditItemDialog(Map<String, dynamic> item) async {
    final nameController = TextEditingController(text: item['name']);
    final descriptionController =
        TextEditingController(text: item['description']);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Item',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                _buildTextField(nameController, 'Name'),
                SizedBox(height: 8),
                _buildTextField(descriptionController, 'Description',
                    maxLines: 3),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => controller.updateItemBasicInfo(
                        item['id'],
                        nameController.text,
                        descriptionController.text,
                      ),
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
} // End of class
