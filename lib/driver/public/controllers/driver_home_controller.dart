import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/functions/GelocatorFun.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/controllers/socket_controller.dart';
import 'package:murafiq/core/services/trip_service.dart';
import 'package:murafiq/driver/public/screens/active_trip_page.dart';
import 'package:murafiq/driver/public/screens/driver_home_page.dart';
import 'package:murafiq/main.dart';
import 'package:murafiq/models/trip.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverHomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxBool isAvailable = false.obs;
  final RxBool isSocketConnected = false.obs;
  final RxList<Trip> availableTrips = <Trip>[].obs;
  String? city;
  LatLng? currentPosition;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  final socketController = Get.find<SocketController>();

  // Getters للوصول إلى الرسوم المتحركة
  Animation<double> get scaleAnimation => _scaleAnimation;
  Animation<double> get opacityAnimation => _opacityAnimation;
  AnimationController get animationController => _animationController;

  @override
  void onInit() {
    super.onInit();
    checkAcceptedTrip();
    _initializeAnimations();
  }

  Future<void> connectToSocket() async {
    await socketController.initializeSocket();
    socketController.socket.socket!.on("update-driver", (data) {
      if (data["func"] == "new-trip" && city != null) {
        _checkForTrips(currentPosition);
      }
    });

    socketController.socket.socket!.on("location-request", (data) {
      if (isAvailable.value) {
        _getCurrentLocation();
      }
    });
  }

  refreshTrips() {
    socketController.socket
        .updateDriver(data: {"func": "new-trip", "tripId": "dsfjssjodfjowejf"});
  }

  void disconnectFromSocket() {
    socketController.socket.socket!.disconnect();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void checkAcceptedTrip() async {
    var hasActiveTrip = shared!.getBool("driver_has_active_trip");
    if (hasActiveTrip == true) {
      try {
        final response = await sendRequestWithHandler(
          endpoint: '/trips/driver/status',
          method: 'GET',
        );

        if (response != null && response['data'] != null) {
          final acceptedTrip = Trip.fromJson(response['data']['trip']);

          if (acceptedTrip.status == TripStatus.accepted ||
              acceptedTrip.status == TripStatus.arrived) {
            Get.offAll(() => ActiveTripPage(trip: acceptedTrip));
          } else if (acceptedTrip.status == TripStatus.completed ||
              acceptedTrip.status == TripStatus.cancelled) {
            shared!.setBool("driver_has_active_trip", false);
            Get.offAll(DriverHomePage());
          }
        } else {
          shared!.setBool("driver_has_active_trip", false);
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  void toggleAvailability(bool value) async {
    await Future.delayed(Duration(milliseconds: 300));
    if (value) {
      final hasPermission =
          await LocationService.handleLocationPermission(isDriver: true);

      if (!hasPermission) return;
      await connectToSocket();
      if (socketController.socket.isConnected.value) {
        isAvailable.value = true;
        _getCurrentLocation();
      } else {
        Get.snackbar('خطا', "حدث خطأ ");
      }
    } else {
      socketController.socket.socket!.disconnect();
      isAvailable.value = false;
      availableTrips.clear();
    }
  }

  void _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition = LatLng(position.latitude, position.longitude);
      city = await LocationService.getCityName(
          lat: position.latitude, lng: position.longitude);
      _checkForTrips(currentPosition);

      // Emit location to server
      socketController.socket.socket!.emit("driver-location", {
        "latitude": position.latitude,
        "longitude": position.longitude,
        "city": city
      });
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ أثناء تحديد الموقع");
    }
  }

  Future<void> _checkForTrips(LatLng? currentPosition) async {
    if (!isAvailable.value) return;
    printer.w("currentposition:$currentPosition");
    if (TripService.driverStatus.value == "blocked") {
      return;
    }

    final trips =
        await TripService.getAvailableTrips(city: city, point: currentPosition);
    printer.w("rechecking trips: ${trips.length}");

    availableTrips.value = trips;
  }

  Future<void> acceptTrip(Trip trip) async {
    final success = await TripService.acceptTrip(trip.id!);

    if (success) {
      // إرسال إشعار للمستخدم عبر السوكت مع معرف الرحلة
      // socketController.updateUser("accept-trip", data: {"tripId": trip.id});
      printer.w("tripId:${trip.id}");
      socketController.socket.updateUser("tripStatus",
          data: {"func": "tripStatus", "tripId": trip.id});

      // حذف الرحلة من القائمة
      availableTrips.remove(trip);

      // الانتقال إلى صفحة الرحلة النشطة
      Get.offAll(() => ActiveTripPage(trip: trip));
    }
  }

  Future<void> rejectTrip(Trip trip) async {
    final success = await TripService.rejectTrip(trip.id!);
    if (success) {
      Get.snackbar(
        'تم',
        'تم رفض الرحلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      availableTrips.remove(trip);
    }
  }

  void openMapRoute(Trip trip) {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${trip.startLocation!.latitude},${trip.startLocation!.longitude}'
      '&destination=${trip.destinationLocation!.latitude},${trip.destinationLocation!.longitude}'
      '&travelmode=driving',
    );
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }
}
