import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/driver/public/controllers/driver_wallet_controller.dart';

class AddbalancePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddbalancePageState();
}

class _AddbalancePageState extends State<AddbalancePage> {
  final TextEditingController _cardCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _addBalance() async {
    final walletcontroller = Get.find<DriverWalletController>();
    if (_formKey.currentState!.validate()) {
      print("card:${_cardCodeController.text}");
      // ---- رمز التحقق من الكرت من قاعدة البيانات ---
      final response = await sendRequestWithHandler(
          method: "POST",
          loadingMessage: "جاري الشحن".tr,
          endpoint: "/public/charge-wallet",
          body: {"code": _cardCodeController.text});
      print(response.toString());
      walletcontroller.fetchWalletDetails();

      if (response != null && response['data'] != null) {
        Get.back();
        Get.snackbar("تم شحن الرصيد".tr, "${response['data']['amount']}",
            backgroundColor: systemColors.primary,
            colorText: systemColors.white);
      } else {
        Get.back();
        Get.snackbar("خطا".tr, response['message'],
            backgroundColor: systemColors.primary,
            colorText: systemColors.white);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
        title: Text(
          'إضافة رصيد'.tr,
          style: systemTextStyle.mediumLight,
        ),
        backgroundColor: systemColors.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SvgPicture.asset(
                  "assets/SVG/addBalance.svg",
                  height: 200,
                  width: 200,
                  placeholderBuilder: (context) => CircularProgressIndicator(
                    color: systemColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "رمز البطاقة".tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: systemColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _cardCodeController,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    label: Text(
                      'رمز البطاقة'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: systemColors.primary,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.credit_card_rounded,
                      color: systemColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: systemColors.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: systemColors.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رمز البطاقة'.tr;
                    }
                    // Add more specific validation if needed
                    if (value.length < 10) {
                      return 'رمز البطاقة غير صحيح'.tr;
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _addBalance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: systemColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'تأكيد رمز البطاقة'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardCodeController.dispose();
    super.dispose();
  }
}
