import 'dart:async';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/customer/public/screens/customer_home_page.dart';
import 'package:murafiq/main.dart';
import 'package:murafiq/models/driver.dart';
import 'package:murafiq/models/trip.dart';

class TripWaitingController extends GetxController {
  final trip = Rxn<Trip>();
  final currentStatus = TripStatus.searching.obs;
  Timer? _statusCheckTimer;
  final driver = Rxn<Driver>();

  @override
  void onInit() {
    super.onInit();
    startStatusChecking();
    shared!.setBool("has_active_trip", true);
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
        driver.value = updatedTrip.driver;
        // إيقاف التحقق إذا وصلت الرحلة إلى حالة نهائية
        if (updatedTrip.status == TripStatus.completed ||
            updatedTrip.status == TripStatus.cancelled ||
            updatedTrip.status == TripStatus.rejected) {
          _statusCheckTimer?.cancel();
          if (updatedTrip.status == TripStatus.completed) {
            shared!.setBool("has_active_trip", false);
            Get.offAll(CustomerHomePage());
          }
        }
      }
    } catch (e) {
      print('Error checking trip status: $e');
    }
  }

  Future<void> cancelTrip() async {
    try {
      print('cancel');
      final response = await sendRequestWithHandler(
        endpoint: '/trips/customer/${trip.value?.id}/cancel',
        method: 'PATCH',
        loadingMessage: 'جاري إلغاء الرحلة...',
      );
      print(response.toString());
      if (response != null && response['status'] == 'success') {
        currentStatus.value = TripStatus.cancelled;
        Get.back();
      } else {
        Get.snackbar(
          "",
          response["message"].toString(),
          backgroundColor: systemColors.error,
          colorText: systemColors.white,
        );
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
