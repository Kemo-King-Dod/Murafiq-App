import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:murafiq/admin/controllers/offers_management_controller.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/customer/private/screens/customer_profile.dart';
import 'package:murafiq/customer/private/screens/trip_history_page.dart';
import 'package:murafiq/customer/public/screens/no_internet.dart';
import 'package:murafiq/customer/trip/controllers/trip_waiting_controller.dart';
import 'package:murafiq/customer/trip/screens/trip_waiting_page.dart';
import 'package:murafiq/driver/public/controllers/driver_profile_controller.dart';
import 'package:murafiq/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:murafiq/models/trip.dart';
import 'package:murafiq/shared/widgets/app_darwer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../trip/screens/trip_selection_page.dart';
import '../../../core/utils/systemVarible.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final RxList<Offer> offers = RxList<Offer>.empty();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      checkInternetAndProceed();
      fetchOffers();
    });
  }

  Future<void> fetchOffers() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/public/offers',
        // loadingMessage: "جاري التحميل",
      );

      if (response is! FlutterError) {
        if (response != null && response['data'] != null) {
          final offersList = <Offer>[];
          for (var offer in response['data']['offers']) {
            offersList.add(Offer.fromJson(offer));
          }
          offers.value = offersList;
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
    print("checkTrip");
    if (shared!.getBool("has_active_trip") == true) {
      try {
        final response = await sendRequestWithHandler(
            endpoint: '/trips/status',
            method: 'GET',
            loadingMessage: "جاري فحص حالة الرحلة");
        print("customer home page 41" + response.toString());
        if (response != null && response['data'] != null) {
          final updatedTrip = Trip.fromJson(response['data']['trip']);

          if (updatedTrip.status == TripStatus.accepted ||
              updatedTrip.status == TripStatus.driverFound ||
              updatedTrip.status == TripStatus.completed ||
              updatedTrip.status == TripStatus.searching) {
            if (updatedTrip.status == TripStatus.completed ||
                updatedTrip.status == TripStatus.cancelled) {
              shared!.setBool("has_active_trip", false);
              Get.offAll(CustomerHomePage());
            } else {
              Get.offAll(TripWaitingPage(
                trip: updatedTrip,
              ));
            }
          } else {
            print(1);
            checkInternetAndProceed();
          }
        } else {
          print(2);
        }
      } catch (e) {
        print('Error checking trip status: $e');
      }
    }
  }

  Future<void> checkInternetAndProceed() async {
    print("checkInternetAndProceed");
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // التوجيه لصفحة عدم الاتصال بالإنترنت

      Get.offAll(() => NoInternetPage());
    } else {
      checkTrip();
    }
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
          color: (iconColor ?? Colors.grey[600])!.withValues(alpha: 0.1),
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

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: systemColors.white,
      drawer: AppDarwer.buildDrawer(userType: UserType.customer),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: systemColors.primaryGoust,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.menu,
                color: systemColors.primary,
                size: 28,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
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
                      color: systemColors.primaryGoust,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_taxi_rounded,
                      color: systemColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "مُرافق",
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
                  height: 200.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.85,
                ),
                items: offers.map((Offer) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: systemColors.primary.withOpacity(0.05),
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

            const Spacer(),

            // Welcome Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    "مرحباً بك",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: systemColors.primary,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "إلى أين تريد الذهاب اليوم؟",
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
                      color: systemColors.primary.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TripSelectionPage(),
                      ),
                    );
                  },
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
                    'رحلة جديدة',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
