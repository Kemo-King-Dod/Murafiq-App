import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/admin/subScreens/driver_details.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/driver.dart';

class DriversManagementPage extends StatefulWidget {
  const DriversManagementPage({Key? key}) : super(key: key);

  @override
  _DriversManagementPageState createState() => _DriversManagementPageState();
}

class _DriversManagementPageState extends State<DriversManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _selectedTab = 'all'.obs;
  final RxList<Driver> _drivers = <Driver>[].obs;
  final RxList<Driver> _filteredDrivers = <Driver>[].obs;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  void _loadDrivers() async {
    _drivers.value = [];

    final response = await sendRequestWithHandler(
      endpoint: '/admin/get_drivers',
      method: 'GET',
    );

    print(response.toString());
    if (response != null && response['data'] != null) {
      final driversList = response['data']['drivers'] as List? ?? [];
      _drivers.addAll(driversList
          .map((driverData) => Driver.fromJson(driverData))
          .toList());
    }

    // TODO: Implement actual driver fetching from backend
    // _drivers.value = [
    //   Driver(
    //     id: '1',
    //     name: 'محمد أحمد',
    //     phone: '0912345678',
    //     status: DriverStatus.active,
    //     gender: 'male',
    //     idNumber: 'fewr332',
    //     carNumber: '324f',
    //   ),
    //   Driver(
    //     id: '2',
    //     name: 'علي محمود',
    //     phone: '0923456789',
    //     status: DriverStatus.pending,
    //     gender: 'male',
    //     idNumber: '324234',
    //     carNumber: '242342',
    //   ),
    //   // Add more dummy data
    // ];
    _filteredDrivers.value = _drivers;
  }

  void _filterDrivers(String query) {
    if (query.isEmpty) {
      _filteredDrivers.value = _selectedTab.value == 'all'
          ? _drivers
          : _drivers
              .where((driver) => driver.status == DriverStatus.pending)
              .toList();
    } else {
      _filteredDrivers.value = _drivers.where((driver) {
        final matchesName =
            driver.name.toLowerCase().contains(query.toLowerCase());
        final matchesPhone = driver.phone.contains(query);
        return (matchesName || matchesPhone) &&
            (_selectedTab.value == 'all' ||
                driver.status == DriverStatus.pending);
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
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          'إدارة السائقين',
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
            child: Obx(() => _buildDriversList()),
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
            onChanged: _filterDrivers,
            decoration: InputDecoration(
              hintText: 'البحث باسم أو رقم هاتف السائق',
              prefixIcon: Icon(Icons.search, color: systemColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: systemColors.primary.withValues(alpha: 0.3),
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
              _buildTabButton('all', 'كل السائقين'),
              SizedBox(width: 16),
              _buildTabButton('pending', 'طلبات التسجيل'),
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
              _filterDrivers(_searchController.text);
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

  Widget _buildDriversList() {
    if (_filteredDrivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Bootstrap.car_front,
              size: 100,
              color: systemColors.primary.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد سائقين',
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
      itemCount: _filteredDrivers.length,
      itemBuilder: (context, index) {
        final driver = _filteredDrivers[index];
        return _buildDriverCard(driver);
      },
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return InkWell(
      onTap: () => Get.to(() => DriverDetails(driver: driver)),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getGradientStartColor(driver),
              _getGradientEndColor(driver),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getStatusColor(driver.status).withValues(alpha: 0.3),
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
            child: Row(
              children: [
                _buildDriverAvatar(driver),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.white70,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            driver.phone,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            driver.gender == 'male' ? Icons.male : Icons.female,
                            color: Colors.white70,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            driver.gender == 'male' ? 'ذكر' : 'أنثى',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(driver.status),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getStatusText(driver.status),
                          style: TextStyle(
                            color: systemColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _showDriverOptionsBottomSheet(driver);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverAvatar(Driver driver) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            'https://ui-avatars.com/api/?name=${driver.name.split(' ').reversed.join(' ')}&background=random&color=white&size=128',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(driver.status).withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  void _showDriverOptionsBottomSheet(Driver driver) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'خيارات السائق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: systemColors.primary,
                ),
              ),
              SizedBox(height: 16),
              _buildBottomSheetAction(
                icon: Icons.visibility,
                label: 'عرض التفاصيل',
                onTap: () {
                  // TODO: Navigate to driver details
                  Navigator.pop(context);
                },
              ),
              if (driver.status == DriverStatus.pending)
                _buildBottomSheetAction(
                  icon: Icons.check_circle,
                  label: 'قبول الطلب',
                  onTap: () {
                    // TODO: Implement driver approval
                    Navigator.pop(context);
                  },
                ),
              _buildBottomSheetAction(
                icon: Icons.block,
                label: 'حظر السائق',
                onTap: () {
                  // TODO: Implement driver blocking
                  Navigator.pop(context);
                },
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : systemColors.primary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : systemColors.dark,
        ),
      ),
      onTap: onTap,
    );
  }

  Color _getStatusColor(DriverStatus status) {
    switch (status) {
      case DriverStatus.active:
        return Colors.green.shade400;
      case DriverStatus.pending:
        return Colors.orange;
      case DriverStatus.blocked:
        return Colors.red;
    }
  }

  String _getStatusText(DriverStatus status) {
    switch (status) {
      case DriverStatus.active:
        return 'نشط';
      case DriverStatus.pending:
        return 'قيد الانتظار';
      case DriverStatus.blocked:
        return 'محظور';
    }
  }

  Color _getGradientStartColor(Driver driver) {
    if (driver.status == DriverStatus.active) {
      if (driver.gender == 'male') {
        return Colors.green.shade400;
      } else {
        return Colors.pink.shade400;
      }
    } else if (driver.status == DriverStatus.pending) {
      if (driver.gender == 'male') {
        return Colors.orange.shade400;
      } else {
        return Colors.yellow.shade400;
      }
    } else {
      return Colors.red.shade400;
    }
  }

  Color _getGradientEndColor(Driver driver) {
    if (driver.status == DriverStatus.active) {
      if (driver.gender == 'male') {
        return Colors.green.shade600;
      } else {
        return Colors.pink.shade600;
      }
    } else if (driver.status == DriverStatus.pending) {
      if (driver.gender == 'male') {
        return Colors.orange.shade600;
      } else {
        return Colors.yellow.shade600;
      }
    } else {
      return Colors.red.shade600;
    }
  }
}
