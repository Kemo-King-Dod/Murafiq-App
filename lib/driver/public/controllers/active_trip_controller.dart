import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/controllers/socket_controller.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/main.dart';
import 'package:murafiq/models/trip.dart';
import 'package:murafiq/driver/public/screens/driver_home_page.dart';

typedef PaintFunction = void Function(Canvas canvas, Size size);

class ActiveTripController extends GetxController {
  final Rx<Trip> trip;
  final codeController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isCodeVerified = false.obs;
  final Rx<BitmapDescriptor> personIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure).obs;
  final RxDouble sheetPosition = 0.4.obs;

  final socketController = Get.find<SocketController>();

  Future<void> connectToSocket() async {
    await socketController.socket.connectAndListen();
    socketController.socket.socket!.on("update-driver", (data) {
      getTripStatus();
    });
  }

  void updateSheetPosition(double position) {
    sheetPosition.value = position;
  }

  Future<void> loadCustomIcons() async {
    personIcon.value = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(50, 50)),
        "assets/images/icons/person.png");

    update();
  }

  ActiveTripController({required this.trip});
  @override
  void onInit() async {
    super.onInit();
    loadCustomIcons().then((_) {});
    shared!.setBool("driver_has_active_trip", true);

    // Initialize isCodeVerified based on trip status

    await getTripStatus();
    isCodeVerified.value = trip.value.status == TripStatus.arrived;
  }

  @override
  void onReady() async {
    await connectToSocket();
  }

  Future<void> getTripStatus() async {
    final response = await sendRequestWithHandler(
      endpoint: '/trips/driver/status',
      method: 'GET',
    );
    print("updatedTrip is :" + response.toString());

    if (response != null && response['data'] != null) {
      final updatedTrip = Trip.fromJson(response['data']['trip']);
      trip.value = updatedTrip;
      // إيقاف التحقق إذا وصلت الرحلة إلى حالة نهائية
      if (updatedTrip.status == TripStatus.completed ||
          updatedTrip.status == TripStatus.cancelled) {
        shared!.setBool("driver_has_active_trip", false);
        Get.offAll(DriverHomePage());
      }
    }
  }

  Future<void> verifyTripCode(String code) async {
    try {
      isLoading.value = true;
      final response = await sendRequestWithHandler(
        endpoint: '/trips/driver/${trip.value.id}/verify-code',
        method: 'patch',
        body: {'tripCode': code},
        loadingMessage: 'جاري التحقق من الرمز...',
      );

      if (response != null && response['status'] == 'success') {
        isCodeVerified.value = true;
        printer.w("tripId:${trip.value.id}");
        socketController.socket.updateUser("tripStatus",
            data: {"func": "tripStatus", "tripId": trip.value.id});
        // تحديث حالة الرحلة باستخدام copyWith
        trip.value = trip.value.copyWith(status: TripStatus.arrived);
        Get.snackbar(
          "نجاح",
          "تم التحقق من الرمز بنجاح",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelTrip() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/trips/driver/${trip.value.id}/cancel',
        method: 'PATCH',
        loadingMessage: 'جاري إلغاء الرحلة...',
      );
      if (response != null && response['status'] == 'success') {
         printer.w("tripId:${trip.value.id}");
      socketController.socket.updateUser("tripStatus",
          data: {"func": "tripStatus", "tripId": trip.value.id});
        shared!.setBool("driver_has_active_trip", false);
        Get.offAll(DriverHomePage());
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

  @override
  void onClose() {
    socketController.socket.dispose();
    super.onClose();
  }
}
