// ignore_for_file: unused_import

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:murafiq/admin/controllers/offers_management_controller.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/locale/LocaleController.dart';
import 'package:murafiq/core/version/version.dart';
import 'package:murafiq/customer/private/screens/customer_profile.dart';
import 'package:murafiq/customer/private/screens/trip_history_page.dart';
import 'package:murafiq/customer/public/screens/no_internet.dart';
import 'package:murafiq/customer/trip/controllers/trip_waiting_controller.dart';
import 'package:murafiq/customer/trip/screens/local_trip_map_page.dart';
import 'package:murafiq/customer/trip/screens/trip_waiting_page.dart';
import 'package:murafiq/driver/public/controllers/driver_profile_controller.dart';
import 'package:murafiq/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:murafiq/models/city.dart';
import 'package:murafiq/models/trip.dart';
import 'package:murafiq/shared/widgets/app_darwer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../trip/screens/trip_selection_page.dart';
import '../../../core/utils/systemVarible.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final RxList<Offer> offers = RxList<Offer>.empty();
  final RxBool isReady = RxBool(false);
  String? selectedValue;
  final List<Map<String, String>> Languges = [
    {"label": "العربية".tr, "code": "ar"},
    {"label": "الانجليزية".tr, "code": "en"},
    {"label": "الفرنسية".tr, "code": "fr"},
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      checkInternetAndProceed();
      fetchOffers();
    });
  }

  void _launchURL(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("لا يمكن فتح الرابط", "الرجاء التأكد من الاتصال بالانترنت",
          colorText: Colors.white, backgroundColor: Colors.red);
    }
  }

  Future<void> fetchOffers() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/public/offers',
        // loadingMessage: "جاري التحميل",
      );

      if (response is! FlutterError) {
        if (response != null && response['version'] != Version.version) {
          Get.dialog(
              barrierDismissible: false,
              PopScope(
                  canPop: false,
                  child: AlertDialog(
                      backgroundColor: systemColors.white,
                      content: Container(
                        color: systemColors.white,
                        height: 250,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "حدث تحديث جديد الرجاء التحميل".tr,
                              style: systemTextStyle.mediumDark,
                            ),
                            Icon(
                              Icons.download,
                              color: systemColors.primary,
                              size: 50,
                            ),
                            TextButton(
                                onPressed: () => _launchURL(response["url"]),
                                child: Text(
                                  "تحميل".tr,
                                  style: systemTextStyle.mediumPrimary,
                                ))
                          ],
                        ),
                      ))));
        } else {
          if (response != null && response['data'] != null) {
            final offersList = <Offer>[];
            for (var offer in response['data']['offers']) {
              offersList.add(Offer.fromJson(offer));
            }
            offers.value = offersList;
          }
          isReady.value = true;
        }
      } else {
        print("Error fetching offers: ${response.toString()}");
      }
    } catch (e) {
      print("Error in fetchOffers: $e");
      offers.value = [];
    }
  }

  Future<void> checkTrip() async {
    if (shared!.getBool("has_active_trip") == true) {
      try {
        final response = await sendRequestWithHandler(
          endpoint: '/trips/status',
          method: 'GET',
        );
        if (response != null && response["version"] != Version.version) {
          Get.snackbar(
              "لديك رحلة غير مكتملة".tr, "الرجاء تحديث التطبيق في اسرع وقت".tr,
              colorText: Colors.white, backgroundColor: Colors.red);
          return;
        }
        if (response != null && response['data'] != null) {
          final updatedTrip = Trip.fromJson(response['data']['trip']);

          if (updatedTrip.status == TripStatus.accepted ||
              updatedTrip.status == TripStatus.driverFound ||
              updatedTrip.status == TripStatus.completed ||
              updatedTrip.status == TripStatus.searching ||
              updatedTrip.status == TripStatus.arrived ||
              updatedTrip.status == TripStatus.cancelled) {
            if (updatedTrip.status == TripStatus.completed ||
                updatedTrip.status == TripStatus.cancelled) {
              shared!.setBool("has_active_trip", false);
              Get.offAll(() => CustomerHomePage());
            } else {
              var city = CityAndBoundary.fromJson(response["data"]["city"]);
              var cityTo = CityAndBoundary.fromJson(response["data"]["cityTo"]);

              Get.offAll(() => LocalTripMapPage(
                    initialPosition: city.center,
                    city: city,
                    cityTo: cityTo,
                    lasttrip: updatedTrip,
                  ));
            }
          } else {
            checkInternetAndProceed();
          }
        } else {
          shared!.setBool("has_active_trip", false);
        }
      } catch (e) {
        print('Error checking trip status: ');
      }
    }
  }

  Future<void> checkInternetAndProceed() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // التوجيه لصفحة عدم الاتصال بالإنترنت

      Get.offAll(() => NoInternetPage());
    } else {
      checkTrip();
    }
  }

  @override
  Widget build(BuildContext context) {
    Localecontroller localecontroller = Get.find();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: systemColors.white,
      drawer: AppDarwer.buildDrawer(userType: UserType.customer),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  systemColors.primary,
                  systemColors.primary,
                  systemColors.primary.withValues(alpha: 0.85),
                ], begin: Alignment.bottomCenter, end: Alignment.topRight),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: systemColors.primary.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.menu,
                color: systemColors.white,
                size: 28,
              ),
            ),
          ),
        ),
        title: Container(
            width: 1), // Empty container to push the dropdown to the right
        actions: [
          Container(
            margin: EdgeInsets.only(left: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                hint: Text(
                  'اللغة'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: systemColors.primary,
                  ),
                ),
                items: Languges.map((item) => DropdownMenuItem<String>(
                      value: item["code"],
                      child: Text(
                        item["label"]!,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    )).toList(),
                value: selectedValue,
                onChanged: (String? value) {
                  localecontroller.chengeLang(value!);
                  setState(() {
                    selectedValue = value;
                  });
                },
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 40,
                  width: 95,
                  decoration: BoxDecoration(
                    color: systemColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                menuItemStyleData: MenuItemStyleData(
                  height: 35,
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    color: systemColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(
                    Icons.arrow_forward_ios_outlined,
                  ),
                  iconSize: 12,
                  iconEnabledColor: systemColors.primary,
                  iconDisabledColor: Colors.grey,
                ),
                style: systemTextStyle.largePrimary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 25),
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: systemColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: systemColors.primary.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_taxi_rounded,
                        color: systemColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      "مُرافق".tr,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: systemColors.primary,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Advertisements Carousel
              Obx(
                () => CarouselSlider(
                  options: CarouselOptions(
                    height: 300.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    viewportFraction: 0.85,
                  ),
                  items: offers.map((Offer) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: systemColors.primary
                                    .withValues(alpha: 0.05),
                                spreadRadius: 0.09,
                                blurRadius: 8,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: Offer.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: systemColors.primaryGoust,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: systemColors.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: systemColors.primaryGoust,
                                child: Icon(
                                  Icons.error_outline,
                                  color: systemColors.primary,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),

              // Welcome Text
              const SizedBox(
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      "مرحباً بك".tr,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: systemColors.primary,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "إلى أين تريد الذهاب اليوم؟".tr,
                      style: TextStyle(
                        fontSize: 18,
                        color: systemColors.darkGoust,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // New Trip Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: systemColors.primary.withValues(alpha: 0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Obx(() => ElevatedButton(
                        onPressed: isReady.value == true
                            ? () {
                                if (shared!.getBool("has_active_trip") ==
                                    true) {
                                  Get.snackbar(
                                    "لديك رحلة نشطة".tr,
                                    "لا يمكنك طلب رحلة جديدة حتى تنتهي الرحلة الحالية"
                                        .tr,
                                    backgroundColor: systemColors.error,
                                    colorText: systemColors.white,
                                  );
                                  checkTrip();
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TripSelectionPage(),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: systemColors.primary,
                          foregroundColor: systemColors.white,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'رحلة جديدة'.tr,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stack _buildReword() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 70, // زيادة الحجم
          width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                systemColors.primary,
                systemColors.primary.withValues(alpha: 0.65)
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            boxShadow: [
              BoxShadow(
                color: systemColors.primary.withValues(alpha: 0.7),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: CircularProgressIndicator.adaptive(
            value: 0.5,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(systemColors.white),
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          "50د",
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
