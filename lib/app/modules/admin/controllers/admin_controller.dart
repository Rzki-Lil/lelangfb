import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../../services/cloudinary_service.dart';
import 'package:flutter/material.dart';

import '../../home/controllers/home_controller.dart';

class AdminController extends GetxController {
  final ImagePicker imagePicker = ImagePicker();
  final controllerHome = Get.put(HomeController());

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  // Fungsi untuk memilih gambar
  Future<String?> pickImage() async {
    try {
      final XFile? pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      return pickedFile?.path;
    } catch (e) {
      Get.snackbar("Error", "Gagal memilih gambar: $e",
          snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  // Fungsi untuk menambah gambar
  Future<void> addImage() async {
    try {
      final XFile? pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final String imageUrl = await CloudinaryService.uploadImage(imageFile);

        await FirebaseFirestore.instance.collection('carousel').add({
          'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await controllerHome.fetchCarouselImages();
        Get.snackbar('Success', 'Image added successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add image: $e');
    }
  }

  // Fungsi untuk mengedit gambar
  Future<void> editImage() async {
    if (controllerHome.currentPage.value < controllerHome.bannerPromo.length) {
      String? updatedImagePath = await pickImage();
      if (updatedImagePath != null) {
        controllerHome.bannerPromo[controllerHome.currentPage.value] =
            updatedImagePath;
        Get.snackbar("Edit Gambar", "Gambar berhasil diperbarui.",
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Edit Gambar", "Tidak ada gambar yang dipilih.",
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar("Edit Gambar", "Gambar tidak ditemukan.",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> editImageAtIndex(int index) async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final String currentImageUrl = controllerHome.carouselImages[index];

        final File imageFile = File(pickedFile.path);
        final String newImageUrl =
            await CloudinaryService.uploadImage(imageFile);

        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('carousel')
            .where('imageUrl', isEqualTo: currentImageUrl)
            .get();

        if (snapshot.docs.isNotEmpty) {
          await snapshot.docs.first.reference.update({
            'imageUrl': newImageUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        final String oldPublicId =
            CloudinaryService.getPublicIdFromUrl(currentImageUrl);
        await CloudinaryService.deleteImage(oldPublicId);

        await controllerHome.fetchCarouselImages();
        Get.snackbar('Success', 'Image updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update image: $e');
    }
  }

  Future<void> removeImage() async {
    try {
      if (controllerHome.carouselImages.isEmpty) return;

      final String imageUrl =
          controllerHome.carouselImages[controllerHome.currentPage.value];
      final String publicId = CloudinaryService.getPublicIdFromUrl(imageUrl);

      await CloudinaryService.deleteImage(publicId);

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('carousel')
          .where('imageUrl', isEqualTo: imageUrl)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }

      await controllerHome.fetchCarouselImages();
      Get.snackbar('Success', 'Image removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove image: $e');
    }
  }

  Future<void> removeImageAtIndex(int index) async {
    try {
      final imageUrl = controllerHome.carouselImages[index];

      final bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Delete Image?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
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

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('carousel')
          .where('imageUrl', isEqualTo: imageUrl)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }

      final String publicId = CloudinaryService.getPublicIdFromUrl(imageUrl);
      await CloudinaryService.deleteImage(publicId);

      Get.back();

      await controllerHome.fetchCarouselImages();
      Get.snackbar(
        'Success',
        'Image deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      print('Delete error details: $e');
      Get.snackbar(
        'Error',
        'Could not delete image. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }
}
