import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/auth/login_page.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/main.dart';
import '../features/customer/screens/customer_home_page.dart';
import '../pages/driver_home_page.dart';
import '../core/services/api_service.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString userType = ''.obs;

  Future<void> login(String phone, String password) async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/auth/login',
        method: 'POST',
        body: {
          'phone': phone,
          'password': password,
        },
        loadingMessage: 'جاري تسجيل الدخول...',
      );
      print(response);
      // Check response status
      if (response['status'] == 'success') {
        // Store user type from response
        userType.value = response['data']['user']['type'];
        isLoggedIn.value = true;

        // Store token
        if (response['token'] != null) {
          final token = response['token'];
          shared!.setString("token", token);
        }

        // Navigate based on user type
        if (userType.value == 'customer') {
          Get.offAll(() => const CustomerHomePage());
        } else if (userType.value == 'driver') {
          Get.offAll(() => DriverHomePage());
        }
      } else {
        throw Exception(response['message'] ?? 'فشل تسجيل الدخول');
      }
    } catch (e) {
      // Error handling is done in ApiService
      isLoggedIn.value = false;
      Get.snackbar(
        'خطأ',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String userTypee,
    required String phone,
    required String gender,
    String? idNumber,
    String? carNumber,
  }) async {
    try {
      // Prepare request body based on user type
      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'type': userTypee,
        'gender': gender,
      };

      // Add driver-specific fields if user is a driver
      if (userTypee == 'driver') {
        body['idNumber'] = idNumber;
        body['carNumber'] = carNumber;
        print(idNumber);
      }

      final response = await ApiService.request(
        endpoint: '/auth/signup',
        method: 'POST',
        body: body,
        loadingMessage: 'جاري إنشاء الحساب...',
      );

      // Check response status
      if (response['status'] == 'success') {
        // Store user type and data
        userType.value = response['data']['user']['type'];
        isLoggedIn.value = true;

        // Store token
        if (response['token'] != null) {
          // TODO: Store token in secure storage
          final token = response['token'];
          shared!.setString("token", token);
        }

        // Navigate based on user type
        if (userType.value == 'customer') {
          Get.offAll(() => const CustomerHomePage());
        } else if (userType.value == 'driver') {
          // TODO: Navigate to driver home page
          Get.offAll(() => DriverHomePage());
        }
      } else {
        throw Exception(response['message'] ?? 'حدث خطأ في عملية التسجيل');
      }
    } catch (e) {
      isLoggedIn.value = false;
      // Error handling is done in ApiService
    }
  }

  Future<void> logout() async {
    try {
      // await ApiService.request(
      //   endpoint: '/auth/logout',
      //   method: 'POST',
      //   loadingMessage: 'جاري تسجيل الخروج...',
      // );

      // isLoggedIn.value = false;
      // userType.value = '';
      // // TODO: Clear stored token
      shared!.remove("token");

      Get.offAll(() => LoginPage());
    } catch (e) {
      // Error handling is done in ApiService
    }
  }
}
