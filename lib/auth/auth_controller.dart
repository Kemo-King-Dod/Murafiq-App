import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:murafiq/admin/screens/admin_dashboard.dart';
import 'package:murafiq/core/constant/Constatnt.dart';
import 'package:murafiq/core/controllers/socket_controller.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/services/notification_service.dart';
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
      String? fcm_token = shared!.getString("fcm_token");
      if (fcm_token == null) {
        // Get new FCM token if not available
        final notificationService = Get.find<NotificationService>();
        fcm_token = await notificationService.getAndSaveFCMToken();
      }
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

      if (response['status'] == 'success') {
        await _handleSuccessfulLogin(response);
      } else {
        throw Exception(response['message'] ?? 'فشل تسجيل الدخول');
      }
    } catch (e) {
      isLoggedIn.value = false;
      Get.snackbar(
        'خطأ',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleSuccessfulLogin(Map<String, dynamic> response) async {
    try {
      print("response handler" + response.toString());
      // Store user data
      userType.value = response['data']['user']['type'];
      shared!.setString("user_type", userType.value);
      shared!.setString("user_phone", response['data']['user']['phone']);
      shared!.setString("user_id", response['data']['user']['id'].toString());
      shared!.setString("user_name", response['data']['user']['name']);
      shared!.setString("user_gender", response["data"]["user"]['gender']);

      // Store token
      if (response['token'] != null) {
        final token = response['token'];
        shared!.setString("token", token);
      }

      isLoggedIn.value = true;

      // Navigate based on user type
      _navigateBasedOnUserType();
    } catch (e) {
      print("Error handling login success: $e");
      throw Exception('حدث خطأ أثناء معالجة تسجيل الدخول');
    }
  }

  void _navigateBasedOnUserType() {
    switch (userType.value) {
      case 'customer':
        FirebaseMessaging.instance.subscribeToTopic('customers');
        Get.offAll(() => const CustomerHomePage());
        break;
      case 'driver':
        FirebaseMessaging.instance.subscribeToTopic('drivers');
        Get.offAll(() => DriverHomePage(),
            binding: BindingsBuilder(() => Get.put(SocketController())));
        break;
      case 'admin':
        FirebaseMessaging.instance.subscribeToTopic('admins');
        Get.offAll(() => const AdminDashboardPage());
        break;
      default:
        Get.offAll(() => LoginPage());
    }
  }

  Future<bool> autoLogin() async {
    try {
      final token = shared!.getString('token');
      final savedUserType = shared!.getString('user_type');

      if (token != null && savedUserType != null) {
        // Verify token with server
        final response = await sendRequestWithHandler(
          endpoint: '/auth/verify-token',
          method: 'POST',
          body: {"token": token},
          loadingMessage: 'جاري التحقق...',
        );

        if (response['status'] == 'success') {
          userType.value = savedUserType;
          isLoggedIn.value = true;
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Auto login error: $e");
      return false;
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
    String? carType,
    String? identityType,
    File? identityImage,
  }) async {
    try {
      isLoading.value = true;
      String? fcm_token = shared!.getString("fcm_token");
      if (fcm_token == null) {
        // Get new FCM token if not available
        final notificationService = Get.find<NotificationService>();
        fcm_token = await notificationService.getAndSaveFCMToken();
      }
      // Prepare request body based on user type
      final Map<String, dynamic> body = {
        'name': name,
        'password': password,
        'phone': phone,
        'type': userTypee,
        'gender': gender,
        'fcmToken': fcm_token,
      };

      // Add driver-specific fields if user is a driver
      if (userTypee == 'driver') {
        body['licenseNumber'] = licenseNumber;
        body['carNumber'] = carNumber;
        body['identityType'] = 'driver_license'; // Always use driver's license
        body["carType"] = carType;
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
          // Store token
          if (responseBody['token'] != null) {
            final token = responseBody['token'];
            shared!.setString("token", token);
          } else {
            throw Exception(
                responseBody['message'] ?? 'حدث خطأ في عملية التسجيل');
          }
          isLoading.value = false;
          // Navigate based on user type
          _handleSuccessfulLogin(responseBody);
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
        if (response != null) {
          // Check response status
          if (response['status'] == 'success') {
            // Store user type and data

            _handleSuccessfulLogin(response);
          } else {
            throw Exception(response['message'] ?? 'حدث خطأ في عملية التسجيل');
          }
        }
      }
    } catch (e) {
      isLoggedIn.value = false;
      // Error handling is done in ApiService
      rethrow; // Rethrow to allow error handling in the UI
    }
  }

  Future<void> forgetPassword({required String phone}) async {
    try {
      final response = await ApiService.request(
        endpoint: '/auth/for',
        method: 'POST',
        body: {
          'phone': phone,
        },
        loadingMessage: 'جاري استعادة كلمة المرور...',
      );

      // Check response status
      if (response['status'] == 'success') {
        Get.offAll(() => LoginPage());
      } else {
        throw Exception(response['message'] ?? 'فشل استعادة كلمة المرور');
      }
    } catch (e) {
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
      shared!.remove("user_type");
      shared!.remove("user_id");
      shared!.remove("user_name");
      shared!.remove("fcm_token");

      Get.offAll(() => LoginPage());
    } catch (e) {
      // Error handling is done in ApiService
    }
  }
}
