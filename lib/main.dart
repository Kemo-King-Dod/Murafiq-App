import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:murafiq/admin/screens/admin_dashboard.dart';
import 'package:murafiq/auth/OnboardingPage.dart';
import 'package:murafiq/auth/customer_signup_page.dart';
import 'package:murafiq/auth/driver_signup_page.dart';
import 'package:murafiq/core/constant/AppRoutes.dart';
import 'package:murafiq/core/controllers/socket_controller.dart';
import 'package:murafiq/core/functions/classes/loading_controller.dart';
import 'package:murafiq/core/locale/Locale.dart';
import 'package:murafiq/core/locale/LocaleController.dart';
import 'package:murafiq/core/middleware/auth_middleware.dart';
import 'package:murafiq/core/screens/splash_screen.dart';
import 'package:murafiq/customer/public/screens/customer_home_page.dart';
import 'package:murafiq/driver/public/screens/driver_home_page.dart';
import 'package:murafiq/models/city.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'auth/login_page.dart';
import 'auth/auth_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:murafiq/core/services/notification_service.dart';
import 'auth/forgot_password_page.dart';
import 'package:flutter/services.dart';

SharedPreferences? shared;
Logger printer = Logger();

// Define app colors
class AppColors {
  static const Color primary = Color(0xFF0045a4);
  static const Color secondary = Color(0xFF646FD4);
  static const Color tertiary = Color(0xFF9BA4B5);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.init();

  // Get and save FCM Token
  String? fcmToken = await notificationService.getAndSaveFCMToken();

  // Optional: Retrieve saved token to verify
  String? savedToken = await notificationService.getSavedFCMToken();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();

  await GetStorage.init();
  shared = await SharedPreferences.getInstance();

  // Initialize socket controller
  Get.put(SocketController(), permanent: true);

  // Initialize AuthController
  Get.put(AuthController());
  Get.put(CityAndBoundaryController(), permanent: true);
  Get.put(LoadingController(), permanent: true);
  Get.put(notificationService, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeController = Get.put(Localecontroller(), permanent: true);
    FlutterNativeSplash.remove();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Murafiq'.tr,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Tajawal',
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.2),
          displayMedium: TextStyle(
              fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: -0.1),
          displaySmall: TextStyle(
              fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0),
          bodyLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
          bodyMedium: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
          bodySmall: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
          labelLarge: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 1.5),
          labelMedium: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 1.5),
        ),
      ),
      locale: localeController.initialLang,
      translations: TaxiLocale(),
      textDirection: TextDirection.rtl,
      home: const SplashScreen(),
      getPages: [
        GetPage(
          name: Approutes.onboardingPage,
          middlewares: [AuthMiddleware()],
          page: () => OnboardingPage(),
        ),
        GetPage(name: Approutes.loginPage, page: () => LoginPage()),
        GetPage(
            name: Approutes.forgetPassword, page: () => ForgotPasswordPage()),
        GetPage(
            name: Approutes.customerSignupPage,
            page: () => CustomerSignupPage()),
        GetPage(
            name: Approutes.driverSignupPage, page: () => DriverSignupPage()),
        GetPage(name: Approutes.userHomePage, page: () => CustomerHomePage()),
        GetPage(name: Approutes.driverHomePage, page: () => DriverHomePage()),
        GetPage(
            name: Approutes.adminHomePage, page: () => AdminDashboardPage()),
      ],
    );
  }
}
