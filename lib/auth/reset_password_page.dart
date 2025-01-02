import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/auth/auth_controller.dart';
import 'package:murafiq/auth/login_page.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

class ResetPasswordPage extends StatelessWidget {
  final String phone;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ResetPasswordPage({Key? key, required this.phone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: systemColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: systemColors.primary,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          'تعيين كلمة المرور الجديدة',
          style: TextStyle(
            color: systemColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Icon(
                      Icons.lock_reset_rounded,
                      size: 120,
                      color: systemColors.primary,
                    ),
                    SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أدخل كلمة المرور الجديدة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: systemColors.primary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 25),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              if (value.length < 6) {
                                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور الجديدة',
                              labelStyle:
                                  TextStyle(color: systemColors.primary),
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: systemColors.primary),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: systemColors.primary),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى تأكيد كلمة المرور';
                              }
                              if (value != passwordController.text) {
                                return 'كلمات المرور غير متطابقة';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'تأكيد كلمة المرور',
                              labelStyle:
                                  TextStyle(color: systemColors.primary),
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: systemColors.primary),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: systemColors.primary),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    final response =
                                        await sendRequestWithHandler(
                                      endpoint: '/auth/reset_password',
                                      method: 'POST',
                                      loadingMessage:
                                          "جاري تحديث كلمة المرور...",
                                      body: {
                                        "phone": phone,
                                        "newPassword": passwordController.text,
                                      },
                                    );

                                    if (response != null &&
                                        response['status'] == 'success') {
                                      Get.snackbar(
                                        'تم بنجاح',
                                        'تم تحديث كلمة المرور بنجاح',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                      Get.offAll(() => LoginPage());
                                    }
                                  } catch (e) {
                                    Get.snackbar(
                                      'خطأ',
                                      'حدث خطأ أثناء تحديث كلمة المرور',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: systemColors.primary,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'تحديث كلمة المرور',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
