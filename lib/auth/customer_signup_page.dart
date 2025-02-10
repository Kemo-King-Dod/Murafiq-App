import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/auth/driver_signup_page.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import '../main.dart';
import 'auth_controller.dart';
import 'login_page.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:murafiq/core/functions/errorHandler.dart';

class CustomerSignupPage extends StatefulWidget {
  const CustomerSignupPage({Key? key}) : super(key: key);

  @override
  State<CustomerSignupPage> createState() => _CustomerSignupPageState();
}

class ResendTimerController extends GetxController {
  RxInt countdown = 0.obs;
  Timer? _timer;

  void startTimer() {
    countdown.value = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

class _CustomerSignupPageState extends State<CustomerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String selectedGender = 'male'; // Default value
  final ResendTimerController _timerController =
      Get.put(ResendTimerController());
  final AuthController authController = Get.find();
  String? _storedOTP;

  void _resetFields() {
    nameController.clear();
    passwordController.clear();
    phoneController.clear();
    confirmPasswordController.clear();
    selectedGender = "male";
  }

  Widget _buildResendButton() {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _timerController.countdown.value == 0
            ? GestureDetector(
                key: const ValueKey('resend-active'),
                onTap: () async {
                  final response = await sendRequestWithHandler(
                    endpoint: '/auth/verify_phone',
                    method: 'POST',
                    loadingMessage: "جاري إعادة إرسال رمز التحقق".tr,
                    body: {
                      "phone": phoneController.text,
                    },
                  );
                  if (response != null &&
                      response["data"] != null &&
                      response["status"] == "success" &&
                      response["data"]["pin"] != null) {
                    _storedOTP = response["data"]["pin"].toString();
                    _timerController.startTimer();
                    Get.snackbar(
                      'إعادة الإرسال'.tr,
                      'تم إعادة إرسال رمز التأكيد'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: Text(
                  'إعادة الإرسال'.tr,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 35,
                    height: 35,
                    child: CircularProgressIndicator(
                      value: _timerController.countdown.value / 60,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  Text(
                    '${_timerController.countdown.value}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'إنشاء حساب زبون'.tr,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل بياناتك لإنشاء حساب جديد'.tr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'الاسم'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال الاسم'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '09XXXXXXXX'.tr,
                      labelText: 'رقم الجوال'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم الجوال'.tr;
                      }
                      if (!GetUtils.isPhoneNumber(value)) {
                        return 'الرجاء إدخال رقم جوال صحيح'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 12.0, bottom: 8.0),
                        child: Text(
                          "الجنس".tr,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedGender = 'male';
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedGender == 'male'
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: selectedGender == 'male'
                                      ? [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.male,
                                      color: selectedGender == 'male'
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ذكر'.tr,
                                      style: TextStyle(
                                        color: selectedGender == 'male'
                                            ? Colors.white
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedGender = 'female';
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedGender == 'female'
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: selectedGender == 'female'
                                      ? [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.female,
                                      color: selectedGender == 'female'
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'انثى'.tr,
                                      style: TextStyle(
                                        color: selectedGender == 'female'
                                            ? Colors.white
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كلمة المرور'.tr;
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء تأكيد كلمة المرور'.tr;
                      }
                      if (value != passwordController.text) {
                        return 'كلمات المرور غير متطابقة'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authController.isLoading.value
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                Get.snackbar(
                                  'خطأ'.tr,
                                  'كلمة المرور غير متطابقة'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              final response = await sendRequestWithHandler(
                                endpoint: '/auth/verify_phone',
                                method: 'POST',
                                loadingMessage: "جاري ارسال رمز التحقق".tr,
                                body: {
                                  "phone": phoneController.text,
                                },
                              );

                              if (response != null &&
                                  response["data"] != null &&
                                  response["status"] == "success" &&
                                  response["data"]["pin"] != null) {
                                _storedOTP = response["data"]["pin"].toString();
                                _timerController.startTimer();
                                Get.dialog(
                                  PopScope(
                                    canPop: false,
                                    child: Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey
                                                  .withValues(alpha: 0.2),
                                              spreadRadius: 3,
                                              blurRadius: 7,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.phone_android,
                                              size: 80,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'تأكيد رقم الجوال'.tr,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'أدخل رمز التأكيد المرسل إلى رقم ${phoneController.text}'
                                                  .tr,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 24),
                                            Directionality(
                                              textDirection: TextDirection.ltr,
                                              child: OTPTextField(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 2),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 1,
                                                        horizontal: 1),
                                                otpFieldStyle: OtpFieldStyle(
                                                  borderColor: Theme.of(context)
                                                      .primaryColor,
                                                  enabledBorderColor:
                                                      Colors.grey[300]!,
                                                  focusBorderColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                ),
                                                fieldStyle: FieldStyle.box,
                                                length: 6,
                                                fieldWidth: 35,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textFieldAlignment:
                                                    MainAxisAlignment.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                onCompleted: (pin) async {
                                                  try {
                                                    if (_storedOTP == pin) {
                                                      final controller =
                                                          Get.find<
                                                              AuthController>();
                                                      controller.signup(
                                                        name:
                                                            nameController.text,
                                                        password:
                                                            passwordController
                                                                .text,
                                                        userTypee: 'customer',
                                                        phone: phoneController
                                                            .text,
                                                        gender: selectedGender,
                                                      );

                                                      Get.back();
                                                      Get.snackbar(
                                                        'ناجح'.tr,
                                                        'تم إنشاء الحساب بنجاح'
                                                            .tr,
                                                        snackPosition:
                                                            SnackPosition
                                                                .BOTTOM,
                                                        backgroundColor:
                                                            Colors.green,
                                                        colorText: Colors.white,
                                                      );
                                                    } else {
                                                      Get.snackbar(
                                                        'خطأ'.tr,
                                                        'رمز التأكيد غير صحيح'
                                                            .tr,
                                                        snackPosition:
                                                            SnackPosition
                                                                .BOTTOM,
                                                        backgroundColor:
                                                            Colors.red,
                                                        colorText: Colors.white,
                                                      );
                                                    }
                                                  } catch (e) {
                                                    Get.snackbar(
                                                      'خطأ'.tr,
                                                      'حدث خطأ غير متوقع'.tr,
                                                      snackPosition:
                                                          SnackPosition.BOTTOM,
                                                      backgroundColor:
                                                          Colors.red,
                                                      colorText: Colors.white,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'لم تستلم الرمز؟'.tr,
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                                const SizedBox(width: 8),
                                                _buildResendButton(),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            TextButton(
                                              onPressed: () {
                                                _timerController.onClose();
                                                _resetFields();
                                                Get.back();
                                              },
                                              child: Text(
                                                'إلغاء'.tr,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  barrierDismissible: false,
                                );
                              } else {
                                Get.snackbar(
                                  'خطأ'.tr,
                                  response?["message"] ??
                                      'حدث خطأ غير متوقع'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إنشاء حساب'.tr,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Obx(
                      () => authController.isLoading.value
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => DriverSignupPage());
                    },
                    child: Text(
                      "إنشاء حساب سائق".tr,
                      style: systemTextStyle.smallPrimary,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: systemColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('لديك حساب بالفعل؟'.tr),
                      TextButton(
                        onPressed: () {
                          Get.to(() => LoginPage());
                        },
                        child: Text('تسجيل الدخول'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
