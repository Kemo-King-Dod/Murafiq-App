enum DriverStatus {
  pending,
  active,
  blocked,
}

class Driver {
  final String? id;
  final String name;
  final String phone;
  final String gender;
  final String licenseNumber;
  final String carNumber;
  String? profileImage;
  String? licenseImage;
  String? passPortImage;
  String? backLicenseImage;
  String? vehicleBookImage;

  String? vehicleImage;
  DriverStatus status;
  double balance;

  Driver({
    this.status = DriverStatus.pending,
    this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.licenseNumber,
    required this.carNumber,
    this.passPortImage,
    this.backLicenseImage,
    this.vehicleBookImage,
    this.vehicleImage,
    this.profileImage,
    this.licenseImage,
    this.balance = 0.0,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      licenseNumber: json['licenseNumber']?.toString() ?? '',
      carNumber: json['carNumber']?.toString() ?? '',
      status: DriverStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
        orElse: () => DriverStatus.pending,
      ),
      profileImage: json['profileImage']?.toString() ?? '',
      licenseImage: json['licenseImage']?.toString() ?? '',
      passPortImage: json['passportImage']?.toString() ?? '',
      backLicenseImage: json['backLicenseImage']?.toString() ?? '',
      vehicleBookImage: json['vehicleBookImage']?.toString() ?? '',
      vehicleImage: json['vehicleImage']?.toString() ?? '',
      balance: json['balance']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'gender': gender,
      'idNumber': licenseNumber,
      'carNumber': carNumber,
    };
  }

  Driver copyWith({
    String? id,
    String? name,
    String? phone,
    String? gender,
    String? licenseNumber,
    String? carNumber,
    DriverStatus? status,
    String? profileImage,
    String? licenseImage,
    double? balance,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      carNumber: carNumber ?? this.carNumber,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      licenseImage: licenseImage ?? this.licenseImage,
      balance: balance ?? this.balance,
    );
  }
}
