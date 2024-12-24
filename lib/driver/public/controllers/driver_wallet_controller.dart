import 'package:get/get.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
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

      print(response.toString());

      if (response != null && response['data'] != null) {
        balance.value = (response['data']['balance'] ?? 0.0).toDouble();

        final transactionsList =
            response['data']['transactions'] as List? ?? [];
        recentTransactions.value = transactionsList
            .map((transactionData) => Transaction.fromJson(transactionData))
            .toList();
      }
    } catch (e) {
      print('Error fetching wallet details: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب تفاصيل المحفظة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void withdrawFunds() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/driver/withdraw',
        method: 'POST',
        body: {
          'amount': balance.value,
        },
      );

      if (response != null && response['success'] == true) {
        Get.snackbar(
          'نجاح',
          'تمت عملية السحب بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
        fetchWalletDetails();
      } else {
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'حدث خطأ أثناء سحب الأموال',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error withdrawing funds: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء محاولة سحب الأموال',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void viewAllTransactions() {
    // TODO: Implement full transactions view
    Get.to(() => AllTransactionsPage());
  }
}
