import 'package:get/get.dart';
import 'package:murafiq/core/services/api_service.dart';
import 'package:murafiq/models/trip.dart';

class TripService {
  // جلب الرحلات المتاحة للسائق
  static Future<Trip?> getAvailableTrip() async {
    try {
      final response = await ApiService.request(
        endpoint: '/trips/driver/available',
        method: 'GET',
        showLoading: false,
      );
      if (response['data']['trip'] != null) {
        return Trip.fromJson(response['data']['trip']);
      }
      return null;
    } catch (e) {
      print('Error getting available trip: $e');
      return null;
    }
  }

  // قبول الرحلة
  static Future<bool> acceptTrip(String tripId) async {
    try {
      await ApiService.request(
        endpoint: '/trips/driver/$tripId/accept',
        method: 'PATCH',
        loadingMessage: 'جاري قبول الرحلة...',
      );
      return true;
    } catch (e) {
      print('Error accepting trip: $e');
      return false;
    }
  }

  // رفض الرحلة
  static Future<bool> rejectTrip(String tripId) async {
    try {
      await ApiService.request(
        endpoint: '/trips/driver/$tripId/reject',
        method: 'PATCH',
        loadingMessage: 'جاري رفض الرحلة...',
      );
      return true;
    } catch (e) {
      print('Error rejecting trip: $e');
      return false;
    }
  }
}
