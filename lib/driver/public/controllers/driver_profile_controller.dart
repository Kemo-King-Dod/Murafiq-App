import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/driver/public/widgets/profile_bottom_sheets.dart';

enum UserType {
  driver,
  customer,
}

class DriverProfileController extends GetxController {
  final UserType userType;
  DriverProfileController({required this.userType});

  final RxString driverName = ''.obs;
  final RxString phoneNumber = ''.obs;
  final Rx<String> createdAt = ''.obs;
  final RxString vehicleType = ''.obs;
  final RxInt totalTrips = 0.obs;
  final RxDouble totalEarnings = 0.0.obs;
  final RxString profileImageUrl = ''.obs;
  @override
  onReady() {
    super.onReady();
    fetchDriverProfile();
  }

  Future<void> fetchDriverProfile() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/public/user-profile',
        method: 'GET',
        loadingMessage: "جاري التحميل",
      );
      print(response.toString());
      if (response != null && response['data'] != null) {
        final profileData = response['data']['user'];
        driverName.value = profileData['name'] ?? '';
        phoneNumber.value = profileData['phone'] ?? '';
        vehicleType.value = profileData['carType'] ?? '';
        createdAt.value = DateTime.parse(profileData['createdAt'])
            .toLocal()
            .toString()
            .split(' ')[0];
        totalTrips.value = profileData['total_trips'] ?? 0;
        totalEarnings.value = (profileData['total_earnings'] ?? 0.0).toDouble();
        profileImageUrl.value = profileData['profile_image'] ?? '';
      }
    } catch (e) {
      print('Error fetching driver profile: $e');
    }
  }

  void editProfile() {
    // TODO: Implement comprehensive profile editing
    Get.bottomSheet(
      EditProfileBottomSheet(userType: userType),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void changePassword() {
    Get.bottomSheet(
      ChangePasswordBottomSheet(),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}
