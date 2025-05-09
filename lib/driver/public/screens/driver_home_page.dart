import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/driver/public/controllers/driver_home_controller.dart';
import 'package:murafiq/driver/public/controllers/driver_profile_controller.dart';
import 'package:murafiq/models/trip.dart';

import 'package:murafiq/shared/widgets/app_darwer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/trip_service.dart';

class DriverHomePage extends StatelessWidget {
  DriverHomePage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final controller = Get.put(DriverHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: AppDarwer.buildDrawer(userType: UserType.driver),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // زر فتح القائمة
              Obx(
                () => SizedBox(
                  width: Get.width,
                  child: Row(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.menu_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 28,
                            ),
                            onPressed: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                            tooltip: 'القائمة الرئيسية',
                          ),
                        ),
                      ),
                      TripService.driverStatus.value == "" ||
                              TripService.driverStatus.value == "active"
                          ? Container()
                          : Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: 30,
                                alignment: Alignment.center,
                                width: Get.width / 1.5,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: getStatusColor(
                                          TripService.driverStatus.value)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  TripService.driverStatus.value == "blocked"
                                      ? "محظور".tr
                                      : "معلق".tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: getStatusColor(
                                          TripService.driverStatus.value)),
                                ),
                              ),
                            ),
                      const Spacer()
                    ],
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
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Row(
                    children: [
                      Text('وضع السائق'.tr, style: systemTextStyle.mediumDark),
                      const SizedBox(width: 10),
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: controller.socketController.socket
                                      .isConnecting.value
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : controller.socketController.socket
                                          .isConnected.value
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controller.socketController.socket.isConnecting
                                      .value
                                  ? 'جاري الاتصال...'.tr
                                  : controller.socketController.socket
                                          .isConnected.value
                                      ? 'متصل'.tr
                                      : 'غير متصل'.tr,
                              style: TextStyle(
                                color: controller.socketController.socket
                                        .isConnected.value
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          )),
                    ],
                  ),
                  trailing: Obx(() => Switch.adaptive(
                        value: controller.isAvailable.value &&
                            controller
                                .socketController.socket.isConnected.value,
                        onChanged: controller.toggleAvailability,
                        activeColor: systemColors.primary,
                        activeTrackColor:
                            systemColors.primary.withValues(alpha: 0.5),
                      )),
                ),
              ),
              const SizedBox(
                height: 20,
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

  Widget _buildRequestCard() {
    return Obx(() {
      if (!controller.isAvailable.value) {
        return _buildOfflineState();
      }

      if (TripService.driverStatus.value != "active") {
        return Container();
      }

      if (controller.availableTrips.isEmpty) {
        return _buildWaitingState();
      }

      return _buildTripsList();
    });
  }

  Widget _buildOfflineState() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.power_settings_new_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'وضع الاستقبال مغلق'.tr,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 250,
            child: Text(
              'قم بتفعيل وضع الاستقبال للبدء في استقبال الطلبات'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingState() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: controller.scaleAnimation,
            child: FadeTransition(
              opacity: controller.opacityAnimation,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(Get.context!)
                      .primaryColor
                      .withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.local_taxi_rounded,
                  size: 80,
                  color: Theme.of(Get.context!).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'في انتظار الطلبات...'.tr,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // Handle the tap event
              controller.refreshTrips();
            },
            child: SizedBox(
              width: 250,
              child: Text(
                'سيتم إشعارك فور وصول طلب جديد في منطقتك'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList() {
    return ListView.builder(
      itemCount: controller.availableTrips.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final trip = controller.availableTrips[index];
        return _buildTripCard(trip);
      },
    );
  }

  Widget _buildTripCard(Trip trip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: systemColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
                    color: systemColors.primary.withValues(alpha: 0.1),
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
                        trip.startCity,
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
                    color: Colors.green.withValues(alpha: 0.1),
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
                        trip.destinationCity,
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
            IconButton(
              onPressed: () {
                // فتح خريطة لعرض المسار
                final Uri url = Uri.parse(
                  'https://www.google.com/maps/dir/?api=1'
                  '&origin=${trip.startLocation!.latitude},${trip.startLocation!.longitude}'
                  '&destination=${trip.destinationLocation!.latitude},${trip.destinationLocation!.longitude}'
                  '&travelmode=driving',
                );
                launchUrl(url, mode: LaunchMode.externalApplication);
              },
              icon: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                decoration: BoxDecoration(
                  color: systemColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.map_rounded,
                      color: systemColors.primary,
                      size: 28,
                    ),
                    Text(
                      'عرض المسار',
                      style: TextStyle(
                        color: systemColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              tooltip: 'عرض المسار على الخريطة',
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),

            // تفاصيل الرحلة
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildTripDetail(
                        icon: Icons.route_rounded,
                        title: 'المسافة',
                        value: '${trip.distance.toStringAsFixed(2)} كم',
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
                    onPressed: () => controller.acceptTrip(trip),
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
                    onPressed: () => controller.rejectTrip(trip),
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
  }

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
            color: color.withValues(alpha: 0.1),
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

  // Stack _buildReword() {
  //   return Stack(
  //     alignment: Alignment.center,
  //     children: [
  //       Container(
  //         height: 70, // زيادة الحجم
  //         width: 70,
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           gradient: LinearGradient(
  //             colors: [systemColors.primary,systemColors.primary.withValues(alpha: 0.65)],
  //             begin: Alignment.topRight,
  //             end: Alignment.bottomLeft,
  //           ),
  //           boxShadow: [
  //             BoxShadow(
  //               color: systemColors.primary.withValues(alpha:0.7),
  //               spreadRadius: 3,
  //               blurRadius: 5,
  //               offset: Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         child: CircularProgressIndicator.adaptive(
  //           value: 0.5,
  //           backgroundColor: Colors.white.withValues(alpha:0.3),
  //           valueColor: AlwaysStoppedAnimation<Color>(systemColors.white),
  //           strokeWidth: 6,
  //           strokeCap: StrokeCap.round,
  //         ),
  //       ),
  //       Text(
  //         "50د",
  //         style: TextStyle(
  //           fontSize: 18,
  //           fontFamily: 'Tajawal',
  //           fontWeight: FontWeight.bold,
  //           color: Colors.white,
  //           shadows: [
  //             Shadow(
  //               offset: Offset(1, 1),
  //               blurRadius: 2,
  //               color: Colors.black26,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Color getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "blocked":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
