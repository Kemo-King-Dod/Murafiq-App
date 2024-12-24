import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/trip.dart';
import 'package:murafiq/models/driver.dart';
import 'package:murafiq/models/customer.dart';

class TripsManagementPage extends StatefulWidget {
  const TripsManagementPage({Key? key}) : super(key: key);

  @override
  _TripsManagementPageState createState() => _TripsManagementPageState();
}

class _TripsManagementPageState extends State<TripsManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _selectedTab = 'ongoing'.obs;
  final RxList<Trip> _trips = <Trip>[].obs;
  final RxList<Trip> _filteredTrips = <Trip>[].obs;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  void _loadTrips() async {
    _trips.value = [];
    final response = await sendRequestWithHandler(
      endpoint: '/admin/trips',
      method: 'GET',
    );
    if (response != null && response['data'] != null) {
      final tripsList = response['data']['trips'] as List? ?? [];
      _trips.addAll(
          tripsList.map((tripData) => Trip.fromJson(tripData)).toList());
    }
    // TODO: Replace with actual backend data fetching

    _filterTrips(_searchController.text);
    setState(() {});
  }

  void _filterTrips(String query) {
    if (query.isEmpty) {
      _filteredTrips.value = _selectedTab.value == 'ongoing'
          ? _trips
              .where((trip) =>
                  trip.status != TripStatus.completed &&
                  trip.status != TripStatus.cancelled)
              .toList()
          : _trips
              .where((trip) =>
                  trip.status == TripStatus.completed ||
                  trip.status == TripStatus.cancelled)
              .toList();
    } else {
      _filteredTrips.value = _trips.where((trip) {
        final matchesDriverName =
            trip.driver?.name.toLowerCase().contains(query.toLowerCase()) ??
                false;
        final matchesCustomerName =
            trip.customer?.name.toLowerCase().contains(query.toLowerCase()) ??
                false;
        final matchesTripId = trip.id!.contains(query);
        return (matchesDriverName || matchesCustomerName || matchesTripId) &&
            (_selectedTab.value == 'ongoing'
                ? trip.status != TripStatus.completed
                : trip.status == TripStatus.completed ||
                    trip.status == TripStatus.cancelled);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: systemColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: systemColors.primary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'إدارة الرحلات',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: systemColors.primary,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          Expanded(
            child: Obx(() => _buildTripsList()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _filterTrips,
            decoration: InputDecoration(
              hintText: 'البحث برقم الرحلة أو اسم السائق أو العميل',
              prefixIcon: Icon(Icons.search, color: systemColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: systemColors.primary.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: systemColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildTabButton('ongoing', 'الرحلات الجارية'),
              SizedBox(width: 16),
              _buildTabButton('completed', 'الرحلات المكتملة'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label) {
    return Expanded(
      child: Obx(() => ElevatedButton(
            onPressed: () {
              _selectedTab.value = tab;
              _filterTrips(_searchController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedTab.value == tab
                  ? systemColors.primary
                  : Colors.white,
              side: BorderSide(
                color: systemColors.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: _selectedTab.value == tab
                    ? Colors.white
                    : systemColors.primary,
              ),
            ),
          )),
    );
  }

  Widget _buildTripsList() {
    if (_filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Bootstrap.map,
              size: 100,
              color: systemColors.primary.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد رحلات',
              style: TextStyle(
                color: systemColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredTrips.length,
      itemBuilder: (context, index) {
        final trip = _filteredTrips[index];
        return _buildTripCard(trip);
      },
    );
  }

  Widget _buildTripCard(Trip trip) {
    return GestureDetector(
      onTap: () => _showTripDetailsBottomSheet(trip),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getGradientStartColor(trip),
              _getGradientEndColor(trip),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getStatusColor(trip.status).withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'رقم الرحلة: ${trip.TripCode}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(trip.status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getStatusText(trip.status),
                        style: TextStyle(
                          color: systemColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildTripDetails(trip),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetails(Trip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRowIcon(
          Icons.location_on_outlined,
          'من: ${trip.startCity.arabicName.toString().split('.').last}',
        ),
        SizedBox(height: 8),
        _buildDetailRowIcon(
          Icons.location_on,
          'إلى: ${trip.destinationCity.arabicName.toString().split('.').last}',
        ),
        SizedBox(height: 16),
        _buildInfoChip(
          Icons.drive_eta,
          'السائق: ${trip.driver?.name ?? 'غير محدد'}',
        ),
        SizedBox(height: 8),
        _buildInfoChip(
          Icons.person,
          'العميل: ${trip.customer?.name ?? 'غير محدد'}',
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoChip(
              Icons.attach_money,
              'السعر: ${trip.price} ر.س',
            ),
            _buildInfoChip(
              Icons.calendar_today,
              'التاريخ: ${_formatDate(trip.createdAt)}',
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildDetailRow(String icon, String text) {
  //   return Row(
  //     children: [
  //       Text(
  //         text,
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: 14,
  //         ),
  //       ),
  //       SizedBox(width: 8),
  //       Text(
  //         text,
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: 14,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDetailRowIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.completed:
        return Colors.green.shade400;
      case TripStatus.cancelled:
        return Colors.red.shade400;
      default:
        return Colors.orange.shade400;
    }
  }

  String _getStatusText(TripStatus status) {
    switch (status) {
      case TripStatus.completed:
        return 'مكتملة';
      case TripStatus.cancelled:
        return 'ملغاة';
      default:
        return "جاري التنفيذ";
    }
  }

  Color _getGradientStartColor(Trip trip) {
    if (trip.status != TripStatus.completed &&
        trip.status != TripStatus.cancelled) {
      return trip.driverType == DriverType.male
          ? Colors.orange.shade400
          : Colors.deepOrange.shade400;
    } else if (trip.status == TripStatus.cancelled) {
      return Colors.red.shade400;
    } else {
      return trip.driverType == DriverType.male
          ? Colors.green.shade400
          : Colors.teal.shade400;
    }
  }

  Color _getGradientEndColor(Trip trip) {
    if (trip.status != TripStatus.completed &&
        trip.status != TripStatus.cancelled) {
      return trip.driverType == DriverType.male
          ? Colors.orange.shade600
          : Colors.deepOrange.shade600;
    } else if (trip.status == TripStatus.cancelled) {
      return Colors.red.shade600;
    } else {
      return trip.driverType == DriverType.male
          ? Colors.green.shade600
          : Colors.teal.shade600;
    }
  }

  void _showTripDetailsBottomSheet(Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                controller: controller,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'تفاصيل الرحلة',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: systemColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildDetailRow('رقم الرحلة', trip.id ?? 'غير محدد'),
                        _buildDetailRow(
                            'المدينة المصدر',
                            trip.startCity.arabicName
                                .toString()
                                .split('.')
                                .last),
                        _buildDetailRow(
                            'المدينة الوجهة',
                            trip.destinationCity.arabicName
                                .toString()
                                .split('.')
                                .last),
                        _buildDetailRow(
                            'نوع الرحلة',
                            trip.tripType == TripType.intercity
                                ? 'بين المدن'
                                : 'داخل المدينة'),
                        _buildDetailRow('المسافة', '${trip.distance} كم'),
                        _buildDetailRow(
                            'الوقت المتوقع', '${trip.estimatedTime} دقيقة'),
                        _buildDetailRow('السعر', '${trip.price} ر.س'),
                        _buildDetailRow(
                            'رسوم الشركة', '${trip.companyFee} ر.س'),
                        _buildDetailRow(
                            'طريقة الدفع',
                            trip.paymentMethod == PaymentMethod.cash
                                ? 'نقداً'
                                : 'محفظة'),
                        SizedBox(height: 16),
                        Text(
                          'معلومات السائق',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: systemColors.primary,
                          ),
                        ),
                        _buildDetailRow(
                            'الاسم', trip.driver?.name ?? 'غير محدد'),
                        _buildDetailRow(
                            'رقم الهاتف', trip.driver?.phone ?? 'غير محدد'),
                        _buildDetailRow('رقم السيارة',
                            trip.driver?.carNumber ?? 'غير محدد'),
                        SizedBox(height: 16),
                        Text(
                          'معلومات العميل',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: systemColors.primary,
                          ),
                        ),
                        _buildDetailRow(
                            'الاسم', trip.customer?.name ?? 'غير محدد'),
                        _buildDetailRow(
                            'رقم الهاتف', trip.customer?.phone ?? 'غير محدد'),
                        SizedBox(height: 24),
                        if (trip.status != TripStatus.completed &&
                            trip.status != TripStatus.cancelled)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showConfirmationDialog(
                                        trip,
                                        'إنهاء الرحلة',
                                        'هل أنت متأكد من إنهاء هذه الرحلة؟',
                                        () async {
                                      // TODO: Implement trip completion logic
                                      final response =
                                          await sendRequestWithHandler(
                                        endpoint: "/admin/complete_trip",
                                        body: {
                                          "tripId": trip.id,
                                          "status": trip.status.toString(),
                                        },
                                        method: "PATCH",
                                      );
                                      print(response.toString());
                                      Navigator.pop(context);
                                      _loadTrips(); // Refresh trips
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'إنهاء الرحلة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showConfirmationDialog(
                                        trip,
                                        'إلغاء الرحلة',
                                        'هل أنت متأكد من إلغاء هذه الرحلة؟',
                                        () async {
                                      final response =
                                          await sendRequestWithHandler(
                                        endpoint: "/admin/cancel_trip",
                                        body: {
                                          "tripId": trip.id,
                                          "status": trip.status.toString(),
                                        },
                                        method: "PATCH",
                                      );
                                      print(response.toString());
                                      Navigator.pop(context);
                                      _loadTrips(); // Refresh trips
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'إلغاء الرحلة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: systemColors.dark,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: systemColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
      Trip trip, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: systemColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'تأكيد',
                style: TextStyle(color: systemColors.primary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }
}
