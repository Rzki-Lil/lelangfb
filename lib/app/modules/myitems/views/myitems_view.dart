import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/myitems_controller.dart';

class MyitemsView extends GetView<MyitemsController> {
  const MyitemsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyitemsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MyitemsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
