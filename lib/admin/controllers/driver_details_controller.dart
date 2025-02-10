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

  void discountDriverWalletfun({required double balance}) {
    final discount = TextEditingController();

    Get.dialog(AlertDialog(
      content: Container(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: 15,
          children: [
            Center(
              child: Text(
                "كم تريد السحب",
                style: systemTextStyle.largeDark,
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text(
                  "كم تريد السحب ؟",
                  style: systemTextStyle.smallDark,
                ),
              ),
              textAlign: TextAlign.center,
              controller: discount,
            ),
            ElevatedButton(
              onPressed: () {
                if (double.parse(discount.text) > balance) {
                  Get.snackbar(
                    'خطاء',
                    'لا يمكنك سحب اكثر من رصيدك',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                if (discount.text.isEmpty) {
                  Get.snackbar(
                    'خطاء',
                    'يرجى ادخال قيمة',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                if (discount.text.contains(".")) {
                  Get.snackbar(
                    'خطاء',
                    'يرجى ادخال قيمة صحيحة',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                if (double.parse(discount.text) <= 0) {
                  Get.snackbar(
                    'خطاء',
                    'يرجى ادخال قيمة صحيحة',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                discountDriverWallet(double.parse(discount.text));
              },
              child: Text(
                "سحب",
                style: systemTextStyle.largeLight.copyWith(fontSize: 18),
              ),
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(150, 50)),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> discountDriverWallet(double discount) async {
    try {
      final response = await sendRequestWithHandler(
        method: "patch",
        endpoint: '/admin/zero_driver_wallet',
        body: {'driverId': driver.id, "discount": discount},
        loadingMessage: 'جاري سحب الرصيد...',
      );

      if (response != null && response['status'] == 'success') {
        driver.balance = driver.balance - discount;
        update();
        Get.snackbar(
          'نجاح',
          'تم سحب $discount من رصيد السائق بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تصفير الرصيد',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
