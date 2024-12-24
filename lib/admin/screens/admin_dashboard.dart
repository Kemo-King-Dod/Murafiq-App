import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/admin/screens/customers_management_page.dart';
import 'package:murafiq/admin/screens/notifications_management_page.dart';
import 'package:murafiq/admin/screens/offers_mangement_page.dart';
import 'package:murafiq/auth/login_page.dart';
import 'package:murafiq/admin/screens/drivers_management_page.dart';
import 'package:murafiq/admin/screens/trips_management_page.dart';
import 'package:murafiq/admin/screens/transactions_management_page.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'تسجيل الخروج',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: systemColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: systemColors.primary,
                  ),
                  child: Text('تأكيد'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.offAll(() => LoginPage());
                  },
                ),
              ],
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'لوحة التحكم',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: systemColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDashboardHeader(),
              SizedBox(height: 20),
              _buildDashboardGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            systemColors.primary.withValues(alpha: 0.7),
            systemColors.primary.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: systemColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 3,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحبًا، المسؤول',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'نظرة عامة على نشاط المنصة',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid() {
    final dashboardItems = [
      _DashboardItem(
        title: 'السائقين',
        icon: Bootstrap.car_front,
        color: Colors.blue,
        onTap: () {
          Get.to(() => DriversManagementPage());
        },
      ),
      _DashboardItem(
        title: 'العملاء',
        icon: Bootstrap.people,
        color: Colors.green,
        onTap: () {
          // TODO: Navigate to Customers Management
          Get.to(() => CustomersManagementPage());
        },
      ),
      _DashboardItem(
        title: 'الرحلات',
        icon: Bootstrap.map,
        color: Colors.orange,
        onTap: () {
          Get.to(() => TripsManagementPage());
        },
      ),
      _DashboardItem(
        title: 'المعاملات',
        icon: Bootstrap.wallet2,
        color: Colors.purple,
        onTap: () {
          Get.to(() => TransactionsManagementPage());
        },
      ),
      _DashboardItem(
        title: 'الإعلانات',
        icon: Bootstrap.megaphone,
        color: Colors.red,
        onTap: () {
          Get.to(() => OffersMangementPage());
        },
      ),
      _DashboardItem(
        title: 'الإشعارات',
        icon: Bootstrap.bell,
        color: Colors.teal,
        onTap: () {
          Get.to(() => NotificationsManagementPage());
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: dashboardItems.length,
      itemBuilder: (context, index) {
        return _buildDashboardItemCard(dashboardItems[index]);
      },
    );
  }

  Widget _buildDashboardItemCard(_DashboardItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 3,
              offset: Offset(0, 7),
            ),
          ],
          border: Border.all(
            color: item.color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.color.withValues(alpha: 0.4),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 45,
                color: item.color,
              ),
            ),
            SizedBox(height: 15),
            Text(
              item.title,
              style: TextStyle(
                color: item.color.darken(0.2),
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}
