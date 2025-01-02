import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:murafiq/admin/screens/admin_dashboard.dart';
import 'package:murafiq/auth/OnboardingPage.dart';
import 'package:murafiq/auth/customer_signup_page.dart';
import 'package:murafiq/core/functions/classes/loading_controller.dart';
import 'package:murafiq/core/locale/LocaleController.dart';
import 'package:murafiq/core/middleware/auth_middleware.dart';
import 'package:murafiq/core/screens/splash_screen.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
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

  // Request notification permissions
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted notification permissions');
  } else {
    print('User declined or has not accepted notification permissions');
  }

  await GetStorage.init();
  shared = await SharedPreferences.getInstance();

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
      title: 'Murafiq',
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
      textDirection: TextDirection.rtl,
      home: const SplashScreen(),
      getPages: [
        GetPage(
          name: '/start',
          middlewares: [AuthMiddleware()],
          page: () => OnboardingPage(),
        ),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/forgot-password', page: () => ForgotPasswordPage()),
        GetPage(name: '/customer-signup', page: () => CustomerSignupPage()),
        GetPage(name: '/customer-home', page: () => CustomerHomePage()),
        GetPage(name: '/driver-home', page: () => DriverHomePage()),
        GetPage(name: '/admin-dashboard', page: () => AdminDashboardPage()),
      ],
    );
  }
}
