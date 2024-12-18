import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ProfileController extends GetxController {
  //TODO: Implement ProfileController

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

  bool verify = false;

  var profile = Rx<File?>(null);

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      profile.value = File(pickedFile.path);
    }
  }

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  var countryCode = 'indonesia'.obs;
  final Map<String, String> countryFlags = {
    'us': 'united-states',
    'id': 'indonesia',
    'gb': 'united-kingdom',
    'fr': 'france',
    'jp': 'japan',
    'dz': 'algeria', // Tambahkan Algeria
    // Tambahkan negara lainnya jika diperlukan
  };
  // Update kode negara berdasarkan input
  void updateCountryCode(String phoneNumber) async {
    try {
      final parsedNumber =
          await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber);
      final isoCode = parsedNumber.isoCode?.toLowerCase();
      print("ISO Code: $isoCode"); // Debugging
      countryCode.value =
          countryFlags[isoCode] ?? 'indonesia'; // Default jika tidak ditemukan
      print("Updated Country Code: ${countryCode.value}"); // Debugging
    } catch (e) {
      countryCode.value = 'indonesia'; // Default jika parsing gagal
      print("Error parsing phone number: $e");
    }
  }
}
