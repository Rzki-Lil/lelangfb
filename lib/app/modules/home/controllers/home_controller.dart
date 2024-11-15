import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lelang_fb/core/assets/assets.gen.dart';

class HomeController extends GetxController with SingleGetTickerProviderMixin {
  //TODO: Implement HomeController

  final count = 0.obs;

  @override
  void onReady() {
    super.onReady();
  }

  void increment() => count.value++;
  final double width = 70;
  List<Widget> get menuItems {
    return [
      Column(
        children: [
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(Assets.logo.logoMobil.path),
          ),
          SizedBox(height: 8),
          Text(
            "Car",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
      Column(
        children: [
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(Assets.logo.logoMotor.path),
          ),
          SizedBox(height: 8),
          Text(
            "Motorcycle",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
      Column(
        children: [
          Container(
              width: width,
              height: width,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(Assets.logo.logoLifestyle.path)),
          SizedBox(height: 8),
          Text(
            "Lifestyle",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
      Column(
        children: [
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(Assets.logo.logoAuction.path),
          ),
          SizedBox(height: 8),
          Text(
            "Auction",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    ];
  }

  final pageController = PageController(initialPage: 0);
  var currentPage = 0.obs;
  Timer? _timer;

  final List<Widget> container = [
    Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 255, 76),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Center(
          child: Text("PROMOOO"),
        ),
      ),
    ),
    Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 255, 76),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text("GILA"),
      ),
    ),
    Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 255, 76),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text("hahah"),
      ),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _startAutoSlide();
    tabController = TabController(length: 3, vsync: this);
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (currentPage.value < container.length - 1) {
        currentPage.value++;
        pageController.animateToPage(
          currentPage.value,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        currentPage.value = 0;
        pageController.jumpToPage(0);
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    tabController.dispose();

    super.onClose();
  }

  late TabController tabController;
  final List<Map<String, String>> carEvents = [
    {
      "date": "17",
      "month": "November",
      "time": "14:00 WIB",
      "location": "BOGOR",
      "imageURL": "assets/logo/mobil.png"
    },
    {
      "date": "17",
      "month": "November",
      "time": "14:00 WIB",
      "location": "CIANJUR",
      "imageURL": "assets/logo/mobil.png"
    },
    {
      "date": "20",
      "month": "November",
      "time": "12:00 WIB",
      "location": "JAKARTA",
      "imageURL": "assets/logo/mobil.png"
    },
    {
      "date": "23",
      "month": "November",
      "time": "12:00 WIB",
      "location": "JAKARTA",
      "imageURL": "assets/logo/mobil.png"
    },
  ];
  final List<Map<String, String>> motorEvents = [
    {
      "date": "17",
      "month": "November",
      "time": "14:00 WIB",
      "location": "BOGOR",
      "imageURL": "assets/logo/logo_motor.png"
    },
    {
      "date": "17",
      "month": "November",
      "time": "14:00 WIB",
      "location": "CIANJUR",
      "imageURL": "assets/logo/logo_motor.png"
    },
    {
      "date": "20",
      "month": "November",
      "time": "12:00 WIB",
      "location": "JAKARTA",
      "imageURL": "assets/logo/logo_motor.png"
    },
    {
      "date": "23",
      "month": "November",
      "time": "12:00 WIB",
      "location": "JAKARTA",
      "imageURL": "assets/logo/logo_motor.png"
    },
  ];
  final List<Map<String, String>> lifestyeEvents = [
    {
      "date": "17",
      "month": "November",
      "time": "14:00 WIB",
      "location": "BOGOR",
      "imageURL": "assets/logo/logo_lifestyle.png"
    },
    {
      "date": "17",
      "month": "November",
      "time": "14:00 WIB",
      "location": "CIANJUR",
      "imageURL": "assets/logo/logo_lifestyle.png"
    },
    {
      "date": "20",
      "month": "November",
      "time": "12:00 WIB",
      "location": "JAKARTA",
      "imageURL": "assets/logo/logo_lifestyle.png"
    },
    {
      "date": "23",
      "month": "November",
      "time": "12:00 WIB",
      "location": "JAKARTA",
      "imageURL": "assets/logo/logo_lifestyle.png"
    },
  ];
}
