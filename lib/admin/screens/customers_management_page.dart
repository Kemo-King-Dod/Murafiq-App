import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/admin/subScreens/customer_details.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/customer.dart';

class CustomersManagementPage extends StatefulWidget {
  const CustomersManagementPage({Key? key}) : super(key: key);

  @override
  _CustomersManagementPageState createState() =>
      _CustomersManagementPageState();
}

class _CustomersManagementPageState extends State<CustomersManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _selectedTab = 'active'.obs;
  final RxList<Customer> _customers = <Customer>[].obs;
  final RxList<Customer> _filteredCustomers = <Customer>[].obs;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() async {
    // TODO: Implement actual customer fetching from backend
    _customers.value = [
      // Customer(
      //   id: '1',
      //   name: 'فاطمة محمد',
      //   phone: '0912345678',
      //   status: CustomerStatus.active,
      //   gender: 'male',
      // ),
      // Customer(
      //   id: '2',
      //   name: 'أحمد علي',
      //   phone: '0923456789',
      //   status: CustomerStatus.blocked,
      //   gender: 'male',
      // ),
      // Customer(
      //   id: '3',
      //   name: 'مريم إبراهيم',
      //   phone: '0934567890',
      //   status: CustomerStatus.active,
      //   gender: 'female',
      // ),
    ];
    final response = await sendRequestWithHandler(
        endpoint: "/admin/get_customers", method: "GET");
    print(response);
    if (response != null && response["data"] != null) {
      final customersList = response["data"]['customers'] as List? ?? [];
      _customers.value = customersList
          .map((customerData) => Customer.fromJson(customerData))
          .toList();
    }
    _filteredCustomers.value = _customers
        .where((customer) => customer.status == CustomerStatus.active)
        .toList();
  }

  void _filterCustomers(String query) {
    if (query.isEmpty) {
      _filteredCustomers.value = _selectedTab.value == 'active'
          ? _customers
              .where((customer) => customer.status == CustomerStatus.active)
              .toList()
          : _customers
              .where((customer) => customer.status == CustomerStatus.blocked)
              .toList();
    } else {
      _filteredCustomers.value = _customers.where((customer) {
        final matchesName =
            customer.name.toLowerCase().contains(query.toLowerCase());
        final matchesPhone = customer.phone.contains(query);
        return (matchesName || matchesPhone) &&
            (_selectedTab.value == 'active'
                ? customer.status == CustomerStatus.active
                : customer.status == CustomerStatus.blocked);
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
          'إدارة العملاء',
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
            child: Obx(() => _buildCustomersList()),
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
            onChanged: _filterCustomers,
            decoration: InputDecoration(
              hintText: 'البحث باسم أو رقم هاتف العميل',
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
              _buildTabButton('active', 'العملاء النشطون'),
              SizedBox(width: 16),
              _buildTabButton('blocked', 'العملاء المحظورون'),
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
              _filterCustomers(_searchController.text);
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

  Widget _buildCustomersList() {
    if (_filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Bootstrap.people,
              size: 100,
              color: systemColors.primary.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'لا يوجد عملاء',
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
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return GestureDetector(
      onTap: () => Get.to(() => CustomerDetails(customer: customer)),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getGradientStartColor(customer),
              _getGradientEndColor(customer),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getStatusColor(customer.status).withOpacity(0.3),
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
                _buildCustomerAvatar(customer),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
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
                            customer.phone,
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
                            customer.gender == 'male'
                                ? Icons.male
                                : Icons.female,
                            color: Colors.white70,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            customer.gender == 'male' ? 'ذكر' : 'أنثى',
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
                          color: _getStatusColor(customer.status),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getStatusText(customer.status),
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
                    _showCustomerOptionsBottomSheet(customer);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerAvatar(Customer customer) {
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
            'https://ui-avatars.com/api/?name=${customer.name.split(' ').reversed.join(' ')}&background=random&color=white&size=128',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(customer.status).withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  void _showCustomerOptionsBottomSheet(Customer customer) {
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
                'خيارات العميل',
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
                  // TODO: Navigate to customer details
                  Navigator.pop(context);
                },
              ),
              if (customer.status == CustomerStatus.active)
                _buildBottomSheetAction(
                  icon: Icons.block,
                  label: 'حظر العميل',
                  onTap: () {
                    // TODO: Implement customer blocking
                    Navigator.pop(context);
                  },
                  isDestructive: true,
                ),
              if (customer.status == CustomerStatus.blocked)
                _buildBottomSheetAction(
                  icon: Icons.check_circle,
                  label: 'إلغاء الحظر',
                  onTap: () {
                    // TODO: Implement customer unblocking
                    Navigator.pop(context);
                  },
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

  Color _getStatusColor(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.active:
        return Colors.green.shade400;
      case CustomerStatus.blocked:
        return Colors.red;
    }
  }

  String _getStatusText(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.active:
        return 'نشط';
      case CustomerStatus.blocked:
        return 'محظور';
    }
  }

  Color _getGradientStartColor(Customer customer) {
    if (customer.status == CustomerStatus.active) {
      if (customer.gender == 'male') {
        return Colors.green.shade400;
      } else {
        return Colors.pink.shade400;
      }
    } else {
      return Colors.red.shade400;
    }
  }

  Color _getGradientEndColor(Customer customer) {
    if (customer.status == CustomerStatus.active) {
      if (customer.gender == 'male') {
        return Colors.green.shade600;
      } else {
        return Colors.pink.shade600;
      }
    } else {
      return Colors.red.shade600;
    }
  }
}
