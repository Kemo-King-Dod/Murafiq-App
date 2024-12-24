import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/main.dart';
import 'package:murafiq/models/trip.dart';
import 'package:murafiq/driver/public/screens/driver_home_page.dart';

typedef PaintFunction = void Function(Canvas canvas, Size size);

class ActiveTripController extends GetxController {
  Rx<Trip> trip;
  Timer? _statusCheckTimer;
  Rx<BitmapDescriptor> carIcon = BitmapDescriptor.defaultMarker.obs;
  Rx<BitmapDescriptor> personIcon = BitmapDescriptor.defaultMarker.obs;
  Future<BitmapDescriptor> loadAssetIcon(String path,
      {int width = 100, int height = 100}) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List originalBytes = data.buffer.asUint8List();

    // Decode the image
    final ui.Codec codec = await ui.instantiateImageCodec(
      originalBytes,
      targetWidth: width,
      targetHeight: height,
    );

    // Get the first frame
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    codec.dispose();
    // Convert the resized image to byte data
    final ByteData? resizedByteData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

    if (resizedByteData != null) {
      final Uint8List resizedBytes = resizedByteData.buffer.asUint8List();
      return BitmapDescriptor.fromBytes(resizedBytes);
    } else {
      // Fallback to original if resizing fails
      return BitmapDescriptor.fromBytes(originalBytes);
    }
  }

  Future<void> loadCustomIcons() async {
    carIcon.value = await loadAssetIcon('assets/images/icons/car.png',
        width: 100, // Specify width
        height: 100 // Specify height
        );
    personIcon.value = await loadAssetIcon('assets/images/icons/person.png',
        width: 100, // Specify width
        height: 100 // Specify height
        );

    update();
  }

  ActiveTripController({required this.trip});
  @override
  void onInit() {
    super.onInit();
    loadCustomIcons().then((_) {});
    shared!.setBool("driver_has_active_trip", true);
    startStatusChecking();
  }

  void startStatusChecking() {
    getTripStatus();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      getTripStatus();
    });
  }

  Future<void> getTripStatus() async {
    final response = await sendRequestWithHandler(
      endpoint: '/trips/driver/status',
      method: 'GET',
    );
    print(response.toString());
    if (response != null && response['data'] != null) {
      final updatedTrip = Trip.fromJson(response['data']['trip']);
      trip.value = updatedTrip;
      // إيقاف التحقق إذا وصلت الرحلة إلى حالة نهائية
      if (updatedTrip.status == TripStatus.completed ||
          updatedTrip.status == TripStatus.cancelled) {
        _statusCheckTimer?.cancel();

        shared!.setBool("driver_has_active_trip", false);
        Get.offAll(DriverHomePage());
      }
    }
  }
}
