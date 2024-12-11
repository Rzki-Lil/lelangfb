import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/addItem/controllers/add_item_controller.dart';
import 'package:lelang_fb/core/constants/color.dart';

import '../../../utils/buttons.dart';
import '../../../utils/custom_text_field.dart';
import '../../../utils/text.dart';
import 'add3_view.dart';

class Add2View extends GetView {
  const Add2View({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddItemController());
    final auctionObjek = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add2View'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              height: 200,
              child: Obx(() {
                if (controller.images.isNotEmpty) {
                  return Stack(
                    children: [
                      CarouselSlider.builder(
                        carouselController: controller.carouselController,
                        itemCount: controller.images.length,
                        itemBuilder: (context, index, realIndex) {
                          return Image.file(
                            controller.images[index],
                            width: double.infinity,
                            fit: BoxFit.contain,
                          );
                        },
                        options: CarouselOptions(
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) =>
                              controller.currentPage.value = index,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: IconC(onPressed: () async {
                          await controller.getImagesFromGallery();
                          controller.onImageAdded();
                        }),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => controller
                              .removeImage(controller.currentPage.value),
                          icon: Icon(
                            Icons.delete,
                            color: AppColors.hijauMuda,
                          ),
                        ),
                      ),
                      if (controller.images.length > 1)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Row(
                            children:
                                List.generate(controller.images.length, (i) {
                              return GestureDetector(
                                onTap: () {
                                  controller.carouselController
                                      .animateToPage(i);
                                },
                                child: Container(
                                  width: 24,
                                  height: 12,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: controller.currentPage.value == i
                                        ? AppColors.hijauMuda
                                        : Colors.grey.withOpacity(0.4),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  );
                } else {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[350],
                    ),
                    child: IconC(
                      onPressed: controller.getImagesFromGallery,
                    ),
                  );
                }
              }),
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: auctionObjek,
              labelText: 'Schdule',
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 20),
            CustomTextField(controller: auctionObjek, labelText: 'Clock'),
            SizedBox(height: 20),
            CustomTextField(controller: auctionObjek, labelText: 'Location'),
            SizedBox(height: 20),
            Button.filled(
              onPressed: () {
                Get.to(Add3View());
              },
              label: 'Continue',
              color: AppColors.hijauTua,
            )
          ],
        ),
      ),
    );
  }
}
