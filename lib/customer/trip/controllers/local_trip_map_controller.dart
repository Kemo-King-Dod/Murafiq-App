import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/controllers/socket_controller.dart';
import 'package:murafiq/core/functions/GelocatorFun.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/functions/getPrice.dart';
import 'package:murafiq/core/functions/get_drivers_position.dart';
import 'package:murafiq/core/functions/is_point_inside_polygon.dart';
import 'package:murafiq/core/functions/socket_services.dart';
import 'package:murafiq/main.dart';
import 'package:murafiq/models/city.dart';
import 'package:murafiq/models/trip.dart';
import '../../../core/utils/systemVarible.dart';
import "package:http/http.dart" as http;

class LocalTripMapController extends GetxController {
  // Constructor with required initial parameters
  LocalTripMapController({
    required this.initialPosition,
    required this.city,
    required this.cityTo,
    this.lasttrip,
  });

  SocketController socketController = Get.find<SocketController>();

  final cityAndBoundaryController = Get.find<CityAndBoundaryController>();
  final Trip? lasttrip;
  static const String _cacheKeyPrefix = 'dir_cache_';
  static const int _cacheValidityHours = 24;
  RxString time = "".obs;
  RxString distenance = "".obs;
  // Initial position and city details
  final LatLng initialPosition;
  final CityAndBoundary city;
  final CityAndBoundary cityTo;
  Set<Polygon> Boundries = {};

  // Reactive map-related variables
  final Rx<LatLng> _currentPosition = Rx<LatLng>(const LatLng(0, 0));
  Rx<LatLng?> _selectedDestination = Rx<LatLng?>(LatLng(0, 0));
  final RxDouble _tripDistance = 0.0.obs;
  final RxDouble _companyFee = 0.0.obs;
  final RxDouble _tripPrice = 0.0.obs;
  final RxBool _isSatelliteView = false.obs;
  final Rx<DriverType> _selectedDriverType = DriverType.male.obs;
  final Rx<PaymentMethod> _selectedPaymentMethod = PaymentMethod.cash.obs;

  // Map controllers and markers
  late GoogleMapController mapController;
  final RxSet<Marker> _markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  // Getter for markers
  Set<Marker> get markers => _markers.value;

  // Location streaming
  Timer? _locationTimer;
  Timer? _driversUpdateTimer;
  Position? _lastPosition;
  StreamSubscription<Position>? _locationSubscription;

  Trip? waittingTrip;
  RxBool isThereTrip = false.obs;
  RxDouble sheetPosition = 0.4.obs;
  BitmapDescriptor? customCarIcon;
  BitmapDescriptor? carInThisTrip;
  BitmapDescriptor? _tripDriverIcon;
  BitmapDescriptor? _availableDriverIcon;

  void updateSheetPosition(double position) {
    sheetPosition.value = position;
  }

  RxBool isReady = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await _loadIcons();
    await socketController.socket.connectAndListen();

    _selectedDestination = Rx<LatLng?>(lasttrip?.destinationLocation ?? null);

    // Load custom car icon
    customCarIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(50, 50)),
      'assets/images/UI/car.jpeg',
    );
    carInThisTrip = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(50, 50)),
      'assets/images/UI/caryellow.png',
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
      setupMarkersAndDirections(
          storePos: lasttrip!.startLocation!,
          customerPos: lasttrip!.destinationLocation!);

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

  Future<void> _loadIcons() async {
    try {
      _tripDriverIcon = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(50, 50)),
          "assets/images/UI/caryellow.png");
      _availableDriverIcon = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(50, 50)),
          "assets/images/UI/car.jpeg");
    } catch (e) {
      print("Error loading icons: $e");
    }
  }

  void _startLocationStream() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        Get.snackbar(
          "تنبيه",
          "خدمة تحديد الموقع غير مفعلة. يرجى تفعيلها للمتابعة",
          backgroundColor: systemColors.error,
          colorText: systemColors.white,
          duration: const Duration(seconds: 5),
          onTap: (_) async {
            await Geolocator.openLocationSettings();
          },
        );
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await LocationService.handleLocationPermission(isDriver: false);
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          Get.snackbar(
            "تنبيه",
            "لا يمكن متابعة الرحلة بدون صلاحية الموقع",
            backgroundColor: systemColors.error,
            colorText: systemColors.white,
            duration: const Duration(seconds: 5),
          );
          Get.back(); // Return to previous screen
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        Get.snackbar(
          "تنبيه",
          "تم رفض الوصول إلى الموقع بشكل دائم. يرجى تفعيل الصلاحية من إعدادات التطبيق للمتابعة",
          backgroundColor: systemColors.error,
          colorText: systemColors.white,
          duration: const Duration(seconds: 5),
          onTap: (_) async {
            await Geolocator.openAppSettings();
          },
        );
        Get.back(); // Return to previous screen
        return;
      }

      // Function to update location and markers
      void updateLocationAndMarkers(Position position) async {
        print("Position updated: ${position.latitude}, ${position.longitude}");

        // Remove old current location marker
        _markers.removeWhere(
            (marker) => marker.markerId.value == 'current_location');

        _currentPosition.value = LatLng(position.latitude, position.longitude);
        _setupInterCityTrip();

        _addCurrentLocationMarker();

        if (_selectedDestination.value != null) {
          _calculateTripDistance(_selectedDestination.value!);
        }

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            _currentPosition.value,
            15,
          ),
        );
      }

      // Start location updates based on movement (10 meters)
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        updateLocationAndMarkers(position);
      }, onError: (error) {
        print('Error in location stream: $error');
        Get.snackbar(
          "تنبيه",
          "حدث خطأ في تحديث الموقع. يرجى التأكد من تفعيل خدمة الموقع",
          backgroundColor: systemColors.error,
          colorText: systemColors.white,
          duration: const Duration(seconds: 5),
        );
      });
    } catch (e) {
      print('Error in location updates: $e');
      Get.snackbar(
        "تنبيه",
        "حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى",
        backgroundColor: systemColors.error,
        colorText: systemColors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  void onClose() {
    _locationTimer?.cancel();
    _driversUpdateTimer?.cancel();
    _locationSubscription?.cancel();
    super.onClose();
  }

  // Add current location marker to the map
  void _addCurrentLocationMarker() {
    _markers.add(
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
      isReady.value = true;
      print("isReady: $isReady");
      // LatLng targetPoint = _getTargetPointForCity(cityTo);
      LatLng targetPoint = cityTo.center;

      // Add destination marker
      _markers.add(
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
  Future<void> onMapTap(LatLng tappedPoint) async {
    try {
      isReady.value = false;
      if (!isPointInsidePolygons(tappedPoint, cityTo.boundary.toSet())) {
        Get.snackbar(
          "",
          "يرجى اختيار نقطة داخل حدود المدينة",
          backgroundColor: systemColors.error,
          colorText: systemColors.white,
        );
        return;
      }

      // Create a new set with existing markers excluding the destination
      final newMarkers = _markers.value.toSet()
        ..removeWhere((marker) => marker.markerId.value == 'destination');

      // Add new destination marker to the set
      newMarkers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: tappedPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'وجهتك'),
        ),
      );

      // Update the markers reactively
      _markers.value = newMarkers;
      _selectedDestination.value = tappedPoint;

      // Calculate trip distance
      _calculateTripDistance(tappedPoint);

      // Calculate trip price and wait for it to complete
      bool priceCalculated = await _calculateTripPrice();
      if (!priceCalculated) {
        Get.snackbar(
          "",
          "حدث خطأ في حساب السعر. يرجى المحاولة مرة أخرى",
          backgroundColor: systemColors.error,
          colorText: systemColors.white,
        );
        return;
      }
    } catch (e) {
      print("Error in onMapTap: $e");
      isReady.value = false;
      Get.snackbar(
        "",
        "حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى",
        backgroundColor: systemColors.error,
        colorText: systemColors.white,
      );
    }
  }

  // Confirm and create trip
  Future<void> confirmTrip() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      // Ensure we have a valid destination
      if (_selectedDestination.value == null) {
        Get.snackbar("", "يرجى اختيار وجهتك أولاً".tr,
            backgroundColor: systemColors.error, colorText: systemColors.white);
        return;
      }

      // Ensure price is calculated and valid
      if (!isReady.value || _tripPrice.value <= 0) {
        bool priceCalculated = await _calculateTripPrice();
        if (!priceCalculated) {
          Get.snackbar(
            "",
            "حدث خطأ في حساب السعر. يرجى المحاولة مرة أخرى".tr,
            backgroundColor: systemColors.error,
            colorText: systemColors.white,
          );
          return;
        }
      }

      // Validate trip distance
      if (_tripDistance.value < 0.5) {
        Get.snackbar(
            "", "المسافة قصيرة جدًا. يجب أن تكون المسافة أكثر من 500 متر".tr,
            backgroundColor: systemColors.error, colorText: systemColors.white);
        return;
      }

      // Double check price is valid
      if (_tripPrice.value <= 0) {
        Get.snackbar(
          "",
          "لم يتم حساب السعر بشكل صحيح. يرجى المحاولة مرة أخرى".tr,
          backgroundColor: systemColors.error,
          colorText: systemColors.white,
        );
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
          loadingMessage: 'جاري إنشاء الرحلة...'.tr,
        );
        socketController.socket.updateDriver(data: {
          "func": "new-trip",
          "tripId": response["data"]["trip"]["_id"]
        });

        if (response != null) {
          if (response['status'].toString() == 'success') {
            final Trip tripFromResponse =
                Trip.fromJson(response["data"]["trip"]);
            waittingTrip = tripFromResponse;
            isThereTrip.value = true;
            setupMarkersAndDirections(
                storePos: _currentPosition.value,
                customerPos: _selectedDestination.value!);
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

            final Trip tripFromResponse =
                Trip.fromJson(response["data"]["trip"]);
            waittingTrip = tripFromResponse;
            isThereTrip.value = true;
            // Navigate to trip waiting page
            // Get.to(() => TripWaitingPage(trip: tripFromResponse));
          }
        }
      } catch (e) {
        Get.snackbar(
          e.toString(),
          "حدث خطأ أثناء إنشاء الرحلة. يرجى المحاولة مرة أخرى".tr,
          backgroundColor: systemColors.error,
          colorText: systemColors.white,
        );
      }
    } catch (e) {
      print("Error in confirmTrip: $e");
      Get.snackbar(
        "",
        "حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى",
        backgroundColor: systemColors.error,
        colorText: systemColors.white,
      );
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
  Future<bool> _calculateTripPrice() async {
    try {
      isReady.value = false;
      final distance = _tripDistance.value;
      if (cityTo == city) {
        print("Same city");
        var price = await GetPrice.getPrice(distance: distance);
        _tripPrice.value = price["_tripPrice"].toDouble();
        _companyFee.value = price["_companyFee"].toDouble();
      } else {
        var price =
            await cityAndBoundaryController.calculatePriceToDiffrentCities(
                city: city.Englishname, cityTo: cityTo.Englishname);
        print("price:$price");
        _tripPrice.value = price["price"].toDouble();
        _companyFee.value = price["_companyFee"].toDouble();
      }
      isReady.value = true;
      return true;
    } catch (e) {
      print("Error calculating price: $e");
      isReady.value = false;
      return false;
    }
  }

  Future<void> setupMarkersAndDirections({
    required LatLng storePos,
    required LatLng customerPos,
  }) async {
    printer.w("setupMarkersAndDirections");
    // تنظيف البيانات القديمة
    markers.clear();
    polylines.clear();

    // إضافة العلامات الأساسية
    markers.addAll([
      Marker(
        markerId: const MarkerId("store_marker"),
        position: storePos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId("customer_marker"),
        position: customerPos,
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      )
    ]);

    // جلب بيانات الاتجاهات
    final dirData = await _getCachedDirections(storePos, customerPos);
    if (dirData == null) return;
    printer.f("dirData: " + dirData.toString());
    time.value = dirData['duration'];
    distenance.value = dirData['distance'];
    // إضافة الخطوط
    polylines.add(Polyline(
      polylineId: const PolylineId('main_route'),
      color: AppColors.primary,
      width: 3,
      points: dirData['points'] as List<LatLng>,
      geodesic: true,
    ));
    update(['map']);
    printer.w("setupMarkersAndDirections done");
  }

  Future<Map<String, dynamic>?> _getCachedDirections(
      LatLng start, LatLng end) async {
    final cacheKey =
        '${_cacheKeyPrefix}${start.latitude},${start.longitude}_${end.latitude},${end.longitude}';

    // التحقق من وجود بيانات حديثة
    if (shared!.containsKey(cacheKey)) {
      final cached = json.decode(shared!.getString(cacheKey)!);
      final timestamp = DateTime.parse(cached['timestamp']);

      if (DateTime.now().difference(timestamp).inHours < _cacheValidityHours) {
        return {
          'distance': cached['distance'],
          'duration': cached['duration'],
          'points': (cached['points'] as List)
              .map((e) => LatLng(e[0], e[1]))
              .toList(),
        };
      }
    }

    // جلب بيانات جديدة من API
    final freshData = await _fetchDirectionsFromAPI(start, end);
    if (freshData == null) return null;

    // تخزين البيانات الجديدة
    await shared!.setString(
        cacheKey,
        json.encode({
          ...freshData,
          'timestamp': DateTime.now().toIso8601String(),
          'points': freshData['points']!
              .map((p) => [p.latitude, p.longitude])
              .toList(),
        }));

    return freshData;
  }

  Future<Map<String, dynamic>?> _fetchDirectionsFromAPI(
      LatLng start, LatLng end) async {
    const apiKey = 'AIzaSyAg6MAVrLL6fLpmc-ZVXIUtMuGTX0lD0dg';
    final url =
        Uri.parse('https://maps.googleapis.com/maps/api/directions/json?'
            'origin=${start.latitude},${start.longitude}'
            '&destination=${end.latitude},${end.longitude}'
            '&mode=driving'
            '&alternatives=false'
            '&key=$apiKey');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return null;

      final route = data['routes'][0] as Map<String, dynamic>;
      final leg = route['legs'][0] as Map<String, dynamic>;

      return {
        'distance': leg['distance']['text'],
        'duration': leg['duration']['text'],
        'points':
            _decodePolyline(route['overview_polyline']['points'] as String),
      };
    } catch (e) {
      print('Error fetching directions: $e');
      return null;
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      // فك تشفير خط العرض
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      // فك تشفير خط الطول
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // Getters for reactive variables
  String get userGender => shared!.getString("user_gender") ?? "";
  LatLng get currentPosition => _currentPosition.value;
  LatLng? get selectedDestination => _selectedDestination.value;
  double get tripDistance => _tripDistance.value;
  double get tripPrice => _tripPrice.value;
  bool get isSatelliteView => _isSatelliteView.value;
  DriverType get selectedDriverType => _selectedDriverType.value;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod.value;
}
