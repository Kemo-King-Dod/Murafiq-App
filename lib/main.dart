import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:murafiq/core/functions/classes/loading_controller.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'customer/public/screens/customer_home_page.dart';
import 'auth/login_page.dart';
import 'auth/auth_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:murafiq/core/services/notification_service.dart';
import 'auth/forgot_password_page.dart';

SharedPreferences? shared;

// Define app colors
class AppColors {
  static const Color primary = Color(0xFF0045a4);
  static const Color secondary = Color(0xFF646FD4);
  static const Color tertiary = Color(0xFF9BA4B5);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted notification permissions');
  } else {
    print('User declined or has not accepted notification permissions');
  }

  await GetStorage.init();
  shared = await SharedPreferences.getInstance();

  // Initialize AuthController
  Get.put(AuthController());
  Get.put(LoadingController(), permanent: true);
  Get.put(notificationService, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Murafiq',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        useMaterial3: true,
        fontFamily: 'Tajawal',
        primaryColor: AppColors.primary,
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
      home: LoginPage(),
      locale: const Locale('ar', 'SA'),
      textDirection: TextDirection.rtl,
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/forgot-password', page: () => ForgotPasswordPage()),
      ],
    );
  }
}
