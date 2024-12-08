import 'dart:async';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/trip.dart';

class tripDriver {
  final String? name;
  final String? phone;
  final String? carNumber;
  tripDriver({this.name, this.phone, this.carNumber});
  factory tripDriver.fromJson(Map<String, dynamic> json) {
    return tripDriver(
      name: json['name'],
      phone: json['phone'],
      carNumber: json['carNumber'],
    );
  }
}

class TripWaitingController extends GetxController {
  final trip = Rxn<Trip>();
  final currentStatus = TripStatus.searching.obs;
  Timer? _statusCheckTimer;
  final driver = Rxn<tripDriver>();

  @override
  void onInit() {
    super.onInit();
    startStatusChecking();
  }

  @override
  void onClose() {
    _statusCheckTimer?.cancel();
    super.onClose();
  }

  void startStatusChecking() {
    // التحقق الأولي من حالة الرحلة
    checkTripStatus();

    // بدء التحقق الدوري كل 5 ثواني
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkTripStatus();
    });
  }

  Future<void> checkTripStatus() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/trips/status',
        method: 'GET',
      );
      print(response.toString());

      if (response != null && response['data'] != null) {
        final updatedTrip = Trip.fromJson(response['data']['trip']);
        trip.value = updatedTrip;
        currentStatus.value = updatedTrip.status;
        driver.value = tripDriver.fromJson(response['data']['trip']['driver']);
        // إيقاف التحقق إذا وصلت الرحلة إلى حالة نهائية
        if (updatedTrip.status == TripStatus.completed ||
            updatedTrip.status == TripStatus.cancelled ||
            updatedTrip.status == TripStatus.rejected) {
          _statusCheckTimer?.cancel();
        }
      }
    } catch (e) {
      print('Error checking trip status: $e');
    }
  }

  Future<void> cancelTrip() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/trips/${trip.value?.id}/cancel',
        method: 'PATCH',
        loadingMessage: 'جاري إلغاء الرحلة...',
      );

      if (response != null) {
        currentStatus.value = TripStatus.cancelled;
        Get.back();
      }
    } catch (e) {
      print('Error cancelling trip: $e');
    }
  }

  void setTrip(Trip newTrip) {
    trip.value = newTrip;
    currentStatus.value = newTrip.status;
  }
}
