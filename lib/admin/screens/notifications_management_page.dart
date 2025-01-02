import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/admin/controllers/notifications_management_controller.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/driver/public/controllers/driver_notifications_controller.dart';

class NotificationsManagementPage extends StatelessWidget {
  final NotificationsManagementController _controller =
      Get.put(NotificationsManagementController());

  NotificationsManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'إدارة الإشعارات',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: systemColors.primary,
        leading: Container(
          margin: EdgeInsets.all(5),
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
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => _showCreateNotificationBottomSheet(context),
          ),
        ],
      ),
      body: Obx(() => _buildNotificationsList()),
    );
  }

  Widget _buildNotificationsList() {
    return _controller.notifications.isEmpty
        ? _buildEmptyStateWidget()
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = _controller.notifications[index];
              return _buildNotificationCard(notification);
            },
          );
  }

  Widget _buildNotificationCard(AdminNotification notification) {
    Color typeColor = _getNotificationTypeColor(notification.type);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _showNotificationDetailsBottomSheet(notification),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: typeColor.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Icon(
                      _getNotificationTypeIcon(notification.type),
                      color: typeColor,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getTargetText(notification.target),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
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
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_off,
              size: 80,
              color: systemColors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: systemColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 10),
          Text(
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

  void _showCreateNotificationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'إنشاء إشعار جديد',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: systemColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _controller.titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان الإشعار',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _controller.messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'محتوى الإشعار',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Obx(() => _controller.selectedTarget.value ==
                        NotificationTarget.specific
                    ? TextField(
                        controller: _controller.spacificTargetPhoneController,
                        decoration: InputDecoration(
                          labelText: 'مستهدف محدد',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      )
                    : Container()),
                SizedBox(height: 16),
                Text(
                  'نوع الإشعار',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Obx(() => Wrap(
                      spacing: 10,
                      children: NotificationType.values.map((type) {
                        return ChoiceChip(
                          label: Text(_getNotificationTypeText(type)),
                          selected: _controller.selectedType.value == type,
                          onSelected: (selected) {
                            if (selected) {
                              _controller.selectedType.value = type;
                            }
                          },
                          selectedColor: _getNotificationTypeColor(type)
                              .withValues(alpha: 0.2),
                        );
                      }).toList(),
                    )),
                SizedBox(height: 16),
                Text(
                  'المستهدفون',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Obx(() => Wrap(
                      spacing: 10,
                      children: NotificationTarget.values.map((target) {
                        return ChoiceChip(
                          label: Text(_getTargetText(target)),
                          selected: _controller.selectedTarget.value == target,
                          onSelected: (selected) {
                            if (selected) {
                              _controller.selectedTarget.value = target;
                            }
                          },
                        );
                      }).toList(),
                    )),
                Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _controller.createNotification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: systemColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          'إرسال الإشعار',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationDetailsBottomSheet(AdminNotification notification) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      _getNotificationTypeIcon(notification.type),
                      color: _getNotificationTypeColor(notification.type),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _getNotificationTypeText(notification.type),
                      style: TextStyle(
                        color: _getNotificationTypeColor(notification.type),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.group, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(_getTargetText(notification.target)),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _controller.deleteNotification(notification.id);
                        Get.back();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  Color _getNotificationTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.trip:
        return Colors.orange;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.system:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.trip:
        return Icons.directions_car_rounded;
      case NotificationType.payment:
        return Icons.payment_rounded;
      case NotificationType.system:
        return Icons.settings_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _getNotificationTypeText(NotificationType type) {
    switch (type) {
      case NotificationType.trip:
        return 'رحلة';
      case NotificationType.payment:
        return 'دفعة';
      case NotificationType.system:
        return 'نظام';
      default:
        return 'عام';
    }
  }

  String _getTargetText(NotificationTarget target) {
    switch (target) {
      case NotificationTarget.customers:
        return 'الزبائن';
      case NotificationTarget.drivers:
        return 'السائقين';
      case NotificationTarget.specific:
        return 'مستهدف محدد';
      default:
        return 'الكل';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else {
      return '${difference.inDays} يوم مضى';
    }
  }
}
