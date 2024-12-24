import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/customer/trip/controllers/trip_waiting_controller.dart';
import 'package:murafiq/models/customer.dart';
import 'package:murafiq/models/driver.dart';

enum TripStatus {
  searching,
  driverFound,
  rejected,
  accepted,
  arrived,
  completed,
  cancelled
}

enum DriverType { male, female }

enum TripType { local, intercity }

enum City {
  alQatrun, // القطرون
  alBakhi, // البخي
  alJinsiya, // الجنسية
  qasrMasud, // قصر مسعود
  sabha // سبها
}

enum PaymentMethod {
  cash,
  wallet,
}

// امتداد لـ enum City لإضافة أسماء المدن بالعربية
extension CityExtension on City {
  String get arabicName {
    switch (this) {
      case City.alQatrun:
        return 'القطرون';
      case City.alBakhi:
        return 'البخي';
      case City.alJinsiya:
        return 'الجنسية';
      case City.qasrMasud:
        return 'قصر مسعود';
      case City.sabha:
        return 'سبها';
    }
  }

  // إحداثيات كل مدينة
  LatLng get location {
    switch (this) {
      case City.alQatrun:
        return const LatLng(24.9500, 14.6500); // القطرون
      case City.alBakhi:
        return const LatLng(24.2000, 14.4000); // البخي (إحداثيات تقريبية)
      case City.alJinsiya:
        return const LatLng(24.5000, 14.5000); // الجنسية (إحداثيات تقريبية)
      case City.qasrMasud:
        return const LatLng(24.1500, 14.3500); // قصر مسعود (إحداثيات تقريبية)
      case City.sabha:
        return const LatLng(24.3000, 14.6000); // سبها (إحداثيات تقريبية)
    }
  }
}

class Trip {
  String? id;
  final City startCity;
  final City destinationCity;
  final LatLng? startLocation; // موقع محدد من قبل الزبون
  final LatLng? destinationLocation; // موقع محدد من قبل الزبون
  final double distance;
  final int estimatedTime;
  final double price;
  final double companyFee;
  final DriverType driverType;
  final TripType tripType;
  final TripStatus status;
  final DateTime createdAt;
  final Driver? driver; // معلومات السائق>
  final Customer? customer; // معلومات الزبون>
  PaymentMethod paymentMethod = PaymentMethod.cash;
  final String? TripCode;

  Trip({
    this.driver,
    this.customer,
    this.id,
    required this.startCity,
    required this.destinationCity,
    this.startLocation,
    this.destinationLocation,
    required this.distance,
    required this.estimatedTime,
    required this.price,
    required this.companyFee,
    required this.driverType,
    required this.tripType,
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
    this.TripCode,
  });

  // تحويل من JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      startCity: City.values.firstWhere(
        (e) => e.toString() == 'City.${json['startCity']}',
      ),
      destinationCity: City.values.firstWhere(
        (e) => e.toString() == 'City.${json['destinationCity']}',
      ),
      startLocation: json['startLocation'] != null
          ? LatLng(
              double.parse(json['startLocation']['latitude'].toString()),
              double.parse(json['startLocation']['longitude'].toString()),
            )
          : null,
      destinationLocation: json['destinationLocation'] != null
          ? LatLng(
              double.parse(json['destinationLocation']['latitude'].toString()),
              double.parse(json['destinationLocation']['longitude'].toString()),
            )
          : null,
      distance: double.parse(json['distance'].toString()),
      estimatedTime: int.parse(json['estimatedTime'].toString()),
      price: double.parse(json['price'].toString()),
      companyFee: double.parse(json['companyFee'].toString()),
      driverType: DriverType.values.firstWhere(
        (e) => e.toString() == 'DriverType.${json['driverType']}',
      ),
      tripType: TripType.values.firstWhere(
        (e) => e.toString() == 'TripType.${json['tripType']}',
      ),
      status: TripStatus.values.firstWhere(
        (e) => e.toString() == 'TripStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['createdAt']),
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
      ),
      TripCode: json['TripCode'] ?? "no code",
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      // ignore: prefer_if_null_operators
      'id': id != null ? id : null,
      'startCity': startCity.toString().split('.').last,
      'destinationCity': destinationCity.toString().split('.').last,
      'startLocation': startLocation != null
          ? {
              'latitude': startLocation!.latitude,
              'longitude': startLocation!.longitude,
            }
          : null,
      'destinationLocation': destinationLocation != null
          ? {
              'latitude': destinationLocation!.latitude,
              'longitude': destinationLocation!.longitude,
            }
          : null,
      'distance': distance,
      'estimatedTime': estimatedTime,
      'price': price,
      'companyFee': companyFee,
      'driverType': driverType.toString().split('.').last,
      'tripType': tripType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'customer': customer?.toJson(),
      'driver': driver?.toJson(),
      'paymentMethod': paymentMethod.toString().split('.').last,
      'TripCode': TripCode,
    };
  }

  // إنشاء نسخة جديدة مع تحديث بعض الخصائص
  Trip copyWith({
    String? id,
    City? startCity,
    City? destinationCity,
    LatLng? startLocation,
    LatLng? destinationLocation,
    double? distance,
    int? estimatedTime,
    double? price,
    double? companyFee,
    DriverType? driverType,
    TripType? tripType,
    TripStatus? status,
    DateTime? createdAt,
    Driver? driver,
    Customer? customer,
    PaymentMethod? paymentMethod,
    String? TripCode,
  }) {
    return Trip(
      id: id ?? this.id,
      startCity: startCity ?? this.startCity,
      destinationCity: destinationCity ?? this.destinationCity,
      startLocation: startLocation ?? this.startLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      distance: distance ?? this.distance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      price: price ?? this.price,
      companyFee: companyFee ?? this.companyFee,
      driverType: driverType ?? this.driverType,
      tripType: tripType ?? this.tripType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      customer: customer,
      driver: driver,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      TripCode: TripCode ?? this.TripCode,
    );
  }
}
