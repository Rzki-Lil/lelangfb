import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/assets/assets.gen.dart';

class TransactionController extends GetxController
    with SingleGetTickerProviderMixin {
  //TODO: Implement TransactionController

  final count = 0.obs;
  late TabController tabController;
  var selectedTab = 0.obs; // Menyimpan tab yang terpilih

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    // Menambahkan listener untuk mendengarkan perubahan tab
    tabController.addListener(() {
      selectedTab.value = tabController.index; // Update tab yang terpili
    });
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

  List<Ticket> tickets = [
    Ticket(
      Assets.logo.lelang.path,
      'Judul',
      'Harga',
      'Date',
      'Location',
      'On Going',
    ),
    Ticket(
      Assets.logo.lelang.path,
      'Judul',
      'Harga',
      'Date',
      'Location',
      'Success',
    ),
  ].obs;
  List<Ticket> getFilteredTickets() {
    if (selectedTab.value == 0) {
      return tickets.where((ticket) => ticket.status == 'On Going').toList();
    } else if (selectedTab.value == 1) {
      return tickets.where((ticket) => ticket.status == 'Success').toList();
    } else {
      return tickets.where((ticket) => ticket.status == 'Failed').toList();
    }
  }
}

class Ticket {
  final String gambar;
  final String name;
  final String price;
  final String date;
  final String location;
  final String status;

  Ticket(
    this.gambar,
    this.name,
    this.price,
    this.date,
    this.location,
    this.status,
  );
}
