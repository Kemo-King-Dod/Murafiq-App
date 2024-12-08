import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:murafiq/main.dart';
import 'trip_selection_page.dart';
import '../../../core/utils/systemVarible.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final List<String> adImages = [
    'https://img.freepik.com/free-vector/taxi-app-concept_23-2148485646.jpg',
    'https://img.freepik.com/free-vector/taxi-service-abstract-concept-vector-illustration_335657-1841.jpg',
    'https://img.freepik.com/free-vector/city-taxi-service-abstract-concept-vector-illustration-city-taxi-order-online-mobile-taxi-application-passenger-transportation-service-urban-traffic-book-car-ride-abstract-metaphor_335657-1685.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: systemColors.white,
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
                    "مرافق",
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
            CarouselSlider(
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
              items: adImages.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: systemColors.primary.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
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
