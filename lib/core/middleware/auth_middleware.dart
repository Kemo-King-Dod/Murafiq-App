import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/auth/auth_controller.dart';
import 'package:murafiq/auth/login_page.dart';
import 'package:murafiq/core/constant/AppRoutes.dart';
import 'package:murafiq/customer/public/screens/customer_home_page.dart';
import 'package:murafiq/driver/public/screens/driver_home_page.dart';
import 'package:murafiq/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return checkAuth();
  }

  RouteSettings? checkAuth() {
    final authController = Get.find<AuthController>();

    // Check if user is already logged in
    final token = shared!.getString('token');
    final userType = shared!.getString('user_type');

    if (token != null && userType != null) {
      // Auto login the user
      authController.isLoggedIn.value = true;
      authController.userType.value = userType;

      // Redirect based on user type
      if (userType == 'customer') {
        return const RouteSettings(name: Approutes.userHomePage);
      } else if (userType == 'driver') {
        return const RouteSettings(name: Approutes.driverHomePage);
      }
    }

    // If no token or userType, continue to onboarding
    return null;
  }
}
