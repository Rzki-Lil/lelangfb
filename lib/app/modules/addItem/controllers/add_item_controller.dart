import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lelang_fb/app/modules/home/controllers/home_controller.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:path/path.dart' as path;
import '../../../services/location_service.dart';
import '../../../services/cloudinary_service.dart';

import 'package:wheel_picker/wheel_picker.dart';

class AddItemController extends GetxController {
  static AddItemController get to => Get.find();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();

  var isLoading = false.obs;
  var selectedValue = ''.obs;
  var images = <File>[].obs;

  final ImagePicker picker = ImagePicker();
  List<String> categoryList = [
    'Electronics',
    'Collectibles',
    'Art',
    'Antiques',
    'Fashion',
    'Others'
  ].obs;

  var selectedDate = DateTime.now().obs;

  var isExpanded1 = false.obs;
  var isExpanded2 = false.obs;

  var characterCount = 0.obs;

  final RxList<Province> provinces = <Province>[].obs;
  final RxList<City> cities = <City>[].obs;
  final Rxn<Province> selectedProvince = Rxn<Province>();
  final Rxn<City> selectedCity = Rxn<City>();

  final RxBool isLoadingProvinces = false.obs;
  final RxBool isLoadingCities = false.obs;

  final Rx<String> selectedStartTime = '00:00'.obs;
  final Rx<String> selectedEndTime = '23:59'.obs;
  final Rx<String> selectedDateStr = ''.obs;

  var selectedRarity = ''.obs;

  List<String> rarityList =
      ['Common', 'Uncommon', 'Rare', 'Epic', 'Legendary', 'Mythic'].obs;

  var thumbnailImage = Rxn<File>();
  var carouselImages = <File>[].obs;

  final selectedHour = 0.obs;
  final selectedMinute = 0.obs;
  final isAm = true.obs;

  final FocusNode priceFocus = FocusNode();

  Future<void> pickThumbnailImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      thumbnailImage.value = File(pickedFile.path);
    }
  }

  Future<void> pickCarouselImages() async {
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 80,
    );
    if (pickedFiles.isNotEmpty) {
      carouselImages.addAll(
        pickedFiles.map((file) => File(file.path)),
      );
    }
  }

  void removeThumbnailImage() {
    thumbnailImage.value = null;
  }

  void removeCarouselImage(int index) {
    if (index >= 0 && index < carouselImages.length) {
      carouselImages.removeAt(index);
    }
  }

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

  Future<void> showDatePicker() async {
    try {
      final now = DateTime.now();
      final picked = await showDialog<DateTime>(
        context: Get.context!,
        builder: (BuildContext context) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.hijauTua,
                  ),
            ),
            child: DatePickerDialog(
              initialDate: selectedDate.value,
              firstDate: now,
              lastDate: DateTime(now.year + 1),
            ),
          );
        },
      );

      if (picked != null) {
        selectedDate.value = picked;
        String formattedDate = formatDate(picked);
        selectedDateStr.value = formattedDate;
        dateController.text = formattedDate;
        update();
      }
    } catch (e) {
      print('Error showing date picker: $e');
      Get.snackbar(
        'Error',
        'Failed to show date picker',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> showTimePicker(bool isStartTime) async {
    selectedHour.value = 0;
    selectedMinute.value = 0;
    isAm.value = true;

    await Get.bottomSheet(
      Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  Text(
                    isStartTime ? 'Select Start Time' : 'Select End Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.hijauTua,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (selectedHour.value != '' &&
                          selectedMinute.value != '') {
                        int hour = selectedHour.value;
                        if (!isAm.value) {
                          // PM
                          if (hour != 12) hour += 12;
                        } else {
                          // AM
                          if (hour == 12) hour = 0;
                        }

                        final timeStr =
                            '${hour.toString().padLeft(2, '0')}:${selectedMinute.value.toString().padLeft(2, '0')}';
                        if (isStartTime) {
                          selectedStartTime.value = timeStr;
                          startTimeController.text = timeStr;
                        } else {
                          selectedEndTime.value = timeStr;
                          endTimeController.text = timeStr;
                        }
                      }
                      Get.back();
                    },
                    child: Text('Done',
                        style: TextStyle(
                            color: AppColors.hijauTua,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: Get.width * 0.8,
                  height: 250,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      //highlight
                      Center(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.hijauTua.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      //puter
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: WheelPicker(
                                itemCount: 12,
                                onIndexChanged: (index) {
                                  selectedHour.value = index;
                                },
                                looping: true,
                                style: WheelPickerStyle(
                                  itemExtent: 50,
                                  squeeze: 1.25,
                                  diameterRatio: 2.0,
                                  surroundingOpacity: 0.3,
                                  magnification: 1.2,
                                ),
                                builder: (context, index) {
                                  return Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${(index == 0 ? 12 : index)}'
                                          .padLeft(2, '0'),
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                ':',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.hijauTua,
                                ),
                              ),
                            ),
                            Expanded(
                              child: WheelPicker(
                                itemCount: 60,
                                onIndexChanged: (index) {
                                  selectedMinute.value = index;
                                },
                                looping: true,
                                style: WheelPickerStyle(
                                  itemExtent: 50,
                                  squeeze: 1.25,
                                  diameterRatio: 2.0,
                                  surroundingOpacity: 0.3,
                                  magnification: 1.2,
                                ),
                                builder: (context, index) {
                                  return Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      index.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: WheelPicker(
                                itemCount: 2,
                                onIndexChanged: (index) =>
                                    isAm.value = index == 0,
                                looping: false,
                                style: WheelPickerStyle(
                                  itemExtent: 50,
                                  squeeze: 1.25,
                                  diameterRatio: 2.0,
                                  surroundingOpacity: 0.3,
                                  magnification: 1.2,
                                ),
                                builder: (context, index) {
                                  return Obx(() => Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: Text(
                                          index == 0 ? 'AM' : 'PM',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: (isAm.value == (index == 0))
                                                ? AppColors.hijauTua
                                                : Colors.grey[400],
                                            fontWeight:
                                                (isAm.value == (index == 0))
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                          ),
                                        ),
                                      ));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  Future<void> submitItem() async {
    try {
      if (!validateForm()) return;
      isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Please login first',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      List<String> allImageUrls = [];

      if (thumbnailImage.value != null) {
        try {
          final thumbnailUrl = await CloudinaryService.uploadImage(
            thumbnailImage.value!,
            folder: 'items/${user.uid}',
            filename:
                '${DateTime.now().millisecondsSinceEpoch}_thumbnail${path.extension(thumbnailImage.value!.path)}',
          );
          allImageUrls.add(thumbnailUrl);
        } catch (e) {
          print('Error uploading thumbnail: $e');
          throw e;
        }
      }

      for (var image in carouselImages) {
        try {
          final imageUrl = await CloudinaryService.uploadImage(
            image,
            folder: 'items/${user.uid}',
            filename:
                '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}',
          );
          allImageUrls.add(imageUrl);
        } catch (e) {
          print('Error uploading carousel image: $e');
          throw e;
        }
      }

      if (locationController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter location',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final itemData = {
        'name': nameController.text.trim(),
        'category': selectedValue.value,
        'starting_price': int.tryParse(priceController.text.trim()) ?? 0,
        'current_price': int.tryParse(priceController.text.trim()) ?? 0,
        'lokasi': locationController.text.trim(),
        'description': descriptionController.text.trim(),
        'imageURL': allImageUrls,
        'seller_id': user.uid,
        'winner_id': '',
        'bid_count': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'tanggal': Timestamp.fromDate(selectedDate.value),
        'jamMulai': startTimeController.text.trim(),
        'jamSelesai': endTimeController.text.trim(),
        'status': 'upcoming',
        'rarity': selectedRarity.value,
      };

      print('Debug - Saving item data: $itemData');
      await FirebaseFirestore.instance.collection('items').add(itemData);

      Get.snackbar(
        'Success',
        'Item added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _clearForm();

      final homeController = Get.find<HomeController>();
      homeController.selectedPage.value = 0;
      Get.offAllNamed('/home');
    } catch (e) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 50,
                ),
                SizedBox(height: 16),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Failed to add item: ${e.toString()}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(double.infinity, 45),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool validateForm() {
    List<String> errors = [];

    if (nameController.text.trim().isEmpty) {
      errors.add('Item name is required');
    }
    if (selectedValue.value.isEmpty) {
      errors.add('Category is required');
    }
    if (priceController.text.trim().isEmpty) {
      errors.add('Starting price is required');
    } else {
      try {
        int price = int.parse(priceController.text.trim());
        if (price <= 0) {
          errors.add('Price must be greater than 0');
        }
      } catch (e) {
        errors.add('Price must be a valid number');
      }
    }
    if (selectedRarity.value.isEmpty) {
      errors.add('Rarity is required');
    }
    if (thumbnailImage.value == null) {
      errors.add('Thumbnail image is required');
    }
    if (carouselImages.isEmpty) {
      errors.add('At least one gallery image is required');
    }
    if (locationController.text.trim().isEmpty) {
      errors.add('Location is required');
    }
    if (descriptionController.text.trim().isEmpty) {
      errors.add('Description is required');
    }

    if (selectedStartTime.value != '00:00' &&
        selectedEndTime.value != '23:59') {
      final startParts = selectedStartTime.value.split(':');
      final endParts = selectedEndTime.value.split(':');

      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      final start = TimeOfDay(hour: startHour, minute: startMinute);
      final end = TimeOfDay(hour: endHour, minute: endMinute);

      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;

      if (startMinutes >= endMinutes) {
        errors.add('End time must be after start time');
      }
    }

    if (errors.isNotEmpty) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 50,
                ),
                SizedBox(height: 16),
                Text(
                  'Required Fields Missing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: errors
                      .map((error) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(double.infinity, 45),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return false;
    }

    return true;
  }

  void _clearForm() {
    nameController.clear();
    priceController.clear();
    locationController.clear();
    descriptionController.clear();
    dateController.clear();
    startTimeController.clear();
    endTimeController.clear();
    selectedValue.value = '';
    images.clear();
    selectedRarity.value = '';
    thumbnailImage.value = null;
    carouselImages.clear();
  }

  void updateCharacterCount(String value) {
    characterCount.value = value.length;
    if (value.length > 400) {
      descriptionController.text = value.substring(0, 400);
      characterCount.value = 400;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadProvinces();

    priceController.addListener(() {
      final text = priceController.text;
      if (text.isNotEmpty) {
        onPriceChanged(text);
      }
    });

    descriptionController.addListener(() {
      updateCharacterCount(descriptionController.text);
    });

    dateController.text = formatDate(DateTime.now());

    selectedDateStr.value = formatDate(DateTime.now());

    ever(selectedProvince, (Province? province) {
      if (province != null) {
        print('Selected province: ${province.name}');
        loadCities(province.id);
      }
    });
  }

  Future<void> loadProvinces() async {
    try {
      isLoadingProvinces.value = true;
      final loadedProvinces = await LocationService.getProvinces();
      if (loadedProvinces.isEmpty) {
        Get.snackbar(
          'Error',
          'Failed to load provinces. Please check your internet connection.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      provinces.value = loadedProvinces;
    } catch (e) {
      print('Error loading provinces: $e');
      Get.snackbar(
        'Error',
        'An error occurred while loading provinces',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingProvinces.value = false;
    }
  }

  Future<void> loadCities(String provinceId) async {
    try {
      isLoadingCities.value = true;
      cities.value = LocationService.getCities(provinceId, provinces);
      if (cities.isEmpty) {
        print('No cities found for province ID: $provinceId');
      }
    } catch (e) {
      print('Error loading cities: $e');
      Get.snackbar(
        'Error',
        'Failed to load cities',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingCities.value = false;
    }
  }

  void onProvinceChanged(Province? province) {
    selectedProvince.value = province;
    selectedCity.value = null;
    cities.clear();

    if (province != null) {
      cities.value = LocationService.getCities(province.id, provinces);
    }
  }

  void onCityChanged(City? city) {
    selectedCity.value = city;
    if (city != null) {
      locationController.text =
          '${LocationService.formatName(city.name)}, ${LocationService.formatName(selectedProvince.value?.name ?? "")}';
    }
  }

  Future<void> retryLoadingLocations() async {
    await loadProvinces();
  }

  String get formattedDate =>
      dateController.text.isEmpty ? 'Select Date' : dateController.text;

  String get formattedStartTime =>
      startTimeController.text.isEmpty ? 'Set Time' : startTimeController.text;

  String get formattedEndTime =>
      endTimeController.text.isEmpty ? 'Set Time' : endTimeController.text;

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    selectedProvince.value = null;
    selectedCity.value = null;
    cities.clear();
    priceFocus.dispose();
    super.onClose();
  }

  void onPriceChanged(String value) {
    if (value.isEmpty) {
      return;
    }

    if (value == priceController.text) {
      return;
    }

    // Remove any non-digit characters
    String numericOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    priceController.value = TextEditingValue(
      text: numericOnly,
      selection: TextSelection.fromPosition(
        TextPosition(offset: numericOnly.length),
      ),
    );
  }

  void resetLocationData() {
    selectedProvince.value = null;
    selectedCity.value = null;
    cities.clear();
    locationController.clear();
  }
}
