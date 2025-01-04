import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/home/controllers/home_controller.dart';
import 'package:lelang_fb/app/widgets/header.dart';
import '../../../../core/constants/color.dart';
import '../controllers/admin_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: Header(
        title: 'Admin Panel',
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.hijauTua),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.addImage,
        backgroundColor: AppColors.hijauTua,
        icon: Icon(Icons.add_photo_alternate),
        label: Text('Add New Image'),
      ),
      body: Column(
        children: [
          // Stats Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.hijauTua,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Obx(() {
              final imageCount =
                  controller.controllerHome.carouselImages.length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Total Images', imageCount.toString()),
                  _buildStat('Active', imageCount.toString()),
                  _buildStat('Max Allowed', '5'),
                ],
              );
            }),
          ),
          // Grid Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Carousel Images',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      controller.controllerHome.fetchCarouselImages(),
                  icon: Icon(Icons.refresh),
                  label: Text('Refresh'),
                ),
              ],
            ),
          ),
          // Image Grid
          Expanded(
            child: Obx(() {
              if (controller.controllerHome.carouselImages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No carousel images found',
                          style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: controller.addImage,
                        icon: Icon(Icons.add_photo_alternate),
                        label: Text('Add First Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.hijauTua,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: controller.controllerHome.carouselImages.length,
                itemBuilder: (context, index) =>
                    _buildImageCard(controller, index),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(AdminController controller, int index) {
    final imageUrl = controller.controllerHome.carouselImages[index];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(Icons.error, color: Colors.red),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Action Buttons and Index
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Image Number
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppColors.hijauTua,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Action Buttons
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.edit,
                        color: AppColors.hijauTua,
                        onTap: () => controller.editImageAtIndex(index),
                      ),
                      SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.delete,
                        color: Colors.red,
                        onTap: () => controller.removeImageAtIndex(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }

  void _showHelp() {
    Get.dialog(
      AlertDialog(
        title: Text('Help & Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.add_photo_alternate,
              title: 'Adding Images',
              description: 'Click the + button to add new carousel images.',
            ),
            _buildHelpItem(
              icon: Icons.edit,
              title: 'Editing Images',
              description: 'Use the edit button to replace existing images.',
            ),
            _buildHelpItem(
              icon: Icons.delete,
              title: 'Deleting Images',
              description: 'Remove unwanted images using the delete button.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.hijauTua),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
