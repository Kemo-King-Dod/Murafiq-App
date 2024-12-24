import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:murafiq/admin/screens/admin_dashboard.dart';
import 'package:murafiq/core/constant/Constatnt.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/main.dart';
import '../customer/public/screens/customer_home_page.dart';
import '../driver/public/screens/driver_home_page.dart';
import '../core/services/api_service.dart';
import '../auth/login_page.dart';
import 'package:path/path.dart' as path;

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString userType = ''.obs;

  Future<void> login(String phone, String password) async {
    try {
      String fcm_token = shared!.getString("fcm_token")!;
      final response = await sendRequestWithHandler(
        endpoint: '/auth/login',
        method: 'POST',
        body: {
          "fcm_token": fcm_token,
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
        shared!.setString("userName", response['data']['user']['name']);
        shared!.setString("userPhone", response['data']['user']['phone']);
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
        } else if (userType.value == 'admin') {
          Get.offAll(() => AdminDashboardPage());
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
    required String password,
    required String userTypee,
    required String phone,
    required String gender,
    String? licenseNumber,
    String? carNumber,
    String? identityType,
    File? identityImage,
  }) async {
    try {
      // Prepare request body based on user type
      final Map<String, dynamic> body = {
        'name': name,
        'password': password,
        'phone': phone,
        'type': userTypee,
        'gender': gender,
        'fcmToken': shared!.getString("fcm_token"),
      };

      // Add driver-specific fields if user is a driver
      if (userTypee == 'driver') {
        body['licenseNumber'] = licenseNumber;
        body['carNumber'] = carNumber;
        body['identityType'] = 'driver_license'; // Always use driver's license
      }

      // Prepare the request
      http.MultipartRequest? request;
      http.StreamedResponse? streamedResponse;

      // Handle identity image upload for drivers
      if (userTypee == 'driver' && identityImage != null) {
        // Create multipart request
        request = await http.MultipartRequest(
            'POST', Uri.parse(serverConstant.serverUrl + '/auth/signup'));

        // Add text fields to the request
        body.forEach((key, value) {
          request!.fields[key] = value.toString();
        });
        print(
          identityImage.path,
        );
        print('File details:');
        print('Path: ${identityImage.path}');
        print('Filename: ${identityImage.path.split('/').last}');
        print('Extension: ${path.extension(identityImage.path)}');
        print('Absolute path: ${identityImage.absolute.path}');

        // Add file type check
        final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
        final fileExt = path.extension(identityImage.path).toLowerCase();
        if (!allowedExtensions.contains(fileExt)) {
          throw Exception(
              'Unsupported file type. Only .jpg, .jpeg, .png, .gif are allowed.');
        }

        // Add file to the request
        request.files.add(await http.MultipartFile.fromPath(
          'driverLicense',
          identityImage.path,
        ));

        // Send the request
        streamedResponse = await request.send();

        // Read the response
        final response = await http.Response.fromStream(streamedResponse);
        final responseBody = json.decode(response.body);
        print(responseBody.toString());

        // Check response status
        if (responseBody['status'] == 'success') {
          // Store user type and data
          userType.value = responseBody['data']['user']['type'];
          isLoggedIn.value = true;

          // Store token
          if (responseBody['token'] != null) {
            final token = responseBody['token'];
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
          throw Exception(
              responseBody['message'] ?? 'حدث خطأ في عملية التسجيل');
        }
      } else {
        // Existing signup logic for non-driver or without image
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
      }
    } catch (e) {
      isLoggedIn.value = false;
      // Error handling is done in ApiService
      rethrow; // Rethrow to allow error handling in the UI
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
