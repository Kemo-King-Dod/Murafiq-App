import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/features/customer/screens/trip_waiting_page.dart';
import 'package:murafiq/main.dart';
import 'package:murafiq/models/trip.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/systemVarible.dart';
import '../../../core/utils/text_styles.dart';

class LocalTripMapPage extends StatefulWidget {
  final Position initialPosition;

  const LocalTripMapPage({Key? key, required this.initialPosition})
      : super(key: key);

  @override
  _LocalTripMapPageState createState() => _LocalTripMapPageState();
}

class _LocalTripMapPageState extends State<LocalTripMapPage> {
  late GoogleMapController _mapController;
  late LatLng _currentPosition;
  LatLng? _selectedDestination;
  double _tripDistance = 0.0;
  double _companyFee = 0.0;
  double _tripPrice = 0.0;
  bool _isSatelliteView = false;
  DriverType _selectedDriverType = DriverType.male;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(
        widget.initialPosition.latitude, widget.initialPosition.longitude);

    // إضافة علامة للموقع الحالي
    _markers.add(Marker(
      markerId: const MarkerId('current_location'),
      position: _currentPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(title: 'موقعك الحالي'),
    ));
  }

  void _onMapTap(LatLng tappedPoint) {
    setState(() {
      // إزالة العلامة القديمة للوجهة إن وجدت
      _markers.removeWhere((marker) => marker.markerId.value == 'destination');

      // إضافة علامة جديدة للوجهة
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: tappedPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'وجهتك'),
      ));

      _selectedDestination = tappedPoint;

      // حساب المسافة
      _tripDistance = Geolocator.distanceBetween(
              _currentPosition.latitude,
              _currentPosition.longitude,
              tappedPoint.latitude,
              tappedPoint.longitude) /
          1000; // تحويل إلى كيلومتر

      // حساب السعر حسب المسافة
      if (_tripDistance < 0.5) {
        _tripPrice = 0; // ممنوع لقصر المسافة
      } else if (_tripDistance >= 0.5 && _tripDistance < 1) {
        _tripPrice = 7;
        _companyFee = 2;
      } else if (_tripDistance >= 1 && _tripDistance < 2) {
        _tripPrice = 10;
        _companyFee = 3;
      } else if (_tripDistance >= 2 && _tripDistance < 3) {
        _tripPrice = 15;
        _companyFee = 3;
      } else if (_tripDistance >= 3 && _tripDistance < 4) {
        _tripPrice = 20;
        _companyFee = 3;
      } else {
        _tripPrice = 25;
        _companyFee = 3;
      }

      // تحريك الكاميرا للوجهة المحددة
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: tappedPoint,
            zoom: 18.0,
          ),
        ),
      );
    });
  }

  void _confirmTrip(
      {required LatLng currentPosition,
      required LatLng? selectedDestination,
      required double tripDistance,
      required double tripPrice,
      required DriverType selectedDriverType}) async {
    if (_selectedDestination == null) {
      Get.snackbar("", "يرجى اختيار وجهتك أولاً",
          backgroundColor: systemColors.error);
      return;
    }

    if (_tripDistance < 0.5) {
      Get.snackbar(
          "", "المسافة قصيرة جدًا. يجب أن تكون المسافة أكثر من 500 متر",
          backgroundColor: systemColors.error, colorText: systemColors.white);
      return;
    }

    final trip = Trip(
      startCity: City.alQatrun,
      destinationCity: City.alQatrun,
      startLocation: currentPosition,
      destinationLocation: selectedDestination,
      distance: tripDistance,
      estimatedTime: _tripDistance.toInt() * 4,
      price: tripPrice,
      companyFee: _companyFee,
      driverType: selectedDriverType,
      tripType: TripType.local,
      status: TripStatus.searching,
      createdAt: DateTime.now(),
    );

    try {
      // إرسال الرحلة إلى الباك اند
      final response = await sendRequestWithHandler(
        endpoint: '/trips/newTrip',
        method: 'POST',
        body: trip.toJson(),
        loadingMessage: 'جاري إنشاء الرحلة...',
      );

      if (response != null) {
        Get.snackbar("respons", response.toString(),
            backgroundColor: systemColors.primary,
            colorText: systemColors.white);
        // تحديث معرف الرحلة من الاستجابة

        // الانتقال لصفحة انتظار الرحلة
        Get.to(() => TripWaitingPage(
          trip:trip
          
            ));
      }
    } catch (e) {
      Get.snackbar(
        "",
        "حدث خطأ أثناء إنشاء الرحلة. يرجى المحاولة مرة أخرى",
        backgroundColor: systemColors.error,
        colorText: systemColors.white,
      );
    }
  }

  void _toggleMapType() {
    setState(() {
      _isSatelliteView = !_isSatelliteView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: Get.width,
            height: Get.height,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 15,
              ),
              mapType: _isSatelliteView ? MapType.satellite : MapType.normal,
              markers: _markers,
              onTap: _onMapTap,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),

          // زر العودة
          Positioned(
            top: 20,
            right: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: systemColors.primary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'العودة',
                ),
              ),
            ),
          ),

          // زر تبديل نوع الخريطة
          Positioned(
            top: 20,
            left: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: systemColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isSatelliteView ? Icons.map : Icons.satellite_alt_outlined,
                    color: systemColors.white,
                  ),
                  onPressed: _toggleMapType,
                  tooltip: _isSatelliteView
                      ? 'عرض الخريطة العادية'
                      : 'عرض القمر الصناعي',
                ),
              ),
            ),
          ),

          // بطاقة معلومات الرحلة في الأسفل
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ]),
              child: Column(
                children: [
                  Text(
                    'تفاصيل الرحلة',
                    style:
                        AppTextStyles.h3.copyWith(color: systemColors.primary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المسافة:',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        '${_tripDistance.toStringAsFixed(2)} كم',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (_selectedDestination != null && _tripDistance < 0.5)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'المسافة قصيرة جدًا. يجب أن تكون المسافة أكثر من 500 متر',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: systemColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التكلفة التقديرية:',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        '${_tripPrice.toStringAsFixed(2)} دينار',
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: systemColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نوع السائق:',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Row(
                        children: [
                          // زر السائق الذكر
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDriverType = DriverType.male;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: _selectedDriverType == DriverType.male
                                    ? systemColors.primary
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 5),
                                  Text(
                                    'سائق ',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color:
                                          _selectedDriverType == DriverType.male
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          // زر السائق الأنثى
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDriverType = DriverType.female;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedDriverType == DriverType.female
                                    ? systemColors.primary
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 5),
                                  Text(
                                    'سائقة',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: _selectedDriverType ==
                                              DriverType.female
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _confirmTrip(
                        currentPosition: _currentPosition,
                        selectedDestination: _selectedDestination,
                        tripDistance: _tripDistance,
                        tripPrice: _tripPrice,
                        selectedDriverType: _selectedDriverType),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: systemColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: Text(
                      'تأكيد الرحلة',
                      style: AppTextStyles.buttonLarge
                          .copyWith(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
