import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/auth/OnboardingPage.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
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

  void deleteAccount() async {
    // TODO: Implement account deletion
    bool delete = false;
    await Get.dialog(AlertDialog(
      title: Text('حذف الحساب'),
      content: Text('هل أنت متأكد من حذف الحساب؟'),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        InkWell(
          onTap: () {
            delete = true;
            Get.back();
          },
          child: Container(
            alignment: Alignment.center,
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: systemColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "حذف",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            delete = false;
            Get.back();
          },
          child: Container(
            alignment: Alignment.center,
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "الغاء",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
        )
      ],
    ));

    deletConfirmed() async {
      // TODO: Implement account deletion
      try {
        final response = await sendRequestWithHandler(
          endpoint: '/public/delete-profile',
          method: 'DELETE',
          loadingMessage: "جاري الحذف",
        );
        print(response.toString());
        if (response != null && response["status"] == "success") {
          systemUtils.logout();
          Get.offAll(() => const OnboardingPage());
          Get.dialog(AlertDialog(
            title: Text("تأكيد الحذف",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            content: Container(
                alignment: Alignment.center,
                height: 200,
                width: 200,
                child: Text(
                  "لقد تم حذف\n الحساب بنجاح",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )),
            actions: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  child: Text(
                    "موافق",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              )
            ],
          ));
        }
      } catch (e) {
        print('Error deleting account: $e');
      }
    }

    if (delete) {
      await deletConfirmed();
    }
  }
}
