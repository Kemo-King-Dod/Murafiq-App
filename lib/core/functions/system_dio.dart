import "package:dio/dio.dart";
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:get/get.dart' as Get;
import 'package:murafiq/core/constant/Constatnt.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/main.dart'; // تأكد من استيراد الـ systemUtils

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "${serverConstant.serverUrl}",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) {
          // اعتبر الأكواد 200، 201، 400، 404 ناجحة
          return status != null &&
              [200, 201, 400, 404, 401, 403].contains(status);
        },
      ),
    );

    // إضافة RetryInterceptor لإعادة المحاولة تلقائيًا
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: print,
        retries: 3,
        retryDelays: [
          Duration(seconds: 1),
          Duration(seconds: 1),
          Duration(seconds: 1),
        ],
        retryEvaluator: (DioException e, int attempt) async {
          return e.type != DioExceptionType.cancel &&
              e.type != DioExceptionType.unknown;
        },
        ignoreRetryEvaluatorExceptions: true,
      ),
    );
  }

  Future<dynamic> sendRequest({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Response response;
      final token = shared!.getString('token');
      Options options = Options(headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token",
      });

      // تحديد نوع الطلب
      if (method.toUpperCase() == 'PATCH') {
        response = await _dio.patch(endpoint, data: body, options: options);
      } else if (method.toUpperCase() == 'POST') {
        response = await _dio.post(endpoint, data: body, options: options);
      } else if (method.toUpperCase() == 'DELETE') {
        response = await _dio.delete(endpoint, data: body, options: options);
      } else {
        response = await _dio.get(endpoint,
            queryParameters: queryParameters, options: options);
      }

      // التحقق من حالة الطلب
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        return response.data;
      } else {
        throw Exception('Error: ${response.statusMessage}');
      }
    } on DioException catch (error) {
      // معالجة أخطاء Dio
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw Exception('Timeout Error: فشل الاتصال بالخادم، حاول مرة أخرى');
      } else if (error.type == DioExceptionType.badResponse) {
        throw Exception('Server Error: ${error.response?.statusMessage}');
      } else if (error.type == DioExceptionType.connectionError) {
        throw Exception('Network Error: تأكد من اتصالك بالإنترنت');
      } else {
        throw Exception('Unknown Error: حدث خطأ غير متوقع');
      }
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }
}
