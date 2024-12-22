import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../home/controllers/home_controller.dart';

class AdminController extends GetxController {
  //TODO: Implement AdminController
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
      final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      return pickedFile?.path;
    } catch (e) {
      Get.snackbar("Error", "Gagal memilih gambar: $e", snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  // Fungsi untuk menambah gambar
  Future<void> addImage() async {
    String? newImagePath = await pickImage();
    if (newImagePath != null) {
      controllerHome.bannerPromo.add(newImagePath);
      controllerHome.currentPage.value = controllerHome.bannerPromo.length - 1;
      Get.snackbar("Tambah Gambar", "Gambar berhasil ditambahkan.", snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Tambah Gambar", "Tidak ada gambar yang dipilih.", snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Fungsi untuk mengedit gambar
  Future<void> editImage() async {
    if (controllerHome.currentPage.value < controllerHome.bannerPromo.length) {
      String? updatedImagePath = await pickImage();
      if (updatedImagePath != null) {
        controllerHome.bannerPromo[controllerHome.currentPage.value] = updatedImagePath;
        Get.snackbar("Edit Gambar", "Gambar berhasil diperbarui.", snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Edit Gambar", "Tidak ada gambar yang dipilih.", snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar("Edit Gambar", "Gambar tidak ditemukan.", snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Fungsi untuk menghapus gambar
  Future<void> removeImage() async {
    if (controllerHome.bannerPromo.isNotEmpty &&
        controllerHome.currentPage.value < controllerHome.bannerPromo.length) {
      int currentIndex = controllerHome.currentPage.value;
      controllerHome.bannerPromo.removeAt(currentIndex);

      if (currentIndex >= controllerHome.bannerPromo.length) {
        controllerHome.currentPage.value = controllerHome.bannerPromo.length - 1;
      }

      Get.snackbar("Hapus Gambar", "Gambar berhasil dihapus.", snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Hapus Gambar", "Tidak ada gambar untuk dihapus.", snackPosition: SnackPosition.BOTTOM);
    }
  }
}