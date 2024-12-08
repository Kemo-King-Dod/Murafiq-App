import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

class LoadingController extends GetxController {
  RxBool isLoading = false.obs;

  /// عرض نافذة اللودينغ
  void showLoading({String? message}) {
    if (!isLoading.value) {
      isLoading.value = true;
      systemUtils.loadingNotPop(message!);
    }
  }

  /// إخفاء نافذة اللودينغ
  void hideLoading() {
    if (isLoading.value) {
      isLoading.value = false;
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }
}
