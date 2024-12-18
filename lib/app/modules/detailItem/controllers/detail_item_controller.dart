import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DetailItemController extends GetxController {
  //TODO: Implement DetailItemController
  var currentPage = 0.obs;
  final isExpanded = false.obs;
  final isClicked = false.obs;
  final box = GetStorage(); // Mendeklarasikan GetStorage
  final count = 0.obs;
  final favoriteItems = <Map<String, dynamic>>[].obs;

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

  void addFavoriteItem(Map<String, dynamic> item) {
    item['isFavorite'] = !(item['isFavorite']); // Toggle status favorit
    if (item['isFavorite']) {
      if (!favoriteItems.contains(item)) {
        favoriteItems.add(item); // Tambahkan item ke dalam daftar favorit
      }
    } else {
      favoriteItems.remove(item); // Hapus item dari daftar favorit
    }

    // Simpan status favorit ke GetStorage
    box.write(
        'favoriteItems', favoriteItems); // Menyimpan seluruh daftar favorit
    update(); // Memperbarui tampilan
  }

  // Memuat item favorit dari GetStorage
  void loadFavoriteItems() {
    final storedItems = box.read('favoriteItems') ?? [];
    print('Stored Favorite Items: $storedItems'); // Debugging line
    favoriteItems.value =
        List<Map<String, dynamic>>.from(storedItems); // Memuat data favorit
  }
}
