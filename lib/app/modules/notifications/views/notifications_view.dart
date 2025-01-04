import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/header.dart';
import '../../../../core/constants/color.dart';
import '../controllers/notifications_controller.dart';
import 'package:intl/intl.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationsController());
    return Scaffold(
      appBar: Header(
        title: 'Notifications',
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.hijauTua),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            final isRead = notification['read'] ?? false;

            return InkWell(
              onTap: () => controller.markAsRead(notification['id']),
              child: Container(
                color: isRead ? Colors.white : Colors.grey[50],
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.hijauTua.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification['type']),
                      color: AppColors.hijauTua,
                    ),
                  ),
                  title: Text(
                    notification['title'] ?? '',
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification['message'] ?? ''),
                      SizedBox(height: 4),
                      Text(
                        _formatDateTime(notification['timestamp']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: !isRead
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.hijauTua,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'auction_won':
        return Icons.emoji_events;
      case 'item_sold':
        return Icons.sell;
      default:
        return Icons.notifications;
    }
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = (timestamp as Timestamp).toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
