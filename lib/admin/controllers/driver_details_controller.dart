import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/driver.dart';

class DriverDetailsController extends GetxController {
  DriverDetailsController({
    required this.driver,
  });

  final Driver driver;
  final RxBool isLoading = false.obs;

  Future<void> updateDriverStatus(DriverStatus newStatus) async {
    try {
      isLoading.value = true;
      final response = await sendRequestWithHandler(
        endpoint: '/admin/update_driver_status',
        method: 'PATCH',
        body: {
          'driverId': driver.id,
          'status': newStatus.toString().split('.').last,
        },
      );

      if (response != null && response['status'] == 'success') {
        driver.status = newStatus;
        update();
        Get.snackbar(
          'نجاح',
          'تم تحديث حالة السائق بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء تحديث حالة السائق',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      textConfirm: 'تأكيد',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      cancelTextColor: systemColors.primary,
      onConfirm: () {
        Get.back(); // Close dialog
        onConfirm();
      },
    );
  }
}
