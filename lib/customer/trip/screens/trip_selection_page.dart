import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/functions/is_point_inside_polygon.dart';
import 'package:murafiq/main.dart';
import 'package:murafiq/models/city.dart';
import '../../../core/utils/systemVarible.dart';
import '../../../core/utils/text_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import '../../../core/functions/GelocatorFun.dart';
import 'local_trip_map_page.dart';

class TripSelectionPage extends StatefulWidget {
  const TripSelectionPage({Key? key}) : super(key: key);

  @override
  State<TripSelectionPage> createState() => _TripSelectionPageState();
}

class _TripSelectionPageState extends State<TripSelectionPage> {
  List<String> _features = [
    "رحلات آمنة ومريحة مع أفضل المرشدين السياحيين".tr,
    "اكتشف أجمل المعالم السياحية في مدينتك".tr,
    "تجربة سفر فريدة مع مرافق متخصص".tr,
    "خدمة عملاء على مدار الساعة".tr,
    "أسعار تنافسية ومناسبة للجميع".tr,
    "تتبع رحلتك مباشرة عبر التطبيق".tr,
    "استمتع برحلة مميزة مع مرافق".tr
  ];

  final List<String> _images = [
    'assets/SVG/undraw_delivery-truck_mjui.svg',
    'assets/SVG/undraw_destination_fkst (1).svg',
    'assets/SVG/undraw_emails_085h.svg',
    'assets/SVG/undraw_into-the-night_nd84.svg',
    'assets/SVG/undraw_mobile-encryption_flk2.svg',
    'assets/SVG/undraw_navigator_2ntl.svg',
    'assets/SVG/undraw_vintage_q09n.svg',
  ];

  int _currentFeatureIndex = 0;
  Timer? _timer;
  final CityAndBoundaryController cityAndBoundaryController = Get.find();
  double _opacity = 1.0;
  CityAndBoundary? _selectedExternalCity;

  @override
  void initState() {
    super.initState();
    // تحميل النصوص أولاً
    if (cityAndBoundaryController.features.isNotEmpty) {
      _features = cityAndBoundaryController.features;
    }
    // بدء التحريك فقط إذا كانت القوائم غير فارغة
    if (_features.isNotEmpty) {
      _startFeatureAnimation();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startFeatureAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_features.isEmpty) {
        timer.cancel();
        return;
      }
      setState(() {
        _opacity = 0.0;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _features.isNotEmpty) {
            setState(() {
              _currentFeatureIndex =
                  (_currentFeatureIndex + 1) % _features.length;
              _opacity = 1.0;
            });
          }
        });
      });
    });
  }

  Future<void> _handleLocalTripSelection({CityAndBoundary? cityTo}) async {
    printer.w("location permission");
    try {
      final hasPermission =
          await LocationService.handleLocationPermission(isDriver: false);
      if (!hasPermission) {
        return;
      }
      systemUtils.loadingPop("جاري تحديد موقعك".tr, canPop: true);

      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        LatLng currentPosition = LatLng(position.latitude, position.longitude);
        CityAndBoundary? currentCity;

        // Ensure cities are loaded
        if (cityAndBoundaryController.citiesAndBoundaries.isEmpty) {
          await cityAndBoundaryController.fetchCitiesandBoundaries();
        }

        // Find current city
        for (var city in cityAndBoundaryController.citiesAndBoundaries) {
          if (isPointInsidePolygons(currentPosition, city.boundary.toSet())) {
            currentCity = city;
            break;
          }
        }

        Get.back(); // Close loading dialog

        if (currentCity == null) {
          _showLocationErrorDialog(
              'موقعك الحالي غير مدعوم سنظيفه قريبا باذن الله'.tr);
          return;
        }

        // Navigate to map page
        Get.to(
          () => LocalTripMapPage(
            initialPosition: currentPosition,
            city: currentCity!,
            cityTo:
                cityTo != null && cityTo.Arabicname != currentCity!.Arabicname
                    ? cityTo
                    : currentCity!,
          ),
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      _showLocationErrorDialog(e.toString());
    }
  }

  void _showLocationErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "موقعك الحالي غير مدعوم".tr,
            style: AppTextStyles.h3.copyWith(color: systemColors.primary),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'حسناً'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: systemColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showExternalTripCitySelector() async {
    systemUtils.loadingPop("جاري تحميل المدن".tr, canPop: false);
    await cityAndBoundaryController.fetchCitiesandBoundaries();
    Get.back();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return InkWell(
          onTap: () {
            print(cityAndBoundaryController.citiesAndBoundaries);
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختر وجهتك'.tr,
                  style: AppTextStyles.h3.copyWith(
                    color: systemColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: systemColors.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Obx(() {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<CityAndBoundary>(
                          isExpanded: true,
                          hint: Text(
                            'اختر المدينة'.tr,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  systemColors.primary.withValues(alpha: 0.7),
                            ),
                          ),
                          value: _selectedExternalCity,
                          icon: Icon(
                            Icons.location_city_rounded,
                            color: systemColors.primary,
                          ),
                          items: cityAndBoundaryController
                                  .citiesAndBoundaries.isEmpty
                              ? []
                              : cityAndBoundaryController.citiesAndBoundaries
                                  .map((CityAndBoundary city) {
                                  return DropdownMenuItem<CityAndBoundary>(
                                    value: city,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: systemColors.primary
                                              .withValues(alpha: 0.7),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          city.Arabicname,
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          onChanged: (CityAndBoundary? newValue) {
                            setState(() {
                              _selectedExternalCity = newValue;
                            });
                            Navigator.pop(context);
                            if (newValue != null) {
                              _handleExternalTripSelection(newValue);
                            }
                            setState(() {
                              _selectedExternalCity = null;
                            });
                          },
                        ),
                      );
                    })),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleExternalTripSelection(CityAndBoundary selectedCity) {
    _handleLocalTripSelection(cityTo: selectedCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: systemColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image at the top
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _opacity,
                  child: SvgPicture.asset(
                    _images[_currentFeatureIndex % _images.length],
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),

                // Animated Features Text
                SizedBox(
                  height: 80,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.5),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Opacity(
                      opacity: _opacity,
                      child: Text(
                        _features[_currentFeatureIndex % _features.length],
                        key: ValueKey<int>(_currentFeatureIndex),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: systemColors.primary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                // Local Trip Button
                InkWell(
                  onTap: _handleLocalTripSelection,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: systemColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [
                                    systemColors.primary.withOpacity(0.85),
                                    systemColors.primary.withOpacity(0.75),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Base SVG Background
                          Positioned.fill(
                            child: SvgPicture.asset(
                              'assets/SVG/city.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          // Colored Overlay

                          // Content Layer
                          Positioned.fill(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.locationDot,
                                      color: systemColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'رحلة في مدينتي'.tr,
                                    style: AppTextStyles.h3.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'تنقل بسهولة داخل مدينتك'.tr,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // External Trip Button
                InkWell(
                  onTap: _showExternalTripCitySelector,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withOpacity(0.95),
                                    Colors.white.withOpacity(0.9),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Base SVG Background
                          Positioned.fill(
                            child: SvgPicture.asset(
                              'assets/SVG/intercity.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          // White Overlay

                          // Content Layer
                          Positioned.fill(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: systemColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.map,
                                      color: systemColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'رحلة خارجية'.tr,
                                    style: AppTextStyles.h3.copyWith(
                                      color: systemColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'سافر بين المدن بأمان'.tr,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for subtle dotted pattern
class DottedPatternPainter extends CustomPainter {
  final Color color;

  DottedPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotSize = 2.0;

    for (var i = 0.0; i < size.width; i += spacing) {
      for (var j = 0.0; j < size.height; j += spacing) {
        canvas.drawCircle(
          Offset(i, j),
          dotSize,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
