import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/services/api_service.dart';
import 'package:murafiq/customer/trip/screens/trip_waiting_page.dart';
import 'package:murafiq/models/trip.dart';
import '../../../core/utils/systemVarible.dart';

class LocalTripMapController extends GetxController {
  // Constructor with required initial parameters
  LocalTripMapController({
    required this.initialPosition,
    required this.city,
    required this.cityTo,
  });

  // Initial position and city details
  final Position initialPosition;
  final String city;
  final String cityTo;

  // Reactive map-related variables
  final Rx<LatLng> _currentPosition = Rx<LatLng>(const LatLng(0, 0));
  final Rx<LatLng?> _selectedDestination = Rx<LatLng?>(null);
  final RxDouble _tripDistance = 0.0.obs;
  final RxDouble _companyFee = 0.0.obs;
  final RxDouble _tripPrice = 0.0.obs;
  final RxBool _isSatelliteView = false.obs;
  final Rx<DriverType> _selectedDriverType = DriverType.male.obs;
  final Rx<PaymentMethod> _selectedPaymentMethod = PaymentMethod.cash.obs;

  // Map controllers and markers
  late GoogleMapController mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize current position
    _currentPosition.value = LatLng(
      initialPosition.latitude,
      initialPosition.longitude,
    );

    // Add initial current location marker
    _addCurrentLocationMarker();

    // Handle inter-city trip setup
    _setupInterCityTrip();

    // Calculate trip price
    _calculateTripPrice();
  }

  // Add current location marker to the map
  void _addCurrentLocationMarker() {
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentPosition.value,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'موقعك الحالي'),
      ),
    );
  }

  // Setup markers and polyline for inter-city trips
  void _setupInterCityTrip() {
    if (cityTo != city) {
      LatLng targetPoint = _getTargetPointForCity(cityTo);

      // Add destination marker
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: targetPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'وجهتك'),
        ),
      );

      // Add polyline between current location and destination
      polylines.add(
        Polyline(
          polylineId: const PolylineId('trip_route'),
          points: [_currentPosition.value, targetPoint],
          color: systemColors.primary,
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );

      _selectedDestination.value = targetPoint;
      _calculateTripDistance(targetPoint);
      _calculateTripPrice();
    }
  }

  // Get target point based on city name
  LatLng _getTargetPointForCity(String cityName) {
    if (cityName == City.alQatrun.arabicName) return City.alQatrun.location;
    if (cityName == City.alBakhi.arabicName) return City.alBakhi.location;
    if (cityName == City.qasrMasud.arabicName) return City.qasrMasud.location;
    if (cityName == City.alJinsiya.arabicName) return City.alJinsiya.location;
    if (cityName == City.sabha.arabicName) return City.sabha.location;

    // Default fallback
    return City.alQatrun.location;
  }

  // Handle map tap for destination selection
  void onMapTap(LatLng tappedPoint) {
    // Remove existing destination marker
    markers.removeWhere((marker) => marker.markerId.value == 'destination');

    // Add new destination marker
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: tappedPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'وجهتك'),
      ),
    );

    _selectedDestination.value = tappedPoint;

    // Calculate trip distance
    _calculateTripDistance(tappedPoint);

    // Calculate trip price
    _calculateTripPrice();
  }

  // Calculate trip distance
  void _calculateTripDistance(LatLng tappedPoint) {
    _tripDistance.value = Geolocator.distanceBetween(
            _currentPosition.value.latitude,
            _currentPosition.value.longitude,
            tappedPoint.latitude,
            tappedPoint.longitude) /
        1000; // Convert to kilometers
  }

  // Calculate trip price based on distance
  void _calculateTripPrice() {
    final distance = _tripDistance.value;
    if (cityTo == city) {
      if (distance < 0.5) {
        _tripPrice.value = 0;
        _companyFee.value = 0;
      } else if (distance >= 0.5 && distance < 1) {
        _tripPrice.value = 7;
        _companyFee.value = 2;
      } else if (distance >= 1 && distance < 2) {
        _tripPrice.value = 10;
        _companyFee.value = 3;
      } else if (distance >= 2 && distance < 3) {
        _tripPrice.value = 15;
        _companyFee.value = 3;
      } else if (distance >= 3 && distance < 4) {
        _tripPrice.value = 20;
        _companyFee.value = 3;
      } else {
        _tripPrice.value = 25;
        _companyFee.value = 3;
      }
    } else {
      if (cityTo == City.alQatrun.arabicName &&
          city == City.alBakhi.arabicName) {
        _tripPrice.value = 15;
        _companyFee.value = 3;
      }
      if (cityTo == City.alQatrun.arabicName && city == City.sabha.arabicName) {
        _tripPrice.value = 15;
        _companyFee.value = 3;
      }
    }
  }

  // Toggle map type between normal and satellite
  void toggleMapType() {
    _isSatelliteView.toggle();
  }

  // Set driver type
  void setDriverType(DriverType driverType) {
    _selectedDriverType.value = driverType;
  }

  // Set payment method
  void setPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod.value = method;
  }

  // Confirm and create trip
  Future<void> confirmTrip() async {
    // Validate destination selection
    if (_selectedDestination.value == null) {
      Get.snackbar("", "يرجى اختيار وجهتك أولاً",
          backgroundColor: systemColors.error);
      return;
    }

    // Validate trip distance
    if (_tripDistance.value < 0.5) {
      Get.snackbar(
          "", "المسافة قصيرة جدًا. يجب أن تكون المسافة أكثر من 500 متر",
          backgroundColor: systemColors.error, colorText: systemColors.white);
      return;
    }

    // Create trip object
    final trip = Trip(
      startCity: City.values.firstWhere((cityN) => cityN.arabicName == city),
      destinationCity:
          City.values.firstWhere((cityN) => cityN.arabicName == cityTo),
      startLocation: _currentPosition.value,
      destinationLocation: _selectedDestination.value,
      distance: _tripDistance.value,
      estimatedTime: _tripDistance.value.ceil().toInt() * 4,
      price: _tripPrice.value,
      companyFee: _companyFee.value,
      driverType: _selectedDriverType.value,
      tripType: city != cityTo ? TripType.intercity : TripType.local,
      status: TripStatus.searching,
      createdAt: DateTime.now(),
      paymentMethod: _selectedPaymentMethod.value,
    );

    try {
      // Send trip request to backend
      final response = await sendRequestWithHandler(
        endpoint: '/trips/newTrip',
        method: 'POST',
        body: trip.toJson(),
        loadingMessage: 'جاري إنشاء الرحلة...',
      );

      if (response != null) {
        print(response.toString());
        if (response['status'].toString() == 'success') {
          final Trip tripFromResponse = Trip.fromJson(response["data"]["trip"]);
          Get.to(() => TripWaitingPage(trip: tripFromResponse));
        } else if (response["status"] == "fail" &&
            response["message"] != null &&
            response["data"] == null) {
          Get.snackbar(
            "",
            response["message"].toString(),
            backgroundColor: systemColors.error,
            colorText: systemColors.white,
          );
        } else if (response["data"]["trip"] != null) {
          Get.snackbar(
            "",
            response["message"].toString(),
            backgroundColor: systemColors.error,
            colorText: systemColors.white,
          );

          final Trip tripFromResponse = Trip.fromJson(response["data"]["trip"]);

          // Navigate to trip waiting page
          Get.to(() => TripWaitingPage(trip: tripFromResponse));
        }
      }
    } catch (e) {
      Get.snackbar(
        e.toString(),
        "حدث خطأ أثناء إنشاء الرحلة. يرجى المحاولة مرة أخرى",
        backgroundColor: systemColors.error,
        colorText: systemColors.white,
      );
    }
  }

  // Calculate center point between two locations
  LatLng calculateCenterPoint(LatLng point1, LatLng point2) {
    return LatLng(
      (point1.latitude + point2.latitude) / 2,
      (point1.longitude + point2.longitude) / 2,
    );
  }

  // Calculate LatLngBounds for camera positioning
  LatLngBounds calculateLatLngBounds(LatLng point1, LatLng point2) {
    return LatLngBounds(
      southwest: LatLng(
        point1.latitude < point2.latitude ? point1.latitude : point2.latitude,
        point1.longitude < point2.longitude
            ? point1.longitude
            : point2.longitude,
      ),
      northeast: LatLng(
        point1.latitude > point2.latitude ? point1.latitude : point2.latitude,
        point1.longitude > point2.longitude
            ? point1.longitude
            : point2.longitude,
      ),
    );
  }

  // Getters for reactive variables
  LatLng get currentPosition => _currentPosition.value;
  LatLng? get selectedDestination => _selectedDestination.value;
  double get tripDistance => _tripDistance.value;
  double get tripPrice => _tripPrice.value;
  bool get isSatelliteView => _isSatelliteView.value;
  DriverType get selectedDriverType => _selectedDriverType.value;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod.value;
}
