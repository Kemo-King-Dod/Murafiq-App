import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/driver/public/controllers/driver_notifications_controller.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

  /// A page that displays driver notifications.
  ///
  /// This page shows a list of notifications for the driver, allowing them to
  /// view details and manage them. If there are no notifications, a message
  /// indicating the absence of notifications is displayed. Notifications can be
  /// dismissed by swiping, and their read status is visually indicated.
class DriverNotificationsPage extends GetView<DriverNotificationsController> {
  const DriverNotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DriverNotificationsController>()) {
      Get.put(DriverNotificationsController());
    }
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: systemColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: systemColors.primary,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        backgroundColor: systemColors.primary,
        title: Text(
          'الإشعارات'.tr,
          style: systemTextStyle.mediumLight,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(systemColors.primary),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        systemColors.primary.withValues(alpha: 0.7),
                        systemColors.primary.withValues(alpha: 0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: systemColors.primary.withValues(alpha: 0.3),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: systemColors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'لا توجد إشعارات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: systemColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
              const  Text(
                  'سيتم إعلامك عندما تصلك أي إشعارات جديدة',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _buildNotificationTile(notification),
            );
          },
        );
      }),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    final Color baseColor = _getNotificationIconColor(notification.type);

    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        controller.deleteNotification(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              baseColor.withValues(alpha: 0.1),
              baseColor.withValues(alpha: 0.05),
              Colors.white.withValues(alpha: 0.02),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: baseColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: baseColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: _getNotificationIcon(notification.type),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight:
                  notification.isRead ? FontWeight.normal : FontWeight.bold,
              color: systemColors.dark,
              letterSpacing: 0.3,
            ),
          ),
          subtitle: Text(
            notification.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              letterSpacing: 0.2,
            ),
          ),
          trailing: Text(
            _formatNotificationTime(notification.timestamp),
            style: TextStyle(
              color: baseColor.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          onTap: () {
            controller.markNotificationAsRead(notification.id);
          },
        ),
      ),
    );
  }

  Color _getNotificationIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.trip:
        return Colors.orange.shade600;
      case NotificationType.payment:
        return Colors.green.shade600;
      case NotificationType.message:
        return Colors.blue.shade600;
      case NotificationType.system:
        return Colors.blueGrey.shade600;
      }
  }

  Icon _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.trip:
        return Icon(Icons.directions_car, color: Colors.orange.shade600);
      case NotificationType.payment:
        return Icon(Icons.payment, color: Colors.green.shade600);
      case NotificationType.message:
        return Icon(Icons.message, color: Colors.blue.shade600);
      case NotificationType.system:
        return Icon(Icons.settings, color: Colors.blueGrey.shade600);
      }
  }

  String _formatNotificationTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ساعة';
    } else {
      return '${difference.inDays} يوم';
    }
  }
}
