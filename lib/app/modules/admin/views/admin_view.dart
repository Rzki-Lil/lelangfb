import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/home/controllers/home_controller.dart';
import 'package:lelang_fb/app/utils/text.dart';
import '../../../../core/constants/color.dart';
import '../../profile/views/transaction_view.dart';
import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminController());
    final controllerHome = Get.put(HomeController());
    final carouselController = CarouselSliderController();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(90, 70),
        child: appbarCust(title: 'Admin Panel'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCust(
                  text: "Edit Promo",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 20),
                // Carousel Preview
                controllerHome.bannerPromo.isNotEmpty
                    ? Stack(
                        children: [
                          CarouselSlider.builder(
                            key: ValueKey(controllerHome.bannerPromo.length),
                            options: CarouselOptions(
                              initialPage: controllerHome.currentPage.value,
                              viewportFraction: 1,
                              enableInfiniteScroll:
                                  controllerHome.bannerPromo.length > 1,
                              onPageChanged: (index, reason) {
                                controllerHome.currentPage.value = index;
                              },
                            ),
                            carouselController: carouselController,
                            itemCount: controllerHome.bannerPromo.length,
                            itemBuilder: (context, index, realIndex) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.file(
                                      File(controllerHome.bannerPromo[index]),
                                      fit: BoxFit.fill,
                                      width: double.infinity,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Row(
                              children: List.generate(
                                  controllerHome.bannerPromo.length, (i) {
                                return GestureDetector(
                                  onTap: () {
                                    carouselController.animateToPage(i);
                                    controllerHome.currentPage.value = i;
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 12,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          controllerHome.currentPage.value == i
                                              ? AppColors.hijauMuda
                                              : Colors.grey.withOpacity(0.4),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text("Belum ada gambar di carousel.")),

                const SizedBox(height: 20),
                // Edit Carousel Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: controller.addImage,
                      icon: const Icon(Icons.add),
                      label: const Text("Tambah Gambar"),
                    ),
                    ElevatedButton.icon(
                      onPressed: controller.removeImage,
                      icon: const Icon(Icons.delete),
                      label: const Text("Hapus Gambar"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: controller.editImage,
                  icon: const Icon(Icons.edit),
                  label: const Text("Ubah Gambar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
