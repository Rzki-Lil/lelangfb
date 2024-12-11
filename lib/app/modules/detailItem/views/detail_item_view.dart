import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:lelang_fb/app/utils/text.dart';
import 'package:lelang_fb/core/constants/color.dart';

import '../../../../core/assets/assets.gen.dart';
import '../controllers/detail_item_controller.dart';

class DetailItemView extends GetView<DetailItemController> {
  const DetailItemView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> item = Get.arguments;
    final List<String> images = item['imageURL'];
    final CarouselSliderController carouselController =
        CarouselSliderController();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, right: 10, left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      initialPage: 0,
                      viewportFraction: 1,
                      enableInfiniteScroll: true,
                      onPageChanged: (index, reason) {
                        controller.currentPage.value = index;
                      },
                    ),
                    carouselController: carouselController,
                    itemCount: images.length,
                    itemBuilder: (context, index, realIndex) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              width: double.infinity,
                              images[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Obx(() {
                    return Positioned(
                      right: 0,
                      bottom: 0,
                      child: Row(
                        children: List.generate(images.length, (i) {
                          return GestureDetector(
                            onTap: () {
                              carouselController.animateToPage(
                                  i); // Navigate to specific page
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
                                    : AppColors.white,
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextCust(
                    fontSize: 30,
                    color: AppColors.black,
                    text: item['judul'],
                    fontWeight: FontWeight.bold,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColors.grey,
                    ),
                    width: 40,
                    height: 40,
                    child: Obx(
                      () {
                        return IconButton(
                          onPressed: () {
                            controller.isClicked.value =
                                !controller.isClicked.value;
                          },
                          icon: Icon(
                            controller.isClicked.value
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                            color: controller.isClicked.value
                                ? Colors.green
                                : Colors.white,
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
              TextCust(
                fontSize: 12,
                color: AppColors.grey,
                text: "First price",
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextCust(
                    fontSize: 24,
                    color: AppColors.hijauMuda,
                    text: item['harga'],
                    fontWeight: FontWeight.bold,
                  ),
                  Container(
                    width: 65,
                    height: 25,
                    decoration: BoxDecoration(
                      color: AppColors.biru,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: TextCust(
                          fontSize: 12,
                          color: AppColors.white,
                          text: "GRADE " + item['grade']),
                    ),
                  )
                ],
              ),
              SizedBox(height: 5),
              TextCust(
                fontSize: 16,
                color: AppColors.black,
                text: "Schedule   : " +
                    item['tanggal'] +
                    " " +
                    item['bulan'] +
                    " " +
                    item['tahun'],
              ),
              TextCust(
                fontSize: 16,
                color: AppColors.black,
                text: "Location    : " + item['lokasi'],
              ),
              SizedBox(height: 10),
              Card(
                margin: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                elevation: 0,
                color: const Color.fromARGB(32, 70, 64, 64),
                child: SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 10, left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextCust(
                          fontSize: 14,
                          text: "Item Details",
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextImageColumn(
                                text: "Production Year\n" + item['tahunMobil'],
                                image: Assets.images.performance1.path,
                                width: 50,
                                height: 50),
                            TextImageColumn(
                              text: "Transmition\n" + item['tipe'],
                              image: Assets.images.transmission1.path,
                              width: 50,
                              height: 50,
                            ),
                            TextImageColumn(
                                text: "Machine Capacity\n" + item['mesinCC'],
                                image: Assets.images.mesin.path,
                                width: 50,
                                height: 50),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextImageColumn(
                                text: "Kilometer          \n" +
                                    item['tahunMobil'],
                                image: Assets.images.kilometer.path,
                                width: 50,
                                height: 50),
                            TextImageColumn(
                              text: "Fuel\n" + item['tipe'],
                              image: Assets.images.bensin.path,
                              width: 50,
                              height: 50,
                            ),
                            TextImageColumn(
                                text: "Machine Capacity\n" + item['mesinCC'],
                                image: Assets.images.warna.path,
                                width: 50,
                                height: 50),
                          ],
                        ),
                        Divider(
                          color: Colors.white,
                          thickness: 2,
                        ),
                        Center(
                          child: TextCust(
                            text: 'Read The Full Specification',
                            fontSize: 14,
                            color: AppColors.biru,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TextImageColumn extends StatelessWidget {
  final String image;
  final String text;
  final double width;
  final double height;
  final double? fontSize;
  const TextImageColumn({
    super.key,
    required this.text,
    required this.image,
    required this.width,
    required this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Image.asset(
            image,
            width: width,
          ),
          TextCust(
              textAlign: TextAlign.center,
              text: text,
              fontSize: fontSize ?? 14),
        ],
      ),
    );
  }
}
