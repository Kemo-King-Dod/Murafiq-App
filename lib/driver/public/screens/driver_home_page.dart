import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/core/functions/GelocatorFun.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/customer/public/screens/no_internet.dart';
import 'package:murafiq/driver/public/controllers/driver_profile_controller.dart';
import 'package:murafiq/main.dart';
import 'package:murafiq/models/trip.dart';
import 'package:murafiq/driver/public/screens/active_trip_page.dart';
import 'package:murafiq/driver/private/screens/driver_profile_page.dart';
import 'package:murafiq/driver/private/screens/driver_trip_history_page.dart';
import 'package:murafiq/driver/private/screens/driver_wallet_page.dart';
import 'package:murafiq/driver/private/screens/driver_notifications_page.dart';
import 'package:murafiq/shared/widgets/app_darwer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/auth_controller.dart';
import '../../../core/services/trip_service.dart';

class DriverHomePage extends StatefulWidget {
  DriverHomePage({Key? key}) : super(key: key);

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RxBool isAvailable = true.obs;
  final RxList<Trip> availableTrips = <Trip>[].obs;
  Timer? _tripCheckTimer;
  String? city;

  @override
  void initState() {
    super.initState();
    checkInternetAndProceed();
    _startTripChecking();
  }

  @override
  void dispose() {
    _tripCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> checkInternetAndProceed() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // التوجيه لصفحة عدم الاتصال بالإنترنت

      Get.offAll(() => NoInternetPage());
    } else {
      checkAcceptedTrip();
    }
  }

  void checkAcceptedTrip() async {
    print("checkAcceptedTrip");
    print(shared!.getBool("driver_has_active_trip"));
    if (shared!.getBool("driver_has_active_trip") == true) {
      try {
        final response = await sendRequestWithHandler(
            endpoint: '/trips/driver/status',
            method: 'GET',
            loadingMessage: "جاري فحص حالة الرحلة");
        print(response.toString());
        if (response != null && response['data'] != null) {
          final acceptedTrip = Trip.fromJson(response['data']['trip']);
          if (acceptedTrip.status == TripStatus.accepted ||
              acceptedTrip.status == TripStatus.driverFound) {
            Get.offAll(() => ActiveTripPage(trip: acceptedTrip));
          } else if (acceptedTrip.status == TripStatus.completed ||
              acceptedTrip.status == TripStatus.cancelled) {
            shared!.setBool("driver_has_active_trip", false);
            Get.offAll(DriverHomePage());
          } else {
            checkInternetAndProceed();
          }
        } else {
          checkInternetAndProceed();
        }
      } catch (e) {
        print("Error checking trip status: $e");
      }
    }
  }

  // بدء التحقق من الرحلات
  void _startTripChecking() async {
    var times = 0;
    if (await Geolocator.isLocationServiceEnabled()) {
      // بدء تتبع الموقع باستخدام Geolocator
      if (await Geolocator.checkPermission() == LocationPermission.denied) {
        Geolocator.requestPermission();
      } else if (await Geolocator.checkPermission() ==
          LocationPermission.deniedForever) {
        Get.dialog(
          AlertDialog(
            title: Text("خطأ"),
            content: Text("يرجى تفعيل الموقع للتطبيق"),
          ),
        );
      }

      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1,
        ),
      ).handleError((error) {
        print("Location Stream Error: $error");
        Get.snackbar(
          'خطأ',
          'حدث خطأ في تتبع الموقع',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }).listen((Position position) async {
        try {
          if (isAvailable.value) {
            String? newCity = await LocationService.getCityName(
                lat: position.latitude, lng: position.longitude);
            print("newCity: $newCity");
            if (city == null) {
              print("city is null");
              city = newCity;
              _checkForTrips();
            } else if (newCity != city) {
              city = newCity;
              print("city changed");
              _checkForTrips();
            } else {
              times++;
              print("times: $times");
            }

            if (times > 3) {
              times = 0;
              _checkForTrips();
            }
          }
        } catch (e) {
          print("Error in location stream: $e");
        }
      });
    } else {
      Get.dialog(
        AlertDialog(
          title: Text("خطأ"),
          content: Text("يرجى تفعيل الموقع للتطبيق"),
        ),
      );
    }
  }

  // التحقق من وجود رحلات متاحة
  Future<void> _checkForTrips() async {
    if (!isAvailable.value) return;

    final trips = await TripService.getAvailableTrips(city: city);
    availableTrips.value = trips;
    print(availableTrips.length);
  }

  // قبول الرحلة
  Future<void> _acceptTrip(Trip trip) async {
    final success = await TripService.acceptTrip(trip.id!);
    if (success) {
      Get.snackbar(
        'تم',
        'تم قبول الرحلة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // حذف الرحلة من القائمة
      availableTrips.remove(trip);
    }
  }

  // رفض الرحلة
  Future<void> _rejectTrip(Trip trip) async {
    final success = await TripService.rejectTrip(trip.id!);
    if (success) {
      Get.snackbar(
        'تم',
        'تم رفض الرحلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // حذف الرحلة من القائمة
      availableTrips.remove(trip);
    }
  }

  // دالة لبناء تفاصيل الرحلة
  Widget _buildTripDetail({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // دالة لبناء بطاقة الطلب
  Widget _buildRequestCard() {
    return Obx(() {
      if (availableTrips.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'جاري البحث عن رحلات...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: availableTrips.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final trip = availableTrips[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: systemColors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // نقطة الانطلاق
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: systemColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: systemColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مدينة الانطلاق',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trip.startCity.arabicName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // خط عمودي
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    width: 2,
                    height: 30,
                    color: systemColors.primary,
                  ),

                  // نقطة الوصول
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.flag_rounded,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مدينة الوجهة',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trip.destinationCity.arabicName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      // فتح خريطة لعرض المسار
                      final Uri url = Uri.parse(
                        'https://www.google.com/maps/dir/?api=1'
                        '&origin=${trip.startLocation!.latitude},${trip.startLocation!.longitude}'
                        '&destination=${trip.destinationLocation!.latitude},${trip.destinationLocation!.longitude}'
                        '&travelmode=driving',
                      );
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    icon: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      decoration: BoxDecoration(
                        color: systemColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map_rounded,
                            color: systemColors.primary,
                            size: 28,
                          ),
                          Text(
                            'عرض المسار',
                            style: TextStyle(
                              color: systemColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    tooltip: 'عرض المسار على الخريطة',
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),

                  // تفاصيل الرحلة
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildTripDetail(
                              icon: Icons.route_rounded,
                              title: 'المسافة',
                              value: '${trip.distance.toStringAsFixed(2)} كم',
                              color: Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: _buildTripDetail(
                              icon: Icons.timer_rounded,
                              title: 'الوقت المتوقع',
                              value: '${trip.estimatedTime} دقيقة',
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildTripDetail(
                              icon: Icons.attach_money_rounded,
                              title: 'السعر',
                              value: '${trip.price} دينار',
                              color: Colors.green,
                            ),
                          ),
                          Expanded(
                            child: _buildTripDetail(
                              icon: Icons.business_rounded,
                              title: 'مستحقات الشركة',
                              value: '${trip.companyFee} دينار',
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // أزرار القبول والرفض
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptTrip(trip),
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text('قبول الطلب'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rejectTrip(trip),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('رفض الطلب'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // دالة مساعدة لبناء تفاصيل الموقع
  Widget _buildLocationDetail(
    String title,
    String location,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: systemTextStyle.smallDark,
              ),
              Text(
                location,
                style: systemTextStyle.mediumDark.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.grey[600])!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.grey[600],
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: AppDarwer.buildDrawer(userType: UserType.driver),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // زر فتح القائمة
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    tooltip: 'القائمة الرئيسية',
                  ),
                ),
              ),

              // زر تبديل الحالة
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text('وضع السائق ', style: systemTextStyle.mediumDark),
                  trailing: Obx(() => Switch.adaptive(
                        value: isAvailable.value,
                        onChanged: (value) {
                          isAvailable.value = value;
                          // TODO: تحديث حالة السائق في الباك اند
                        },
                        activeColor: systemColors.primary,
                        activeTrackColor: systemColors.primary.withOpacity(0.5),
                      )),
                ),
              ),

              // محتوى الصفحة
              Expanded(
                child: _buildRequestCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح الرابط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
