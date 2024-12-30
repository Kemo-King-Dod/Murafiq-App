import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/services/api_service.dart';
import 'package:murafiq/core/services/local_storage_service.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/trip.dart';
import 'package:murafiq/driver/public/screens/active_trip_page.dart';

class TripService {
  // جلب الرحلات المتاحة للسائق
  static Future<List<Trip>> getAvailableTrips(
      {String? city, LatLng? point}) async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/trips/driver/available',
        method: 'POST',
        body: {
          'city': city,
          'point': {"latitude": point!.latitude, "longitude": point.longitude},
        },
      );

      if (response != null &&
          response['status'] == 'success' &&
          response['data'] != null) {
        final List<dynamic> tripsJson = response['data']['trips'] ?? [];
        final rejectedTrips = LocalStorageService.getRejectedTrips();

        // تصفية الرحلات المرفوضة
        final trips = tripsJson
            .map((tripJson) => Trip.fromJson(tripJson))
            .where((trip) => !rejectedTrips.contains(trip.id))
            .toList();

        return trips;
      } else if (response != null && response['status'] == 'error') {
        Get.snackbar(
          'خطاء',
          response['error']['message'].toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: systemColors.error,
          colorText: systemColors.white,
        );
        return [];
      }
      return [];
    } catch (e) {
      print('Error getting available trips: $e');
      return [];
    }
  }

  // قبول الرحلة
  static Future<bool> acceptTrip(String tripId) async {
    try {
      print("here trip id $tripId");
      final response = await sendRequestWithHandler(
        endpoint: '/trips/driver/$tripId/accept',
        method: 'PATCH',
        loadingMessage: 'جاري قبول الرحلة...',
      );
      if (response != null) {
        if (response['status'] == 'success' && response['data'] != null) {
          final trip = Trip.fromJson(response['data']['trip']);
          // التوجيه إلى صفحة الرحلة النشطة
          Get.off(() => ActiveTripPage(trip: trip));
          return true;
        } else if (response['status'] == 'error' &&
            response['message'] != null) {
          Get.snackbar(
            'خطاء',
            response['message'].toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: systemColors.error,
            colorText: systemColors.white,
          );
          return false;
        } else if (response['status'] == 'fail' &&
            response['message'] != null) {
          Get.snackbar(
            'خطاء',
            response['message'].toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: systemColors.error,
            colorText: systemColors.white,
          );
          return false;
        }
        return false;
      }
      return false;
    } catch (e) {
      print('Error accepting trip: $e');
      return false;
    }
  }

  // رفض الرحلة
  static Future<bool> rejectTrip(String tripId) async {
    try {
      // إضافة الرحلة إلى قائمة الرحلات المرفوضة محلياً
      LocalStorageService.addRejectedTrip(tripId);
      return true;
    } catch (e) {
      print('Error rejecting trip: $e');
      return false;
    }
  }

  // إنهاء الرحلة
  static Future<bool> completeTrip(String tripId) async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/trips/driver/$tripId/complete',
        method: 'PATCH',
        loadingMessage: 'جاري إنهاء الرحلة...',
      );
      print(response.toString());
      if (response != null) {
        if (response['status'] == 'success') {
          Get.snackbar(
            'نجاح',
            'تم إنهاء الرحلة بنجاح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: systemColors.sucsses,
            colorText: systemColors.white,
          );
          return true;
        } else {
          Get.snackbar(
            'خطاء',
            response["message"].toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: systemColors.error,
            colorText: systemColors.white,
          );
        }
        return false;
      } else {
        print("response" + response);
        return false;
      }
    } catch (e) {
      print('Error completing trip: $e');
      return false;
    }
  }

  // التحقق من رمز الرحلة وتغيير حالتها إلى arrived
  static Future<bool> verifyTripCodeAndUpdateStatus(
      String tripId, String enteredCode) async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/trips/driver/$tripId/verify-code',
        method: 'PATCH',
        body: {
          'tripCode': enteredCode,
        },
        loadingMessage: 'جاري التحقق من رمز الرحلة...',
      );

      if (response != null) {
        if (response['status'] == 'success') {
          Get.snackbar(
            'نجاح',
            'تم التحقق من رمز الرحلة بنجاح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: systemColors.sucsses,
            colorText: systemColors.white,
          );
          return true;
        } else {
          Get.snackbar(
            'خطأ',
            response['message'] ?? 'فشل التحقق من رمز الرحلة',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: systemColors.error,
            colorText: systemColors.white,
          );
          return false;
        }
      }
      return false;
    } catch (e) {
      print('Error verifying trip code: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء التحقق من رمز الرحلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: systemColors.error,
        colorText: systemColors.white,
      );
      return false;
    }
  }
}
