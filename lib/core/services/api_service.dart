import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:murafiq/core/constant/Constatnt.dart';
import 'package:murafiq/main.dart';
import '../utils/systemVarible.dart';

class ApiService {
  static Future<Map<String, dynamic>> request({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String loadingMessage = 'جاري التحميل...',
    bool showLoading = true,
    bool handleError = true,
  }) async {
    try {
      final token = shared!.getString("token");
      // Show loading if requested
      if (showLoading) {
        Get.dialog(
          PopScope(
            canPop: true,
            child: AlertDialog(
              backgroundColor: systemColors.white,
              content: Container(
                height: 150,
                width: 150,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SpinKitWave(
                        color: systemColors.primary,
                        itemCount: 4,
                        size: 40.0,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        loadingMessage,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );
      }

      // Prepare URL
      final url = Uri.parse('${serverConstant.serverUrl}$endpoint');

      // Prepare headers
      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      // Make request based on method
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: requestHeaders,
            body: json.encode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: requestHeaders,
            body: json.encode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders);
          break;
        case 'PATCH':
          response = await http.patch(
            url,
            headers: requestHeaders,
            body: json.encode(body),
          );
          break;
        default:
          throw Exception('Method $method not supported');
      }

      // Hide loading
      if (showLoading && Get.isDialogOpen == true) {
        Get.back();
      }

      // Parse response
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Check for error status codes
      if (response.statusCode >= 400) {
        throw HttpException(
          responseData['message'] ??
              responseData['error'] ??
              'حدث خطأ في الخادم',
          uri: url,
        );
      }

      return responseData;
    } on SocketException catch (_) {
      if (showLoading && Get.isDialogOpen == true) Get.back();
      if (handleError) {
        Get.snackbar(
          'خطأ في الاتصال',
          'تأكد من اتصالك بالإنترنت',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      rethrow;
    } on HttpException catch (e) {
      if (showLoading && Get.isDialogOpen == true) Get.back();
      if (handleError) {
        Get.snackbar(
          'خطأ',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      rethrow;
    } on FormatException catch (_) {
      if (showLoading && Get.isDialogOpen == true) Get.back();
      if (handleError) {
        Get.snackbar(
          'خطأ',
          'حدث خطأ في معالجة البيانات',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      rethrow;
    } catch (e) {
      if (showLoading && Get.isDialogOpen == true) Get.back();

      if (handleError) {
        print(e);
        Get.snackbar(
          'خطأ',
          'حدث خطأ غير متوقع',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      await Future.delayed(const Duration(seconds: 1));
      if (showLoading && Get.isDialogOpen == true) Get.back();
      await Future.delayed(const Duration(seconds: 5));

      if (showLoading && Get.isDialogOpen == true) Get.back();
      await Future.delayed(const Duration(seconds: 10));

      if (showLoading && Get.isDialogOpen == true) Get.back();
      rethrow;
    }
  }
}
