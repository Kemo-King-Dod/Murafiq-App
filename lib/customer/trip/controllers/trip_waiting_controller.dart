import 'dart:async';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:murafiq/core/controllers/socket_controller.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/functions/socket_services.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/customer/public/screens/customer_home_page.dart';
import 'package:murafiq/main.dart';
import 'package:murafiq/models/driver.dart';
import 'package:murafiq/models/trip.dart';

class TripWaitingController extends GetxController {
  final Rx<Trip?> trip = Rx<Trip?>(null);
  final Rx<Driver?> driver = Rx<Driver?>(null);
  final Rx<TripStatus> currentStatus = Rx<TripStatus>(TripStatus.searching);
  Timer? _statusCheckTimer;
  final SocketController socketController = Get.find<SocketController>();

  @override
  void onInit() {
    super.onInit();
    startStatusChecking();
    shared!.setBool("has_active_trip", true);
    connectToSocket();
  }

  @override
  void onClose() {
    _statusCheckTimer?.cancel();
    socketController.socket.dispose();
    super.onClose();
  }

  void startStatusChecking() {
    // التحقق الأولي من حالة الرحلة
    checkTripStatus();

    // بدء التحقق الدوري كل 5 ثواني
    // _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
    //   checkTripStatus();
    // });
  }

  Future<void> checkTripStatus() async {
    try {
      printer.f('checkTripStatus');
      final response = await sendRequestWithHandler(
        endpoint: '/trips/status',
        method: 'GET',
      );
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
            Get.offAll(() => CustomerHomePage());
          }
        }
      }
    } catch (e) {
      print('Error checking trip status: $e');
    }
  }

  void connectToSocket() async {
    await socketController.socket.connectAndListen();

    socketController.socket.socket!.on('tripStatus', (data) {
      checkTripStatus();
    });
  }

  Future<void> cancelTrip() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/trips/customer/${trip.value?.id}/cancel',
        method: 'PATCH',
        loadingMessage: 'جاري إلغاء الرحلة...'.tr,
      );
      if (response != null && response['status'] == 'success') {
        currentStatus.value = TripStatus.cancelled;
        shared!.setBool("has_active_trip", false);
        Get.offAll(() => const CustomerHomePage());
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
