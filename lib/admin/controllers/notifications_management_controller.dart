import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/driver/public/controllers/driver_notifications_controller.dart';

enum NotificationTarget { all, customers, drivers, specific }

class AdminNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationTarget target;
  final String? specificTargetPhone;
  final DateTime createdAt;

  AdminNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = NotificationType.message,
    this.target = NotificationTarget.all,
    this.specificTargetPhone,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'] ?? json["_id"],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => NotificationType.system),
      target: NotificationTarget.values.firstWhere(
          (e) => e.toString().split('.').last == json['target'],
          orElse: () => NotificationTarget.all),
      specificTargetPhone: json['specificTargetPhone'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class NotificationsManagementController extends GetxController {
  final RxList<AdminNotification> _notifications = <AdminNotification>[].obs;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController spacificTargetPhoneController =
      TextEditingController();

  RxList<AdminNotification> get notifications => _notifications;

  // Observables for form selection
  Rx<NotificationType> selectedType = NotificationType.message.obs;
  Rx<NotificationTarget> selectedTarget = NotificationTarget.all.obs;
  RxString specificTargetId = ''.obs;

  void createNotification() {
    if (titleController.text.isEmpty || messageController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال العنوان والرسالة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final newNotification = AdminNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      body: messageController.text,
      type: selectedType.value,
      target: selectedTarget.value,
      specificTargetPhone: selectedTarget.value == NotificationTarget.specific
          ? spacificTargetPhoneController.text
          : null,
    );

    _notifications.insert(0, newNotification);
    _sendNotification(newNotification);

    // Clear form
    titleController.clear();
    messageController.clear();
    selectedType.value = NotificationType.message;
    selectedTarget.value = NotificationTarget.all;
    specificTargetId.value = '';

    Get.back(); // Close bottom sheet
    Get.snackbar(
      'نجاح',
      'تم إرسال الإشعار بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _sendNotification(AdminNotification notification) async {
    final data = {
      "title": notification.title,
      "body": notification.body,
      "type": notification.type.toString().split('.').last,
      "target": notification.target.toString().split('.').last,
      "phone": notification.target == NotificationTarget.specific
          ? notification.specificTargetPhone
          : null,
    };
    final response = await sendRequestWithHandler(
      endpoint: '/admin/notifications',
      method: 'POST',
      body: data,
      loadingMessage: "جاري التحميل",
    );
    if (response != null) {}
    if (response["status"] == "success") {
      Get.snackbar(
        'نجاح',
        'تم إرسال الإشعار بنجاح',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((notification) => notification.id == id);
  }

  @override
  onReady() {
    fetchNotifications();
    super.onReady();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/admin/notifications',
        method: 'GET',
        loadingMessage: "جاري التحميل",
      );

      print(response.toString());

      if (response != null &&
          response['data'] != null &&
          response["data"]["notifications"] != null) {
        final notificationsList =
            response['data']["notifications"] as List? ?? [];
        notifications.value = notificationsList
            .map((notificationData) =>
                AdminNotification.fromJson(notificationData))
            .toList();
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      Get.snackbar(
        'خطاء',
        'حدث خطاء أثناء جلب الإشعارات',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    messageController.dispose();
    spacificTargetPhoneController.dispose();
    super.onClose();
  }
}
