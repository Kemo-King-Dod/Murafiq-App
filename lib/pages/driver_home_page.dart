import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/trip.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/auth_controller.dart';
import '../core/services/trip_service.dart';

class DriverHomePage extends StatefulWidget {
  DriverHomePage({Key? key}) : super(key: key);

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RxBool isAvailable = true.obs;
  final Rx<Trip?> currentTrip = Rx<Trip?>(null);
  Timer? _tripCheckTimer;

  @override
  void initState() {
    super.initState();
    _startTripChecking();
  }

  @override
  void dispose() {
    _tripCheckTimer?.cancel();
    super.dispose();
  }

  // بدء التحقق من الرحلات المتاحة
  void _startTripChecking() {
    // التحقق الأولي
    _checkForTrips();

    // بدء التحقق الدوري كل 5 ثواني
    _tripCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (isAvailable.value && currentTrip.value == null) {
        _checkForTrips();
      }
    });
  }

  // التحقق من وجود رحلات متاحة
  Future<void> _checkForTrips() async {
    if (!isAvailable.value) return;

    final trip = await TripService.getAvailableTrip();

    if (trip != null) {
      currentTrip.value = trip;
    }
  }

  // قبول الرحلة
  Future<void> _acceptTrip() async {
    if (currentTrip.value == null) return;

    final success = await TripService.acceptTrip(currentTrip.value!.id!);
    if (success) {
      Get.snackbar(
        'تم',
        'تم قبول الرحلة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // تحديث حالة الرحلة محلياً
      currentTrip.value = currentTrip.value!.copyWith(
        status: TripStatus.accepted,
      );
    }
  }

  // رفض الرحلة
  Future<void> _rejectTrip() async {
    if (currentTrip.value == null) return;

    final success = await TripService.rejectTrip(currentTrip.value!.id!);
    if (success) {
      Get.snackbar(
        'تم',
        'تم رفض الرحلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      currentTrip.value = null;
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح الرابط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: systemColors.white,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person,
                                  size: 40, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'اسم السائق',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'رقم الهاتف',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.person_outline,
                      title: 'الملف الشخصي',
                      iconColor: Colors.blue[700],
                      onTap: () {
                        Get.back();
                        // TODO: التنقل إلى صفحة الملف الشخصي
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.history_rounded,
                      title: 'السجل',
                      iconColor: Colors.purple[400],
                      onTap: () {
                        Get.back();
                        // TODO: التنقل إلى صفحة السجل
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'المحفظة',
                      iconColor: Colors.green[600],
                      onTap: () {
                        Get.back();
                        // TODO: التنقل إلى صفحة المحفظة
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.notifications_rounded,
                      title: 'الإشعارات',
                      iconColor: Colors.orange[600],
                      onTap: () {
                        Get.back();
                        // TODO: التنقل إلى صفحة الإشعارات
                      },
                    ),
                    const Divider(height: 40),
                    _buildDrawerItem(
                      icon: FontAwesome.whatsapp_brand,
                      iconColor: const Color(0xFF25D366), // لون واتساب الرسمي
                      title: 'المساعدة والدعم',
                      onTap: () {
                        _launchURL('https://wa.me/+966XXXXXXXXX');
                        Get.back();
                      },
                    ),
                    _buildDrawerItem(
                      icon: FontAwesomeIcons.facebook,
                      iconColor: const Color(0xFF1877F2), // لون فيسبوك الرسمي
                      title: 'صفحتنا على فيسبوك',
                      onTap: () {
                        _launchURL('https://facebook.com/murafiq');
                        Get.back();
                      },
                    ),
                    const Divider(height: 40),
                    _buildDrawerItem(
                      icon: Icons.logout_rounded,
                      title: 'تسجيل الخروج',
                      iconColor: Colors.red[600],
                      textColor: Colors.red[600],
                      onTap: () {
                        Get.back();
                        authController.logout();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // زر فتح القائمة
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    tooltip: 'القائمة الرئيسية',
                  ),
                ),
              ),

              // زر تبديل الحالة
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text('وضع السائق ', style: systemTextStyle.mediumDark),
                  trailing: Obx(() => Switch.adaptive(
                        value: isAvailable.value,
                        onChanged: (value) {
                          isAvailable.value = value;
                          // TODO: تحديث حالة السائق في الباك اند
                        },
                        activeColor: systemColors.primary,
                        activeTrackColor: systemColors.primary.withOpacity(0.5),
                      )),
                ),
              ),

              // محتوى الصفحة
              Expanded(
                child: _buildRequestCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لبناء تفاصيل الرحلة
  Widget _buildTripDetail({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // دالة لبناء بطاقة الطلب
  Widget _buildRequestCard() {
    return Obx(() {
      final trip = currentTrip.value;

      if (trip == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'جاري البحث عن رحلات...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        decoration: BoxDecoration(
          color: systemColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // نقطة الانطلاق
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: systemColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: systemColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مدينة الانطلاق',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trip.startCity.arabicName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // خط عمودي
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                width: 2,
                height: 30,
                color: systemColors.primary,
              ),

              // نقطة الوصول
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مدينة الوجهة',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trip.destinationCity.arabicName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // فتح خريطة لعرض المسار
                      final Uri url = Uri.parse(
                        'https://www.google.com/maps/dir/?api=1&origin=${Uri.encodeComponent(trip.startCity.arabicName)}&destination=${Uri.encodeComponent(trip.destinationCity.arabicName)}&travelmode=driving',
                      );
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    icon: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_rounded,
                          color: systemColors.primary,
                          size: 28,
                        ),
                        Text(
                          'المسار',
                          style: TextStyle(
                            color: systemColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    tooltip: 'عرض المسار على الخريطة',
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),

              // تفاصيل الرحلة
              Column(
                children: [
                  // الصف الأول: المسافة والوقت
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildTripDetail(
                          icon: Icons.route_rounded,
                          title: 'المسافة',
                          value: '${trip.distance} كم',
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildTripDetail(
                          icon: Icons.timer_rounded,
                          title: 'الوقت المتوقع',
                          value: '${trip.estimatedTime} دقيقة',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // الصف الثاني: السعر ومستحقات الشركة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildTripDetail(
                          icon: Icons.attach_money_rounded,
                          title: 'السعر',
                          value: '${trip.price} دينار',
                          color: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildTripDetail(
                          icon: Icons.business_rounded,
                          title: 'مستحقات الشركة',
                          value: '${trip.companyFee} دينار',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // أزرار القبول والرفض
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _acceptTrip,
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('قبول الطلب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _rejectTrip,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('رفض الطلب'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // دالة مساعدة لبناء تفاصيل الموقع
  Widget _buildLocationDetail(
    String title,
    String location,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: systemTextStyle.smallDark,
              ),
              Text(
                location,
                style: systemTextStyle.mediumDark.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Colors.grey[700],
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minLeadingWidth: 20,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
