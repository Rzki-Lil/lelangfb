import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddItemController extends GetxController {
  //TODO: Implement AddItemController

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
  var currentPage = 0.obs;
  final CarouselSliderController carouselController =
      CarouselSliderController();
  List<String> list = <String>['Mobil', 'Motor', 'LifeStyle'].obs;

  var selectedValue = ''.obs; // Observable for the selected value

  var images = <File>[].obs;

  final ImagePicker picker = ImagePicker();

  Future<void> getImagesFromGallery() async {
    final pickedFile = await picker.pickMultiImage(
      imageQuality: 80,
    );
    if (pickedFile.isNotEmpty) {
      images.addAll(
        pickedFile.map(
          (file) => File(file.path),
        ),
      );
    } else {
      print('No image selected');
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);

      // Pastikan currentPage tetap valid setelah penghapusan
      if (images.isEmpty) {
        currentPage.value = 0; // Atur currentPage ke 0 jika tidak ada gambar
      } else {
        // Jika gambar terakhir dihapus, pastikan currentPage tidak melebihi jumlah gambar yang tersisa
        if (currentPage.value >= images.length) {
          currentPage.value = images.length - 1;
        }
      }
    }
  }

  void onImageAdded() {
    carouselController.animateToPage(images.length - 1);
    currentPage.value = images.length - 1;
  }
}
