import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/profile/views/transaction_view.dart';
import 'package:lelang_fb/app/services/location_service.dart';
import 'package:lelang_fb/app/utils/custom_text_field.dart';
import 'package:lelang_fb/app/utils/text.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:lelang_fb/app/utils/buttons.dart';
import '../../../widgets/header.dart';
import '../../../../core/assets/assets.gen.dart';
import '../controllers/profile_controller.dart';

class ProfileSettingView extends GetView<ProfileController> {
  const ProfileSettingView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: Header(
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile Settings',
              style: TextStyle(
                color: AppColors.hijauTua,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.insert_photo,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Row(
                  children: [
                    Obx(
                      () => Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: controller.profile.value != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.file(
                                      controller.profile.value!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : controller.profileUrl.value.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.network(
                                          controller.profileUrl.value,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            Assets.icons.profile.path,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      )
                                    : Image.asset(
                                        Assets.icons.profile.path,
                                        fit: BoxFit.contain,
                                      ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.green,
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  if (!controller.isLoading.value) {
                                    await controller.pickImage();
                                  }
                                },
                                icon: Obx(
                                  () => controller.isLoading.value
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => TextCust(
                              text: controller.displayName.value,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                        Row(
                          children: [
                            Obx(() => TextCust(
                                  text:
                                      "${controller.profileCompleteness.value.toStringAsFixed(0)}% ",
                                  fontSize: 16,
                                  color: controller.profileCompleteness.value ==
                                          100
                                      ? AppColors.hijauTua
                                      : AppColors.kuning,
                                )),
                            TextCust(
                              text: "Profile Completeness",
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                        TextCust(
                            text: controller.profileStatusMessage.value,
                            fontSize: 12),
                      ],
                    )
                  ],
                ),
              ),
              Text(
                'Detailed Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: controller.name,
                labelText: 'Name',
                textColor: Colors.black,
                prefixIcon: Icon(
                  Icons.person_outlined,
                  size: 34,
                ),
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: controller.email,
                labelText: 'Email',
                textColor: Colors.black,
                prefixIcon: Icon(
                  Icons.email_outlined,
                  size: 34,
                ),
              ),
              SizedBox(height: 15),
              Obx(
                () => TextFormField(
                  controller: controller.phone,
                  onChanged: (value) => controller.updateCountryCode(value),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(color: AppColors.hijauTua),
                    hintText: '+62812312322',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                          left: 2, top: 6, bottom: 2, right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.grey[100],
                          child: Image.asset(
                            'assets/flags/${controller.countryCode.value}.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Button.filled(
                onPressed: () => controller.updateUserProfile(),
                label: 'Save',
                fontSize: 20,
                color: AppColors.hijauTua,
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Addresses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAddressDialog(context),
                    icon: Icon(Icons.add_location_alt,
                        color: Colors.white, size: 20),
                    label:
                        Text('Add New', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.hijauTua,
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Obx(() => Column(
                    children: controller.addresses.map((address) {
                      bool isDefault = address['isDefault'] ?? false;
                      return GestureDetector(
                        onTap: () =>
                            controller.setDefaultAddress(address['id']),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDefault
                                  ? AppColors.hijauTua
                                  : Colors.grey.shade200,
                              width: isDefault ? 2 : 1,
                            ),
                            color: isDefault
                                ? AppColors.hijauTua.withOpacity(0.05)
                                : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                address['address'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isDefault
                                                      ? AppColors.hijauTua
                                                      : Colors.black87,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '${address['city']}, ${address['province']}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                '${address['postalCode']}',
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
                                  ],
                                ),
                              ),
                              if (isDefault)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.hijauTua,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Main Address',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          controller.editAddress(address),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red[400],
                                        size: 20,
                                      ),
                                      onPressed: () => controller
                                          .deleteAddress(address['id']),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
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
                  'Add New Address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // Province
                DropdownSearch<Province>(
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'Search province...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  items: controller.provinces,
                  selectedItem: controller.selectedProvince.value,
                  onChanged: controller.onProvinceChanged,
                  itemAsString: (Province? p) => p?.name ?? '',
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Province',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // City
                Obx(() => DropdownSearch<City>(
                      enabled: controller.selectedProvince.value != null &&
                          !controller.isLoadingCities.value,
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Search city...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      items: controller.cities,
                      selectedItem: controller.selectedCity.value,
                      onChanged: controller.onCityChanged,
                      itemAsString: (City? c) => c?.name ?? '',
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: controller.isLoadingCities.value
                              ? 'Loading cities...'
                              : 'City',
                          border: OutlineInputBorder(),
                          suffixIcon: controller.isLoadingCities.value
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    )),
                SizedBox(height: 15),

                CustomTextField(
                  controller: controller.postalCodeController,
                  labelText: 'Postal Code',
                  textColor: Colors.black,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 15),

                CustomTextField(
                  controller: controller.addressController,
                  labelText: 'Detailed Address',
                  textColor: Colors.black,
                  maxLines: 3,
                ),
                SizedBox(height: 15),

                Row(
                  children: [
                    Obx(() => Checkbox(
                          value: controller.isDefaultAddress.value,
                          onChanged: (value) =>
                              controller.isDefaultAddress.value = value!,
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
                      onPressed: () => Get.back(),
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: controller.addAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.hijauTua,
                        padding: EdgeInsets.symmetric(horizontal: 30),
                      ),
                      child: Text('Save Address',
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
}
