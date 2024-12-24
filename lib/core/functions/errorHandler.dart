import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/functions/classes/loading_controller.dart';
import 'package:murafiq/core/functions/system_dio.dart';
import 'package:murafiq/core/utils/systemVarible.dart'; // تأكد من وجود هذا الملف لديك

Future<T?> errorHandler<T>({
  required Future<T> Function() operation,
  String? loadingMessage,
}) async {
  final loadingController = Get.find<LoadingController>();

  try {
    // عرض اللودينغ إذا تم تمرير رسالة
    if (loadingMessage != null && loadingMessage.isNotEmpty) {
      loadingController.showLoading(message: loadingMessage);
    }

    // تنفيذ العملية
    final T result = await operation();

    // إخفاء اللودينغ إذا كان مفعلًا
    if (loadingMessage != null && loadingMessage.isNotEmpty) {
      loadingController.hideLoading();
    }

    return result;
  } catch (e) {
    // إخفاء اللودينغ إذا كان مفعلًا
    if (loadingMessage != null && loadingMessage.isNotEmpty) {
      loadingController.hideLoading();
    }

    // طباعة الخطأ للديباغ
    print("Error occurred: $e");

    // عرض رسالة خطأ للمستخدم
    Get.snackbar(
      'خطأ',
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: systemColors.primary,
      colorText: systemColors.white,
    );

    return null;
  }
}

Future<dynamic> sendRequestWithHandler({
  required String endpoint,
  String method = "GET",
  String? loadingMessage,
  Map<String, dynamic>? body,
  Map<String, dynamic>? queryParameters,
}) async {
  final loadingController = Get.find<LoadingController>();

  try {
    if (loadingMessage != null) {
      loadingController.showLoading(message: loadingMessage);
    }

    final response = await ApiService().sendRequest(
      endpoint: endpoint,
      method: method,
      body: body,
      queryParameters: queryParameters,
    );

    if (loadingMessage != null) {
      loadingController.hideLoading();
    }

    if (response != null) {
      return response;
    } else {
      throw FlutterError("لا توجد بيانات");
    }
  } catch (e) {
    if (loadingMessage != null) {
      loadingController.hideLoading();
    }

    // تأخير قصير قبل عرض رسالة الخطأ
    await Future.delayed(const Duration(milliseconds: 300));

    Get.snackbar(
      "خطأ",
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

    throw FlutterError(e.toString());
  }
}
