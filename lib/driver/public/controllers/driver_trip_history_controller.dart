import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/models/customer.dart';
import 'package:murafiq/models/driver.dart';
import 'package:murafiq/models/trip.dart';

class DriverTripHistoryController extends GetxController {
  final RxList<Trip> trips = <Trip>[
    // Trip(
    //   distance: 10.0,
    //   estimatedTime: 30,
    //   startCity: City.sabha,
    //   destinationCity: City.sabha,
    //   driver: Driver(
    //     name: "محمد",
    //     phone: "01012345678",
    //     gender: "male",
    //     idNumber: "123456789",
    //     carNumber: "1234",
    //   ),
    //   id: "iddfs",
    //   startLocation: LatLng(30.0444, 31.2357),
    //   destinationLocation: LatLng(30.0444, 31.2357),
    //   createdAt: DateTime.now(),
    //   status: TripStatus.completed,
    //   price: 50.0,
    //   companyFee: 12,
    //   tripType: TripType.intercity,
    //   driverType: DriverType.male,
    //   paymentMethod: PaymentMethod.cash,
    //   customer: Customer(
    //     name: "محمد",
    //     phone: "01012345678",
    //     gender: "male",
    //   ),
    //   TripCode: "12345",
    // ),
    // Trip(
    //   distance: 10.0,
    //   estimatedTime: 30,
    //   startCity: City.sabha,
    //   destinationCity: City.sabha,
    //   driver: Driver(
    //     name: "محمد",
    //     phone: "01012345678",
    //     gender: "male",
    //     idNumber: "123456789",
    //     carNumber: "1234",
    //   ),
    //   id: "iddfs",
    //   startLocation: LatLng(30.0444, 31.2357),
    //   destinationLocation: LatLng(30.0444, 31.2357),
    //   createdAt: DateTime.now(),
    //   status: TripStatus.cancelled,
    //   price: 50.0,
    //   companyFee: 12,
    //   tripType: TripType.intercity,
    //   driverType: DriverType.male,
    //   paymentMethod: PaymentMethod.cash,
    //   customer: Customer(
    //     name: "محمد",
    //     phone: "01012345678",
    //     gender: "male",
    //   ),
    //   TripCode: "12345",
    // )
  ].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
  }

  onReady() {
    super.onReady();
    fetchTripHistory();
  }

  Future<void> fetchTripHistory() async {
    try {
      isLoading.value = true;
      final response = await sendRequestWithHandler(
        endpoint: '/public/trip-history',
        method: 'GET',
        loadingMessage: "جاري التحميل",
      );

      if (response != null && response['data'] != null) {
        final tripList = response['data']['trips'] as List;
        trips.value =
            tripList.map((tripData) => Trip.fromJson(tripData)).toList();
      }
    } catch (e) {
      print('Error fetching trip history: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب سجل الرحلات',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshTripHistory() {
    fetchTripHistory();
  }
}
