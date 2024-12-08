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
  String method = 'GET',
  Map<String, dynamic>? body,
  Map<String, dynamic>? queryParameters,
  String? loadingMessage,
}) async {
  return await errorHandler<dynamic>(
    operation: () => ApiService().sendRequest(
      endpoint: endpoint,
      method: method,
      body: body,
      queryParameters: queryParameters,
    ),
    loadingMessage: loadingMessage,
  );
}