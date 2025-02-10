import 'package:get/get.dart';
import 'package:murafiq/core/functions/errorHandler.dart';

enum NotificationType {
  trip,
  payment,
  message,
  system,
}

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: _parseNotificationType(json['type']),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      isRead: json['is_read'] ?? false,
    );
  }

  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'trip':
        return NotificationType.trip;
      case 'payment':
        return NotificationType.payment;
      case 'message':
        return NotificationType.message;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
}

class DriverNotificationsController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final response = await sendRequestWithHandler(
        endpoint: '/public/notifications',
        method: 'GET',
      );

      print(response.toString());

      if (response != null &&
          response['data'] != null &&
          response["data"]["notifications"] != null) {
        final notificationsList =
            response['data']["notifications"] as List? ?? [];
        notifications.value = notificationsList
            .map((notificationData) =>
                NotificationModel.fromJson(notificationData))
            .toList();
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب الإشعارات',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void markNotificationAsRead(int notificationId) async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/driver/notifications/mark-read',
        method: 'POST',
        body: {'notification_id': notificationId},
      );

      if (response != null && response['success'] == true) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index].isRead = true;
          notifications.refresh();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  void deleteNotification(int notificationId) async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/driver/notifications/delete',
        method: 'DELETE',
        body: {'notification_id': notificationId},
      );

      if (response != null && response['success'] == true) {
        notifications.removeWhere((n) => n.id == notificationId);
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  void clearAllNotifications() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/driver/notifications/clear-all',
        method: 'DELETE',
      );

      if (response != null && response['success'] == true) {
        notifications.clear();
      }
    } catch (e) {
      print('Error clearing all notifications: $e');
    }
  }
}
