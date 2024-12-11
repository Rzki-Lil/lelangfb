import 'package:flutter/material.dart';

import 'package:get/get.dart';

class Add3View extends GetView {
  const Add3View({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add3View'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Add3View is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
