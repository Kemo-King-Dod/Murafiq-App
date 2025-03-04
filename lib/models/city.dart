import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/functions/errorHandler.dart';

class CityAndBoundary {
  final String Arabicname;
  final String Englishname;
  final List<LatLng> boundary;
  final LatLng center;

  CityAndBoundary({
    required this.center,
    required this.Englishname,
    required this.Arabicname,
    required this.boundary,
  });

  factory CityAndBoundary.fromJson(Map<String, dynamic> json) {
    return CityAndBoundary(
      center: LatLng(
          json['center']['latitude'].toDouble(), json['center']['longitude'] ),
      Arabicname: json['Arabicname'],
      Englishname: json['Englishname'],
      boundary: json['boundary'].map<LatLng>((point) {
        return LatLng(point['latitude'], point['longitude']);
      }).toList(),
    );
  }
}

class CityAndBoundaryController extends GetxController {
  List<Map<String, dynamic>> priceToDifferentCities = [];
  RxList<CityAndBoundary> citiesAndBoundaries = <CityAndBoundary>[].obs;
  List<String> features = [];
  List? tripSelectionImgs;
  // get citiesAndBoundarie => citiesAndBoundaries;

  Future<void> fetchCitiesandBoundaries() async {
    try {
      final response = await sendRequestWithHandler(
        endpoint: '/public/cityBoundaries',
        method: 'GET',
      );
      if (response != null && response['status'] == 'success') {
        final data = response['data'];
        if (data["citiesAndBoundaries"] is List) {
          citiesAndBoundaries.clear();
          for (var cityAndBoundary in data["citiesAndBoundaries"]) {
            CityAndBoundary cityBoundaries =
                CityAndBoundary.fromJson(cityAndBoundary);
            citiesAndBoundaries.add(cityBoundaries);
          }
        }
        if (data["priceToDifferentCities"] != null &&
            data["priceToDifferentCities"] is List) {
          priceToDifferentCities.clear();
          data["priceToDifferentCities"].forEach((element) {
            priceToDifferentCities.add(element);
          });
        }
        features = data["features"];
        tripSelectionImgs = data["tripSelectionImgs"];
      }
    } catch (e) {
      print('Error fetching city boundaries: $e');
    }
  }

  Map calculatePriceToDiffrentCities(
      {required String city, required String cityTo}) {
    double price = 0;
    double companyFee = 0;

    priceToDifferentCities.forEach((cityprice) {
      if (cityprice["cities"].contains(city) &&
          cityprice["cities"].contains(cityTo)) {
        price = cityprice["price"].toDouble();
        companyFee = cityprice["companyFee"].toDouble();
      }
    });

    return {"price": price, "_companyFee": companyFee};
  }

  @override
  void onInit() {
    // TODO: implement onInit
    fetchCitiesandBoundaries();
    super.onInit();
  }
}
