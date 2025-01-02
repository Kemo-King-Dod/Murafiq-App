import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/functions/get_drivers_position.dart';
import 'package:murafiq/core/functions/is_point_inside_polygon.dart';
import 'package:murafiq/core/services/api_service.dart';
import 'package:murafiq/customer/trip/screens/trip_waiting_page.dart';
import 'package:murafiq/models/city.dart';
import 'package:murafiq/models/trip.dart';
import '../../../core/utils/systemVarible.dart';

class LocalTripMapController extends GetxController {
  // Constructor with required initial parameters
  LocalTripMapController({
    required this.initialPosition,
    required this.city,
    required this.cityTo,
    this.lasttrip,
  });

  final cityAndBoundaryController = Get.find<CityAndBoundaryController>();
  final Trip? lasttrip;
  // Initial position and city details
  final LatLng initialPosition;
  final CityAndBoundary city;
  final CityAndBoundary cityTo;
  Set<Polygon> Boundries = {};

  // Reactive map-related variables
  final Rx<LatLng> _currentPosition = Rx<LatLng>(const LatLng(0, 0));
  late final Rx<LatLng?> _selectedDestination;
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

  // Location streaming
  StreamSubscription<Position>? _locationSubscription;

  Trip? waittingTrip;
  RxBool isThereTrip = false.obs;
  BitmapDescriptor? customCarIcon;

  @override
  void onInit() async {
    super.onInit();
    _selectedDestination = Rx<LatLng?>(lasttrip?.destinationLocation ?? null);

    // Load custom car icon
    customCarIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(50, 50)),
      'assets/images/UI/car.jpeg',
    );

    if (lasttrip != null) {
      waittingTrip = lasttrip;
      isThereTrip.value = true;
      // Set initial position from the trip's start location
      _currentPosition.value = lasttrip!.startLocation!;
      _selectedDestination.value = lasttrip!.destinationLocation;
    } else {
      // Initialize current position from provided initial position
      _currentPosition.value = LatLng(
        initialPosition.latitude,
        initialPosition.longitude,
      );
    }

    // Start location streaming
    _startLocationStream();

    // Add initial current location marker
    _addCurrentLocationMarker();

    // Handle inter-city trip setup
    if (cityTo != city) {
      _setupInterCityTrip();
    }

    // Setup boundaries
    _setupBoundaries();

    // Calculate trip price
    _calculateTripPrice();

    // If there's an active trip, fit the map to show both points
    if (lasttrip != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            calculateCenterPoint(
              lasttrip!.startLocation!,
              lasttrip!.destinationLocation!,
            ),
            15, // Adjusted zoom level to make the map closer
          ),
        );
      });
    }
  }

  void _startLocationStream() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        await Geolocator.openLocationSettings();
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      // Start location stream
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) async {
        print("is streaming: ${position.latitude}, ${position.longitude}");

        // Remove old current location marker
        markers.removeWhere(
            (marker) => marker.markerId.value == 'current_location');

        _currentPosition.value = LatLng(position.latitude, position.longitude);
        _setupInterCityTrip();

        _addCurrentLocationMarker();

        final response = await GetDriversPosition.getDriversPOS(
            pos: LatLng(position.latitude, position.longitude));
        if (response != null) {
          if (response["data"]["driversPositions"] is List) {
            markers.removeWhere((marker) =>
                marker.markerId.value != 'current_location' &&
                marker.markerId.value != 'destination');
            response["data"]["driversPositions"].forEach((position) {
              print(position);
              markers.add(
                Marker(
                  markerId: MarkerId(position["_id"].toString()),
                  position: LatLng(position["position"]["latitude"],
                      position["position"]["longitude"]),
                  icon: customCarIcon ??
                      BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueCyan),
                  infoWindow: const InfoWindow(title: 'موقع السائق'),
                ),
              );
            });
          }
        }

        if (_selectedDestination.value != null) {
          _calculateTripDistance(_selectedDestination.value!);
        }

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            _currentPosition.value,
            15, // Adjusted zoom level to make the map closer
          ),
        );
      });
    } catch (e) {
      print('Error in location stream: $e');
    }
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    super.onClose();
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
      // LatLng targetPoint = _getTargetPointForCity(cityTo);
      LatLng targetPoint = cityTo.center;

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
      Future.delayed(
          const Duration(seconds: 1),
          () => polylines.add(
                Polyline(
                  polylineId: const PolylineId('trip_route'),
                  points: [_currentPosition.value, targetPoint],
                  color: systemColors.primary,
                  width: 5,
                  patterns: [PatternItem.dash(20), PatternItem.gap(10)],
                ),
              ));

      _selectedDestination.value = targetPoint;
      _calculateTripDistance(targetPoint);
      _calculateTripPrice();
    }
  }

  // Handle map tap for destination selection
  void onMapTap(LatLng tappedPoint) {
    // Remove existing destination marker
    markers.removeWhere((marker) => marker.markerId.value == 'destination');
    if (!isPointInsidePolygons(tappedPoint, cityTo.boundary.toSet())) return;
    // Add new destination marker
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: tappedPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
      _tripPrice.value =
          cityAndBoundaryController.calculatePriceToDiffrentCities(
              city: city.Englishname, cityTo: cityTo.Englishname);
      _companyFee.value = 5.0;

      // if (cityTo == City.alQatrun.arabicName &&
      //     city == City.alBakhi.arabicName) {
      //   _tripPrice.value = 15;
      //   _companyFee.value = 3;
      // }
      // if (cityTo == City.alQatrun.arabicName && city == City.sabha.arabicName) {
      //   _tripPrice.value = 15;
      //   _companyFee.value = 3;
      // }
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
      startCity: city.Arabicname,
      destinationCity: cityTo.Arabicname,
      startLocation: _currentPosition.value,
      destinationLocation: _selectedDestination.value,
      distance: _tripDistance.value,
      estimatedTime: (_tripDistance.value / 10).ceil() * 10, // Minutes
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
          waittingTrip = tripFromResponse;
          isThereTrip.value = true;
          // Get.to(() => TripWaitingPage(trip: tripFromResponse));
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
          waittingTrip = tripFromResponse;
          isThereTrip.value = true;
          // Navigate to trip waiting page
          // Get.to(() => TripWaitingPage(trip: tripFromResponse));
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

  void _setupBoundaries() {
    Boundries = {
      Polygon(
        polygonId: PolygonId(city.Arabicname),
        points: city.boundary,
        fillColor: systemColors.primary.withValues(alpha: 0.001),
        strokeColor: systemColors.primary,
        strokeWidth: 1,
      ),
      Polygon(
        polygonId: PolygonId(cityTo.Arabicname),
        points: cityTo.boundary,
        fillColor: systemColors.sucsses.withValues(alpha: 0.001),
        strokeColor: systemColors.sucsses,
        strokeWidth: 1,
      ),
    };
  }
}
