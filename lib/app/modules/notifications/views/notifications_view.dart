import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
      body: Column(
        children: [
          // Add Instructions Card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Management Guide',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.hijauTua,
                  ),
                ),
                SizedBox(height: 16),
                _buildInstructionRow(
                  icon: Icons.touch_app,
                  color: Colors.blue,
                  text: "Tap notification to mark as read",
                ),
                SizedBox(height: 12),
                _buildInstructionRow(
                  icon: Icons.swipe,
                  color: Colors.red,
                  text: "Swipe left to delete notification",
                ),
              ],
            ),
          ),

          // Existing Notifications List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 64, color: Colors.grey),
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

                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.3,
                      children: [
                        SlidableAction(
                          onPressed: (context) =>
                              controller.deleteNotification(notification['id']),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: InkWell(
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
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
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
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
