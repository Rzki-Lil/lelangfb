import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../services/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path/path.dart' as path;

class MyitemsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  final items = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final ImagePicker _picker = ImagePicker();
  final isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserItems();
  }

  Future<void> fetchUserItems() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection('items')
          .where('seller_id', isEqualTo: user?.uid)
          .get();

      final List<Map<String, dynamic>> itemsList = [];

      for (var doc in snapshot.docs) {
        final itemData = doc.data();
        Map<String, dynamic> item = {
          'id': doc.id,
          ...itemData,
        };

        if (itemData['status']?.toLowerCase() == 'closed' &&
            itemData['winner_id'] != null) {
          try {
            final winnerDoc = await _firestore
                .collection('users')
                .doc(itemData['winner_id'])
                .get();

            if (winnerDoc.exists) {
              final winnerData = winnerDoc.data()!;

              final addressSnapshot = await _firestore
                  .collection('users')
                  .doc(itemData['winner_id'])
                  .collection('addresses')
                  .where('isDefault', isEqualTo: true)
                  .limit(1)
                  .get();

              Map<String, dynamic>? defaultAddress;
              if (addressSnapshot.docs.isNotEmpty) {
                defaultAddress = addressSnapshot.docs.first.data();
              }

              item.addAll({
                'winner_name': winnerData['displayName'] ?? 'Unknown',
                'winner_phone': winnerData['phoneNumber'],
                'winner_photo': winnerData['photoURL'] ?? '',
                'winner_email': winnerData['email'] ?? '',
                'winner_address': defaultAddress?['address'],
                'winner_city': defaultAddress?['city'],
                'winner_province': defaultAddress?['province'],
                'winner_postal_code': defaultAddress?['postalCode'],
              });
            }
          } catch (e) {
            print('Error fetching winner details: $e');
          }
        }

        itemsList.add(item);
      }

      items.value = itemsList;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItemName(String itemId, String newName) async {
    try {
      await _firestore.collection('items').doc(itemId).update({
        'name': newName,
        'updated_at': FieldValue.serverTimestamp(),
      });
      await fetchUserItems();
      Get.back();
      Get.snackbar('Success', 'Item name updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update item name: $e');
    }
  }

  Future<void> addImage(String itemId, List<String> currentImages) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final uid = user?.uid ?? '';
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final filename = '${timestamp}_${path.basename(image.path)}';

        final imageUrl = await CloudinaryService.uploadImage(
          File(image.path),
          folder: 'items/$uid',
          filename: filename,
        );

        List<String> updatedImages = [...currentImages, imageUrl];
        await _firestore.collection('items').doc(itemId).update({
          'imageURL': updatedImages,
          'updated_at': FieldValue.serverTimestamp(),
        });

        await fetchUserItems();
        Get.snackbar('Success', 'Image added successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add image: $e');
      print('Error adding image: $e');
    }
  }

  Future<void> removeImage(
      String itemId, List<String> images, int index) async {
    try {
      isDeleting.value = true;

      final bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Delete Image?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: images[index],
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),
              Text('Are you sure you want to delete this image?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final String imageUrl = images[index];
      final String publicId = CloudinaryService.getPublicIdFromUrl(imageUrl);
      print('Attempting to delete image with publicId: $publicId');

      await CloudinaryService.deleteImage(publicId);
      print('Successfully deleted from Cloudinary');

      images.removeAt(index);
      await _firestore.collection('items').doc(itemId).update({
        'imageURL': images,
        'updated_at': FieldValue.serverTimestamp(),
      });
      print('Successfully updated Firestore');

      if (Get.isDialogOpen == true) Get.back();

      await fetchUserItems();
      Get.snackbar(
        'Success',
        'Image deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error details: $e');
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        'Error',
        'Failed to delete image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> deleteItem(String itemId, List<String> images) async {
    try {
      final bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Delete Item'),
          content: Text(
              'This will permanently delete this item and all its images.'),
          actions: [
            TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancel')),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      for (String imageUrl in images) {
        try {
          await CloudinaryService.deleteImageByUrl(imageUrl);
        } catch (e) {
          print('Error deleting image: $e');
        }
      }

      await _firestore.collection('items').doc(itemId).delete();

      if (Get.isDialogOpen!) Get.back();
      await fetchUserItems();
      Get.snackbar('Success', 'Item deleted successfully');
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar('Error', 'Failed to delete item: $e');
    }
  }

  Future<void> editImageAtIndex(
      String itemId, List<String> images, int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        final String currentImageUrl = images[index];
        final String uid = user?.uid ?? '';
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final filename = '${timestamp}_${path.basename(pickedFile.path)}';

        final File imageFile = File(pickedFile.path);
        final String newImageUrl = await CloudinaryService.uploadImage(
          imageFile,
          folder: 'items/$uid',
          filename: filename,
          previousImageUrl: currentImageUrl,
        );

        images[index] = newImageUrl;
        await _firestore.collection('items').doc(itemId).update({
          'imageURL': images,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (Get.isDialogOpen!) Get.back();
        await fetchUserItems();
        Get.snackbar('Success', 'Image updated successfully');
      }
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar('Error', 'Failed to update image: $e');
    }
  }

  Future<void> setAsThumbnail(
      String itemId, List<String> images, int index) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final selectedImage = images.removeAt(index);
      images.insert(0, selectedImage);

      await _firestore.collection('items').doc(itemId).update({
        'imageURL': images,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (Get.isDialogOpen!) Get.back();
      await fetchUserItems();
      Get.snackbar('Success', 'Thumbnail updated successfully');
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar('Error', 'Failed to update thumbnail: $e');
    }
  }

  Future<void> updateItemBasicInfo(
    String itemId,
    String name,
    String description,
  ) async {
    try {
      await _firestore.collection('items').doc(itemId).update({
        'name': name,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Get.back();
      await fetchUserItems();
      Get.snackbar('Success', 'Item updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update item: $e');
    }
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
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _updateItem(
    String itemId,
    String name,
    String description,
  ) async {
    try {
      await _firestore.collection('items').doc(itemId).update({
        'name': name,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Get.back();
      await fetchUserItems();
      Get.snackbar('Success', 'Item updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update item: $e');
    }
  }

  void reorderImages(
      String itemId, List<String> images, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = images.removeAt(oldIndex);
    images.insert(newIndex, item);

    FirebaseFirestore.instance
        .collection('items')
        .doc(itemId)
        .update({'imageURL': images}).then((_) {
      fetchUserItems();
      Get.snackbar(
        'Success',
        'Image order updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }).catchError((error) {
      Get.snackbar(
        'Error',
        'Failed to update image order',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }
}
