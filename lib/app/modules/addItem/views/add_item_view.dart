import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lelang_fb/core/constants/color.dart';

import '../../../utils/buttons.dart';
import '../../../utils/custom_text_field.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/add_item_controller.dart';
import 'add2_view.dart';

class AddItemView extends GetView<AddItemController> {
  const AddItemView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddItemController());
    final AuctionObjek = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AddView'),
        leading: IconButton(
          onPressed: () {
            final homeController = Get.find<HomeController>();
            homeController.changePage(
                0); 
          },
          icon: Icon(Icons.arrow_back),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
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
                  text: 'Got a ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'Car, Motorcycle, or Lifestyle Item',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' to sell? List it for auction in just a few steps and connect with thousands of eager buyers!',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Obx(
                () => Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: controller.selectedValue.value.isEmpty
                          ? null
                          : controller.list.first,
                      isExpanded: true,
                      hint: Text("Pilih Type Barang"),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                              color: Colors.grey), // Border saat tidak fokus
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                              color: AppColors.hijauTua), // Border saat fokus
                        ),
                      ),
                      focusColor: AppColors.hijauMuda,
                      items: controller.list
                          .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          controller.selectedValue.value = newValue;
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                        controller: AuctionObjek, labelText: 'Brand'),
                    SizedBox(height: 20),
                    CustomTextField(
                        controller: AuctionObjek, labelText: 'Title'),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: AuctionObjek,
                      labelText: 'First Price',
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: AuctionObjek,
                      labelText: 'Production Year',
                      keyboardType: TextInputType.datetime,
                    ),
                    SizedBox(height: 20),
                    Button.filled(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => Add2View(),
                        //   ),
                        // );
                        Get.to(() => Add2View());
                      },
                      label: 'Continue',
                      color: AppColors.hijauTua,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
