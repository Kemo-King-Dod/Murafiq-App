enum CustomerStatus { active, blocked }

class Customer {
  final String? id;
  final String name;
  final String phone;
  final String gender;
  final double? rating;
  final String? profileImage;
  CustomerStatus status;

  Customer({
    this.status = CustomerStatus.active,
    this.id,
    required this.name,
    required this.phone,
    required this.gender,
    this.rating,
    this.profileImage,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      status: CustomerStatus.values.firstWhere(
        (e) => e.toString() == 'CustomerStatus.${json['status']}',
        orElse: () => CustomerStatus.active,
      ),
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : null,
      profileImage: json['profileImage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'gender': gender,
      'rating': rating,
      'profileImage': profileImage,
      'status': status.toString().split('.').last,
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? gender,
    double? rating,
    String? profileImage,
    CustomerStatus? status,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      rating: rating ?? this.rating,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
    );
  }
}
