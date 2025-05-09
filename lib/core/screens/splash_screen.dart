import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:murafiq/auth/OnboardingPage.dart';
import 'package:murafiq/core/constant/AppRoutes.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/core/version/version.dart';
import 'package:murafiq/main.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Create scale animation
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    // Create opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    // Create slide animation
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start the animation
    _controller.forward();

    getUpdate();

    // Navigate to the next screen after animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? systemColors.dark : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo with scale, opacity, and slide
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: Image.asset(
                        isDarkMode
                            ? 'assets/brand/startScreen.png'
                            : 'assets/brand/logoL.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Loading indicator
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _opacityAnimation,
              child: SpinKitWave(
                itemCount: 5,
                size: 30,
                color: isDarkMode ? Colors.white : const Color(0xFF0047AB),
              ),
            ),

            const SizedBox(height: 25),

            // Animated text
            FadeTransition(
              opacity: _opacityAnimation,
              child: Text(
                'مرافق',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF0047AB),
                ),
              ),
            ),
            FadeTransition(
              opacity: _opacityAnimation,
              child: Text(
                'MURAFIQ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF0047AB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getUpdate() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/public/update',
        method: 'GET',
      );
      if (response != null &&
          response["status"] == "success" &&
          response['version'] != Version.version) {
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
                            "هناك تحديث جديد الرجاء التحميل".tr,
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
      } else if (response != null &&
          response["status"] == "success" &&
          response['version'] == Version.version) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.offAllNamed(Approutes.onboardingPage);
        });
      } else {
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
                            "حدث خطأ الرجاء فحص  اتصالك بالانترنت".tr,
                            style: systemTextStyle.mediumDark,
                          ),
                        ],
                      ),
                    ))));
      }
    } catch (error) {
      printer.e(error);
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
                          "حدث خطأ الرجاء فحص  اتصالك بالانترنت".tr,
                          style: systemTextStyle.mediumDark,
                        ),
                      ],
                    ),
                  ))));
    }
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
