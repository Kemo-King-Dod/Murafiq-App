import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

class LoadingController extends GetxController {
  RxBool isLoading = false.obs;
  String? _currentDialogName;

  /// عرض نافذة اللودينغ
  void showLoading({String? message}) {
    if (!isLoading.value) {
      isLoading.value = true;
      _currentDialogName =
          "loading_dialog_${DateTime.now().millisecondsSinceEpoch}";

      // إغلاق أي snackbar مفتوح
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      // إغلاق أي dialog مفتوح
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.dialog(
        PopScope(
          canPop: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(20),
              backgroundColor: systemColors.white,
              content: SizedBox(
                height: 150,
                width: 150,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: SpinKitWave(
                        itemCount: 4,
                        color: systemColors.primary,
                        size: 40.0,
                        duration: const Duration(seconds: 1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      message ?? "جاري التحميل",
                      style: systemTextStyle.mediumDark,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        name: _currentDialogName,
        barrierDismissible: false,
      );
    }
  }

  /// إخفاء نافذة اللودينغ
  void hideLoading() {
    if (isLoading.value) {
      isLoading.value = false;

      // التأكد من أن الدايلوج الحالي هو دايلوج اللودينغ
      if (Get.isDialogOpen ?? false) {
        final currentDialog = Get.rawRoute?.settings.name;
        if (currentDialog == _currentDialogName) {
          Get.back();
        }
      }

      _currentDialogName = null;

      // تأخير قصير قبل السماح بعرض snackbar جديد
      Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void onClose() {
    hideLoading();
    super.onClose();
  }
}
