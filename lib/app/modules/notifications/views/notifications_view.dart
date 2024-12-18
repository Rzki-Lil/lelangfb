import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/profile/views/transaction_view.dart';

import '../controllers/notifications_controller.dart';

class NotifictaionsView extends GetView<NotificationsController> {
  const NotifictaionsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 70),
        child: appbarCust(title: "Notifications"),
      ),
      body: Center(
        child: Text(
          'Notifictaions',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
