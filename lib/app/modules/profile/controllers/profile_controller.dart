import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async'; // Add this import

import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lelang_fb/app/modules/profile/controllers/phone_verification_controller.dart';
import 'package:lelang_fb/app/services/cloudinary_service.dart';
import 'package:lelang_fb/app/services/location_service.dart';
import 'package:lelang_fb/app/utils/custom_text_field.dart';
import 'package:lelang_fb/core/constants/color.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var userData = Rxn<Map<String, dynamic>>();
  var profile = Rx<File?>(null);
  var profileUrl = ''.obs;
  var displayName = ''.obs;
  var userEmail = ''.obs;
  var phoneNumber = ''.obs;

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  // For address management
  final addresses = <Map<String, dynamic>>[].obs;
  final addressController = TextEditingController();
  final provinceController = TextEditingController();
  final cityController = TextEditingController();
  final postalCodeController = TextEditingController();
  final isDefaultAddress = false.obs;

  final provinces = <Province>[].obs;
  final cities = <City>[].obs;
  final Rxn<Province> selectedProvince = Rxn<Province>();
  final Rxn<City> selectedCity = Rxn<City>();
  final RxBool isLoadingCities = false.obs;

  final RxDouble profileCompleteness = 0.0.obs;
  final Map<String, double> completenessWeights = {
    'name': 25.0,
    'email': 25.0,
    'phone': 25.0,
    'address': 25.0,
  };

  final phoneVerificationController = Get.put(PhoneVerificationController());

  final RxString profileStatusMessage = ''.obs;

  final RxBool hasShownVerificationMessage = false.obs;

  final RxBool isVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    fetchAddresses();
    loadProvinces();

    ever(displayName, (_) => calculateProfileCompleteness());
    ever(userEmail, (_) => calculateProfileCompleteness());
    ever(phoneNumber, (_) => calculateProfileCompleteness());
    ever(addresses, (_) => calculateProfileCompleteness());

    ever(selectedProvince, (Province? province) {
      if (province != null) {
        loadCities(province.id);
      } else {
        cities.clear();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    hasShownVerificationMessage.value = false;
    super.onClose();
  }

  void increment() => count.value++;

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        final docSnapshot =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (docSnapshot.exists) {
          userData.value = docSnapshot.data();
          displayName.value = userData.value?['displayName'] ?? 'No Name';
          userEmail.value = userData.value?['email'] ?? '';
          phoneNumber.value = userData.value?['phoneNumber'] ?? '';
          profileUrl.value = userData.value?['photoURL'] ?? '';

          name.text = displayName.value;
          email.text = userEmail.value;
          phone.text = phoneNumber.value;

          await fetchAddresses();

          calculateProfileCompleteness();
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserProfile() async {
    try {
      isLoading.value = true;
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // If phone number has changed, trigger verification
        if (phone.text != phoneNumber.value) {
          // Store pending updates including the new phone number
          phoneVerificationController.pendingUpdates = {
            'displayName': name.text,
            'phoneNumber': phone.text,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          // Show verification dialog and wait for result
          final verificationResult = await phoneVerificationController
              .sendVerificationCode(phone.text);
          if (!verificationResult) {
            // Reset phone number if verification fails
            phone.text = phoneNumber.value;
            return;
          }
        } else {
          // If only name changed, update directly
          final updates = {
            'displayName': name.text,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .update(updates);
          await fetchUserData();
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  final count = 0.obs;

  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        // Crop Image
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 80,
          cropStyle: CropStyle.circle,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Profile Photo',
              toolbarColor: AppColors.hijauTua,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: false,
            ),
            IOSUiSettings(
              title: 'Crop Profile Photo',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
            ),
          ],
        );

        if (croppedFile != null) {
          profile.value = File(croppedFile.path);
          // Upload to Cloudinary
          await uploadProfilePhoto();
        }
      }
    } catch (e) {
      print('Error picking/cropping image: $e');
      Get.snackbar(
        'Error',
        'Failed to process image',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> uploadProfilePhoto() async {
    if (profile.value == null) return;

    try {
      isLoading.value = true;
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        String? oldPhotoURL = profileUrl.value;

        // Upload
        final imageUrl = await CloudinaryService.uploadImage(
          profile.value!,
          folder: 'users_profile',
        );

        // Update Firestore
        await _firestore.collection('users').doc(currentUser.uid).update({
          'photoURL': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Apus profile lama
        if (oldPhotoURL.isNotEmpty) {
          try {
            String publicId = CloudinaryService.getPublicIdFromUrl(oldPhotoURL);
            await CloudinaryService.deleteImage(publicId);
          } catch (e) {
            print('Error deleting old photo: $e');
          }
        }

        profileUrl.value = imageUrl;

        Get.snackbar(
          'Success',
          'Profile photo updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error uploading profile photo: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile photo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAddresses() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('addresses')
            .get();

        addresses.value =
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    }
  }

  Future<void> addAddress() async {
    try {
      if (!_validateAddress()) {
        return;
      }

      isLoading.value = true;
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        final newAddress = {
          'address': addressController.text,
          'province': provinceController.text,
          'city': cityController.text,
          'postalCode': postalCodeController.text,
          'isDefault': isDefaultAddress.value,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // buat yang lain jadi non default
        if (isDefaultAddress.value) {
          final batch = _firestore.batch();
          final addressesSnapshot = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('addresses')
              .get();

          for (var doc in addressesSnapshot.docs) {
            batch.update(doc.reference, {'isDefault': false});
          }
          await batch.commit();
        }

        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('addresses')
            .add(newAddress);

        _clearAddressForm();
        await fetchAddresses();
        Get.back();
        Get.snackbar(
          'Success',
          'Address added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error adding address: $e');
      Get.snackbar(
        'Error',
        'Failed to add address: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('addresses')
            .doc(addressId)
            .delete();

        await fetchAddresses();
        Get.snackbar('Success', 'Address deleted successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      print('Error deleting address: $e');
      Get.snackbar('Error', 'Failed to delete address',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> loadProvinces() async {
    try {
      final loadedProvinces = await LocationService.getProvinces();
      if (loadedProvinces.isEmpty) {
        Get.snackbar(
          'Error',
          'Failed to load provinces',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }
      provinces.value = loadedProvinces;
      print('Loaded ${provinces.length} provinces'); // Debug info
    } catch (e) {
      print('Error loading provinces: $e');
      Get.snackbar(
        'Error',
        'Failed to load provinces: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  void onProvinceChanged(Province? province) {
    selectedProvince.value = province;
    selectedCity.value = null;
    provinceController.text = province?.name ?? '';

    if (province != null) {
      loadCities(province.id);
    } else {
      cities.clear();
    }
  }

  Future<void> loadCities(String provinceId) async {
    try {
      isLoadingCities.value = true;
      cities.clear();

      final loadedCities = LocationService.getCities(provinceId, provinces);
      cities.value = loadedCities;

      print(
          'Loaded ${cities.length} cities for province $provinceId'); // Debug info
    } catch (e) {
      print('Error loading cities: $e');
      Get.snackbar(
        'Error',
        'Failed to load cities',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingCities.value = false;
    }
  }

  void onCityChanged(City? city) {
    selectedCity.value = city;
    cityController.text = city?.name ?? '';

    // Debug info
    if (city != null) {
      print('Selected city: ${city.name} (${city.id})');
    }
  }

  bool _validateAddress() {
    if (addressController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter the address',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    if (provinceController.text.isEmpty) {
      Get.snackbar('Error', 'Please select a province',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    if (cityController.text.isEmpty) {
      Get.snackbar('Error', 'Please select a city',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    if (postalCodeController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter the postal code',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    return true;
  }

  void _clearAddressForm() {
    addressController.clear();
    provinceController.clear();
    cityController.clear();
    postalCodeController.clear();
    isDefaultAddress.value = false;
    selectedProvince.value = null;
    selectedCity.value = null;
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final batch = _firestore.batch();
        final addressesRef = _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('addresses');

        final allAddresses = await addressesRef.get();
        for (var doc in allAddresses.docs) {
          batch.update(doc.reference, {'isDefault': false});
        }

        batch.update(addressesRef.doc(addressId), {'isDefault': true});

        await batch.commit();
        await fetchAddresses();
        Get.snackbar(
          'Success',
          'Default address updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error setting default address: $e');
      Get.snackbar(
        'Error',
        'Failed to update default address',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void editAddress(Map<String, dynamic> address) {
    addressController.text = address['address'];
    provinceController.text = address['province'];
    cityController.text = address['city'];
    postalCodeController.text = address['postalCode'];
    isDefaultAddress.value = address['isDefault'] ?? false;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                CustomTextField(
                  controller: addressController,
                  labelText: 'Detailed Address',
                  textColor: Colors.black,
                  maxLines: 3,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  controller: provinceController,
                  labelText: 'Province',
                  textColor: Colors.black,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  controller: cityController,
                  labelText: 'City',
                  textColor: Colors.black,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  controller: postalCodeController,
                  labelText: 'Postal Code',
                  textColor: Colors.black,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Obx(() => Checkbox(
                          value: isDefaultAddress.value,
                          onChanged: (value) => isDefaultAddress.value = value!,
                          activeColor: AppColors.hijauTua,
                        )),
                    Text('Set as default address'),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _clearAddressForm();
                        Get.back();
                      },
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => updateAddress(address['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.hijauTua,
                        padding: EdgeInsets.symmetric(horizontal: 30),
                      ),
                      child: Text('Save Changes',
                          style: TextStyle(color: Colors.white)),
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

  Future<void> updateAddress(String addressId) async {
    try {
      if (!_validateAddress()) {
        return;
      }

      isLoading.value = true;
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        final updatedAddress = {
          'address': addressController.text,
          'province': provinceController.text,
          'city': cityController.text,
          'postalCode': postalCodeController.text,
          'isDefault': isDefaultAddress.value,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (isDefaultAddress.value) {
          final batch = _firestore.batch();
          final addressesSnapshot = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('addresses')
              .get();

          for (var doc in addressesSnapshot.docs) {
            if (doc.id != addressId) {
              batch.update(doc.reference, {'isDefault': false});
            }
          }
          await batch.commit();
        }

        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('addresses')
            .doc(addressId)
            .update(updatedAddress);

        _clearAddressForm();
        await fetchAddresses();
        Get.back();
        Get.snackbar(
          'Success',
          'Address updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error updating address: $e');
      Get.snackbar(
        'Error',
        'Failed to update address',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void calculateProfileCompleteness() async {
    double completeness = 0.0;

    if (displayName.value.isNotEmpty && displayName.value != 'No Name') {
      completeness += completenessWeights['name']!;
    }

    if (userEmail.value.isNotEmpty) {
      completeness += completenessWeights['email']!;
    }

    if (phoneNumber.value.isNotEmpty) {
      completeness += completenessWeights['phone']!;
    }

    if (addresses.isNotEmpty) {
      completeness += completenessWeights['address']!;
    }

    profileCompleteness.value = completeness;
    updateVerificationStatus();
  }

  void updateVerificationStatus() {
    bool complete = profileCompleteness.value == 100;
    isVerified.value = complete;

    profileStatusMessage.value = complete
        ? "Your profile is complete!"
        : "Complete your profile to make it easier\nfor you to use application";
  }

  void onPhoneNumberChanged(String value) {
    String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 12) {
      digits = digits.substring(0, 12);
    }

    phone.text = digits;
    phone.selection = TextSelection.fromPosition(
      TextPosition(offset: digits.length),
    );
  }
}
