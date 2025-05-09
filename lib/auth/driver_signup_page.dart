import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import '../main.dart';
import 'auth_controller.dart';
import 'login_page.dart';

class DResendTimerController extends GetxController {
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

class DriverSignupPage extends StatefulWidget {
  DriverSignupPage({Key? key}) : super(key: key);

  @override
  State<DriverSignupPage> createState() => _DriverSignupPageState();
}

class _DriverSignupPageState extends State<DriverSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController();
  final TextEditingController carTypeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String selectedGender = 'male'; // Default value
  File? identityImageFile; // File to store uploaded driver's license image
  File? carBrochureImageFile; // File to store uploaded car brochure image
  File? carImageFile; // File to store uploaded car image
  File? passportImageFile; // File to store uploaded passport image
  File?
      identityImageBackFile; // File to store uploaded back image of driver's license
  final DResendTimerController _timerController =
      Get.put(DResendTimerController());
  String? _storedOTP;
  final AuthController authController = Get.find();

  Future<void> _pickIdentityImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        identityImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCarBrochureImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        carBrochureImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCarImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        carImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickPassportImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        passportImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickIdentityImageBack() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        identityImageBackFile = File(pickedFile.path);
      });
    }
  }

  void _resetFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    licenseNumberController.clear();
    carTypeController.clear();
    carNumberController.clear();
    confirmPasswordController.clear();
    identityImageFile = null;
    selectedGender = "male";
  }

  @override
  void dispose() {
    _timerController.onClose();
    super.dispose();
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
                      'إعادة إرسال'.tr,
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
                    '${_timerController.countdown.value}'.tr,
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
        child: Get.find<AuthController>().isLoading.value
            ? SizedBox(
                height: Get.height,
                width: Get.width,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: systemColors.primary,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "جاري التحميل".tr,
                        style: TextStyle(
                            color: systemColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      )
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          'إنشاء حساب سائق'.tr,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أدخل بياناتك لإنشاء حساب جديد'.tr,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                        TextFormField(
                          controller: licenseNumberController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'رقم الرخصة'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الرخصة'.tr;
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: carNumberController,
                          decoration: InputDecoration(
                            labelText: 'رقم السيارة'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon:
                                const Icon(Icons.directions_car_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم السيارة'.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: carTypeController,
                          decoration: InputDecoration(
                            labelText: 'نوع السيارة'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon:
                                const Icon(Icons.directions_car_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال نوع السيارة'.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(right: 12.0, bottom: 8.0),
                              child: Text(
                                'الجنس'.tr,
                                style: TextStyle(
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(right: 12.0, bottom: 8.0),
                              child: Text(
                                'صورة رخصة القيادة'.tr,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: _pickIdentityImage,
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: identityImageFile != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            identityImageFile!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload,
                                              color: Colors.grey[600],
                                              size: 50,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'اضغط لرفع صورة رخصة القيادة'.tr,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(right: 12.0, bottom: 8.0),
                              child: Text(
                                'صورة كتيب السيارة'.tr,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: _pickCarBrochureImage,
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: carBrochureImageFile != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            carBrochureImageFile!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload,
                                              color: Colors.grey[600],
                                              size: 50,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'اضغط لرفع صورة كتيب السيارة'.tr,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(right: 12.0, bottom: 8.0),
                              child: Text(
                                'صورة السيارة'.tr,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: _pickCarImage,
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: carImageFile != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            carImageFile!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload,
                                              color: Colors.grey[600],
                                              size: 50,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'اضغط لرفع صورة السيارة'.tr,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(right: 12.0, bottom: 8.0),
                              child: Text(
                                'صورة جواز السفر'.tr,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: _pickPassportImage,
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: passportImageFile != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            passportImageFile!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload,
                                              color: Colors.grey[600],
                                              size: 50,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'اضغط لرفع صورة جواز السفر'.tr,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(right: 12.0, bottom: 8.0),
                              child: Text(
                                'صورة رخصة القيادة من الخلف'.tr,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: _pickIdentityImageBack,
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: identityImageBackFile != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            identityImageBackFile!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload,
                                              color: Colors.grey[600],
                                              size: 50,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'اضغط لرفع صورة رخصة القيادة من الخلف'
                                                  .tr,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
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
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                                  .tr;
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
                        Column(
                          children: [
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

                                        if (identityImageFile == null) {
                                          Get.snackbar(
                                            'خطأ'.tr,
                                            'الرجاء رفع صورة رخصة القيادة'.tr,
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }

                                        if (carBrochureImageFile == null) {
                                          Get.snackbar(
                                            'خطأ'.tr,
                                            'الرجاء رفع صورة كتيب السيارة'.tr,
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }

                                        if (carImageFile == null) {
                                          Get.snackbar(
                                            'خطأ'.tr,
                                            'الرجاء رفع صورة السيارة'.tr,
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }

                                        if (passportImageFile == null) {
                                          Get.snackbar(
                                            'خطأ'.tr,
                                            'الرجاء رفع صورة جواز السفر'.tr,
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }

                                        if (identityImageBackFile == null) {
                                          Get.snackbar(
                                            'خطأ'.tr,
                                            'الرجاء رفع صورة رخصة القيادة من الخلف'
                                                .tr,
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }
                                        final response =
                                            await sendRequestWithHandler(
                                                endpoint: '/auth/verify_phone',
                                                method: 'POST',
                                                loadingMessage:
                                                    "جاري ارسال رمز التحقق".tr,
                                                body: {
                                              "phone": phoneController.text,
                                            });
                                        if (response != null &&
                                            response["data"] != null &&
                                            response["status"] == "success" &&
                                            response["data"]["pin"] != null) {
                                          _storedOTP = response["data"]["pin"]
                                              .toString();
                                          _timerController.startTimer();
                                          Get.dialog(PopScope(
                                            canPop: false,
                                            child: Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(24),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withValues(
                                                              alpha: 0.2),
                                                      spreadRadius: 3,
                                                      blurRadius: 7,
                                                      offset:
                                                          const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'أدخل رمز التأكيد المرسل إلى رقم'
                                                              .tr +
                                                          ' ${phoneController.text}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 24),
                                                    Directionality(
                                                      textDirection:
                                                          TextDirection.ltr,
                                                      child: OTPTextField(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 2),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical: 1,
                                                                    horizontal:
                                                                        1),
                                                        otpFieldStyle:
                                                            OtpFieldStyle(
                                                          borderColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          enabledBorderColor:
                                                              Colors.grey[300]!,
                                                          focusBorderColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        fieldStyle:
                                                            FieldStyle.box,
                                                        length: 6,
                                                        fieldWidth: 35,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textFieldAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onCompleted:
                                                            (pin) async {
                                                          try {
                                                            if (_storedOTP ==
                                                                pin) {
                                                              // Create driver account
                                                              final controller =
                                                                  Get.find<
                                                                      AuthController>();
                                                              controller.signup(
                                                                name:
                                                                    nameController
                                                                        .text,
                                                                password:
                                                                    passwordController
                                                                        .text,
                                                                userTypee:
                                                                    'driver',
                                                                phone:
                                                                    phoneController
                                                                        .text,
                                                                gender:
                                                                    selectedGender,
                                                                licenseNumber:
                                                                    licenseNumberController
                                                                        .text,
                                                                carNumber:
                                                                    carNumberController
                                                                        .text,
                                                                carType:
                                                                    carTypeController
                                                                        .text,
                                                                identityType:
                                                                    'driver_license',
                                                                identityImage:
                                                                    identityImageFile,
                                                                bookletOfCar:
                                                                    carBrochureImageFile,
                                                                carImage:
                                                                    carImageFile,
                                                                identityImageBackFile:
                                                                    identityImageBackFile,
                                                                passportImage:
                                                                    passportImageFile,
                                                              );

                                                              // Close dialog and show success
                                                              Get.back();
                                                              Get.snackbar(
                                                                'ناجح'.tr,
                                                                'تم إنشاء حساب السائق بنجاح'
                                                                    .tr,
                                                                snackPosition:
                                                                    SnackPosition
                                                                        .BOTTOM,
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                colorText:
                                                                    Colors
                                                                        .white,
                                                                duration:
                                                                    const Duration(
                                                                        seconds:
                                                                            3),
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              );
                                                            } else {
                                                              // Show error for incorrect OTP
                                                              Get.snackbar(
                                                                'خطأ'.tr,
                                                                'رمز التأكيد غير صحيح'
                                                                    .tr,
                                                                snackPosition:
                                                                    SnackPosition
                                                                        .BOTTOM,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                colorText:
                                                                    Colors
                                                                        .white,
                                                                duration:
                                                                    const Duration(
                                                                        seconds:
                                                                            3),
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .error_outline,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              );
                                                            }
                                                          } catch (e) {
                                                            // Handle any unexpected errors
                                                            Get.snackbar(
                                                              'خطأ'.tr,
                                                              'حدث خطأ غير متوقع'
                                                                  .tr,
                                                              snackPosition:
                                                                  SnackPosition
                                                                      .BOTTOM,
                                                              backgroundColor:
                                                                  Colors.red,
                                                              colorText:
                                                                  Colors.white,
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'لم تستلم الرمز؟'.tr,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[600]),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        _buildResendButton(),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    TextButton(
                                                      onPressed: () {
                                                        _timerController
                                                            .onClose();
                                                        _resetFields();
                                                        Get.back();
                                                      },
                                                      child: Text(
                                                        'إلغاء'.tr,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ));
                                        } else {
                                          Get.snackbar(
                                            'خطاء'.tr,
                                            'حدث خطاء غير متوقع'.tr,
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 56, vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'إنشاء حساب'.tr,
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => authController.isLoading.value
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
