import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/driver/private/supScreens/allTransactions.dart';
import 'package:murafiq/models/transaction.dart';

class DriverWalletController extends GetxController {
  final RxDouble balance = 0.0.obs;
  final RxList<Transaction> recentTransactions = <Transaction>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletDetails();
  }

  Future<void> fetchWalletDetails() async {
    try {
      isLoading.value = true;
      final response = await sendRequestWithHandler(
        endpoint: '/public/wallet',
        method: 'GET',
      );

      if (response != null && response['data'] != null) {
        balance.value = (response['data']['balance'] ?? 0.0).toDouble();

        final transactionsList =
            response['data']['transactions'] as List? ?? [];
        recentTransactions.value = transactionsList
            .map((transactionData) => Transaction.fromJson(transactionData))
            .toList();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب تفاصيل المحفظة'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void withdrawFunds() async {
    try {
      Get.snackbar(
        duration: Duration(seconds: 5),
        'نأسف'.tr,
        "سيتم اضافة سحب الاموال قريبا ان شاء الله يرجى التوجه الى مركز مرافق الخاص بمدينتك او التواصل مع المساعدة",
        colorText: systemColors.white,
        backgroundColor: systemColors.primary,
        backgroundGradient: LinearGradient(colors: [
          systemColors.primary,
          systemColors.primary.withValues(alpha: 0.9),
          systemColors.primary.withValues(alpha: 0.8),
          systemColors.primary.withValues(alpha: 0.7)
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error withdrawing funds: $e');
      Get.snackbar(
        'خطأ'.tr,
        'حدث خطأ أثناء محاولة سحب الأموال'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void viewAllTransactions() {
    // TODO: Implement full transactions view
    Get.to(() => AllTransactionsPage());
  }
}
