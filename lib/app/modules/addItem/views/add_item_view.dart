import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/widgets/header.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../../core/assets/assets.gen.dart';
import '../../../services/location_service.dart';
import '../../../utils/input_decorations.dart';

import '../../../utils/buttons.dart';
import '../../../utils/custom_text_field.dart';

import '../../home/controllers/home_controller.dart';

import '../controllers/add_item_controller.dart';
import 'package:flutter/services.dart';

class AddItemView extends GetView<AddItemController> {
  const AddItemView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddItemController());

    // ever(Get.reference, (_) {
    //   if (!Get.isRegistered<AddItemController>()) {
    //     controller.resetLocationData();
    //   }
    // });

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: Header(
        title: 'Search Items',
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.hijauTua),
          onPressed: () {
            Get.back();
            final homeController = Get.find<HomeController>();
            homeController.selectedPage.value = 0;
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Your Item for Auction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: 'Got an ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  children: [
                    TextSpan(
                      text: 'Item to Auction?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' List it in just a few steps and connect with thousands of eager buyers!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  // Section 1: Basic Item Information
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor:
                            Colors.transparent, // This removes the top border
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              // This removes the dark outline
                              outline: Colors.transparent,
                            ),
                      ),
                      child: Obx(() => ExpansionTile(
                            initiallyExpanded: controller.isExpanded1.value,
                            onExpansionChanged: (expanded) =>
                                controller.isExpanded1.value = expanded,
                            title: Text('Item Information',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.hijauTua)),
                            subtitle: Text(
                                'Basic details about your auction item',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextField(
                                      controller: controller.nameController,
                                      labelText: 'Item Name',
                                    ),
                                    SizedBox(height: 16),

                                    DropdownButtonFormField<String>(
                                      value:
                                          controller.selectedValue.value.isEmpty
                                              ? null
                                              : controller.selectedValue.value,
                                      isExpanded: true,
                                      style: TextStyle(
                                        color: AppColors.hijauTua,
                                        fontSize: 14,
                                      ),
                                      decoration: CustomInputDecoration
                                          .buildInputDecoration(
                                        labelText: 'Category',
                                        icon: Icons.category,
                                        hasValue: controller
                                            .selectedValue.value.isNotEmpty,
                                      ),
                                      items: controller.categoryList
                                          .map((item) => DropdownMenuItem(
                                                value: item,
                                                child: Text(item),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        if (newValue != null) {
                                          controller.selectedValue.value =
                                              newValue;
                                        }
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    // Remove the Status Dropdown section completely

                                    // Add Rarity Dropdown
                                    DropdownButtonFormField<String>(
                                      value: controller
                                              .selectedRarity.value.isEmpty
                                          ? null
                                          : controller.selectedRarity.value,
                                      isExpanded: true,
                                      style: TextStyle(
                                        color: AppColors.hijauTua,
                                        fontSize: 14,
                                      ),
                                      decoration: CustomInputDecoration
                                          .buildInputDecoration(
                                        labelText: 'Rarity',
                                        icon: Icons.stars,
                                        hasValue: controller
                                            .selectedRarity.value.isNotEmpty,
                                      ),
                                      items: controller.rarityList
                                          .map((rarity) => DropdownMenuItem(
                                                value: rarity,
                                                child: Text(rarity),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        if (newValue != null) {
                                          controller.selectedRarity.value =
                                              newValue;
                                        }
                                      },
                                    ),
                                    SizedBox(height: 16),

                                    CustomTextField(
                                      controller: controller.priceController,
                                      focusNode: controller.priceFocus,
                                      labelText: 'Starting Price',
                                      keyboardType: TextInputType.number,
                                      prefix: Text(
                                        'Rp ',
                                        style: TextStyle(
                                          color: AppColors.hijauTua,
                                          fontSize: 14,
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (value) {
                                        controller.onPriceChanged(value);
                                      },
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),

                  // Section 2: Auction Schedule
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor:
                            Colors.transparent, // This removes the top border
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              // This removes the dark outline
                              outline: Colors.transparent,
                            ),
                      ),
                      child: Obx(() => ExpansionTile(
                            initiallyExpanded: controller.isExpanded2.value,
                            onExpansionChanged: (expanded) =>
                                controller.isExpanded2.value = expanded,
                            title: Text('Auction Schedule',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.hijauTua)),
                            subtitle: Text(
                                'Set your auction timeline and location',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: ListTile(
                                        leading: Icon(Icons.calendar_today,
                                            color: AppColors.hijauTua),
                                        title: Text(
                                          'Auction Date',
                                          style: TextStyle(
                                              color: AppColors.hijauTua),
                                        ),
                                        trailing: GetX<AddItemController>(
                                          builder: (controller) => Text(
                                            controller.selectedDateStr.value,
                                            style: TextStyle(
                                                color: AppColors.hijauTua,
                                                fontSize: 14),
                                          ),
                                        ),
                                        onTap: controller.showDatePicker,
                                      ),
                                    ),

                                    // Time Range Picker
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Start Time Picker
                                        Container(
                                          margin: EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                          ),
                                          child: ListTile(
                                            leading: Icon(Icons.access_time,
                                                color: AppColors.hijauTua),
                                            title: Text('Start Time',
                                                style: TextStyle(
                                                    color: AppColors.hijauTua)),
                                            trailing: Obx(() => Text(
                                                  controller
                                                      .selectedStartTime.value,
                                                  style: TextStyle(
                                                      color: controller
                                                                  .selectedStartTime
                                                                  .value ==
                                                              '00:00'
                                                          ? Colors.grey
                                                          : AppColors.hijauTua,
                                                      fontSize: 14),
                                                )),
                                            onTap: () =>
                                                controller.showTimePicker(true),
                                          ),
                                        ),

                                        // End Time Picker
                                        Container(
                                          margin: EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                          ),
                                          child: ListTile(
                                            leading: Icon(Icons.access_time,
                                                color: AppColors.hijauTua),
                                            title: Text('End Time',
                                                style: TextStyle(
                                                    color: AppColors.hijauTua)),
                                            trailing: Obx(() => Text(
                                                  controller
                                                      .selectedEndTime.value,
                                                  style: TextStyle(
                                                      color: controller
                                                                  .selectedEndTime
                                                                  .value ==
                                                              '23:59'
                                                          ? Colors.grey
                                                          : AppColors.hijauTua,
                                                      fontSize: 14),
                                                )),
                                            onTap: () => controller
                                                .showTimePicker(false),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Location Selection
                                    Container(
                                      margin: EdgeInsets.only(top: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Province Dropdown with Search
                                          DropdownSearch<Province>(
                                            popupProps: PopupProps.menu(
                                              showSearchBox: true,
                                              searchFieldProps: TextFieldProps(
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Search province...',
                                                  prefixIcon: Icon(Icons.search,
                                                      size: 20),
                                                  border: OutlineInputBorder(),
                                                  isDense:
                                                      true, // Make the search input more compact
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 8),
                                                ),
                                              ),
                                              constraints: BoxConstraints(
                                                  maxHeight:
                                                      400), // Limit popup height
                                              showSelectedItems: true,
                                              searchDelay:
                                                  Duration(milliseconds: 100),
                                              containerBuilder:
                                                  (context, popupWidget) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.1),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: popupWidget,
                                              ),
                                            ),
                                            compareFn:
                                                (Province? p1, Province? p2) =>
                                                    p1?.id ==
                                                    p2?.id, // Add this line
                                            dropdownDecoratorProps:
                                                DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                                  CustomInputDecoration
                                                      .buildDropdownSearchDecoration(
                                                labelText: 'Province',
                                                icon: Icons.location_on,
                                                hasValue: controller
                                                        .selectedProvince
                                                        .value !=
                                                    null,
                                              ),
                                            ),
                                            items: controller.provinces,
                                            selectedItem: controller
                                                .selectedProvince.value,
                                            onChanged:
                                                controller.onProvinceChanged,
                                            itemAsString: (Province? p) =>
                                                p?.name ?? '',
                                            // Add textStyle for the selected item
                                            dropdownBuilder:
                                                (context, selectedItem) {
                                              return Text(
                                                selectedItem?.name ??
                                                    'Select Province',
                                                style: TextStyle(
                                                  color: selectedItem != null
                                                      ? AppColors.hijauTua
                                                      : Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(height: 16),

                                          // City Dropdown with Search
                                          DropdownSearch<City>(
                                            enabled: controller
                                                    .selectedProvince.value !=
                                                null,
                                            popupProps: PopupProps.menu(
                                              showSearchBox: true,
                                              searchFieldProps: TextFieldProps(
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Search city/regency...',
                                                  prefixIcon: Icon(Icons.search,
                                                      size: 20),
                                                  border: OutlineInputBorder(),
                                                  isDense:
                                                      true, // Make the search input more compact
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 8),
                                                ),
                                              ),
                                              constraints: BoxConstraints(
                                                  maxHeight:
                                                      400), // Limit popup height
                                              showSelectedItems: true,
                                              searchDelay:
                                                  Duration(milliseconds: 100),
                                              emptyBuilder:
                                                  (context, searchEntry) =>
                                                      Center(
                                                child: Text(
                                                    'No cities/regencies found'),
                                              ),
                                              containerBuilder:
                                                  (context, popupWidget) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.1),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: popupWidget,
                                              ),
                                            ),
                                            compareFn: (City? c1, City? c2) =>
                                                c1?.id ==
                                                c2?.id, // Add this line
                                            dropdownDecoratorProps:
                                                DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                                  CustomInputDecoration
                                                      .buildDropdownSearchDecoration(
                                                labelText: 'City/Regency',
                                                icon: Icons.location_city,
                                                hasValue: controller
                                                        .selectedCity.value !=
                                                    null,
                                              ),
                                            ),
                                            items: controller.cities,
                                            selectedItem:
                                                controller.selectedCity.value,
                                            onChanged: controller.onCityChanged,
                                            itemAsString: (City? c) =>
                                                c?.name ?? '',

                                            dropdownBuilder:
                                                (context, selectedItem) {
                                              return Text(
                                                selectedItem?.name ??
                                                    'Select City/Regency',
                                                style: TextStyle(
                                                  color: selectedItem != null
                                                      ? AppColors.hijauTua
                                                      : Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item Images',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.hijauTua,
                          ),
                        ),
                        Column(
                          children: [
                            // Thumbnail Image
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  'This will be the main image shown on the item card',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                SizedBox(height: 16),
                                Obx(() => GestureDetector(
                                      onTap: controller.pickThumbnailImage,
                                      child: Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: controller
                                                    .thumbnailImage.value ==
                                                null
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons.add_photo_alternate,
                                                      size: 50,
                                                      color: Colors.grey),
                                                  Text('Add thumbnail',
                                                      style: TextStyle(
                                                          color: Colors.grey)),
                                                ],
                                              )
                                            : Stack(
                                                children: [
                                                  Image.file(
                                                    controller
                                                        .thumbnailImage.value!,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: IconButton(
                                                      icon: Icon(Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: controller
                                                          .removeThumbnailImage,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    )),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Gallery Images
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  'Add more images for the item gallery (up to 5 images)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                SizedBox(height: 16),
                                Obx(() => GestureDetector(
                                      onTap: controller.pickCarouselImages,
                                      child: Container(
                                        height: 120,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: controller.carouselImages.isEmpty
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons.add_photo_alternate,
                                                      size: 50,
                                                      color: Colors.grey),
                                                  Text('Add gallery images',
                                                      style: TextStyle(
                                                          color: Colors.grey)),
                                                ],
                                              )
                                            : ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: controller
                                                    .carouselImages.length,
                                                itemBuilder: (context, index) {
                                                  return Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Image.file(
                                                          controller
                                                                  .carouselImages[
                                                              index],
                                                          height: 104,
                                                          width: 104,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: IconButton(
                                                          icon: Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.red),
                                                          onPressed: () =>
                                                              controller
                                                                  .removeCarouselImage(
                                                                      index),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Item Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.hijauTua,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Provide detailed information about your item',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: 200,
                          child: CustomTextField(
                            controller: controller.descriptionController,
                            labelText: 'Description',
                            height: 200,
                            maxLines: 8,
                            maxLength: 400,
                            onChanged: controller.updateCharacterCount,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                            isPassword: false,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  Obx(() => Button.filled(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.submitItem(),
                        label: controller.isLoading.value
                            ? 'Submitting...'
                            : 'Submit Auction Item',
                        color: AppColors.hijauTua,
                        height: 54,
                        borderRadius: 8,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
