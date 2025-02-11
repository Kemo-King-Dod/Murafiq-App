import 'dart:ffi' as ffi;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/customer/public/screens/customer_home_page.dart';
import 'package:murafiq/main.dart';
import 'package:murafiq/models/driver.dart';
import 'package:murafiq/models/trip.dart';
import '../../../core/utils/systemVarible.dart';
import '../../../core/utils/text_styles.dart';
import '../controllers/trip_waiting_controller.dart';

class TripWaitingPage extends StatefulWidget {
  final Trip trip;
  final ScrollController scrollcontroller;

  const TripWaitingPage(
      {Key? key, required this.trip, required this.scrollcontroller})
      : super(key: key);

  @override
  _TripWaitingPageState createState() => _TripWaitingPageState();
}

class _TripWaitingPageState extends State<TripWaitingPage> {
  final TripWaitingController controller = Get.put(TripWaitingController());
  @override
  void initState() {
    super.initState();
    controller.setTrip(widget.trip);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? resulte) {
        if (didPop) return;
        if (controller.currentStatus.value == TripStatus.searching ||
            controller.currentStatus.value == TripStatus.accepted) {
          Get.defaultDialog(
            title: 'تنبيه'.tr,
            titleStyle: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: systemColors.primary,
            ),
            middleText: "هل تريد الغاء الرحلة".tr,
            middleTextStyle: AppTextStyles.bodyMedium,
            confirm: ElevatedButton(
              onPressed: () {
                controller.socketController.socket.updateDriver(
                    data: {"func": "tripStatus", "tripId": widget.trip.id});
                Get.back();
                controller.cancelTrip();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: systemColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'حسنا'.tr,
              ),
            ),
            cancel: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: systemColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text('لا'.tr),
            ),
          );
        } else {
          Get.back();
        }
      },
      child: Container(
        color: systemColors.white,
        child: CustomScrollView(
          controller: widget.scrollcontroller,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              centerTitle: true,
              pinned: false,
              elevation: 0,
              backgroundColor: systemColors.primary,
              expandedHeight: 50,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1.5,
                stretchModes: const [
                  StretchMode.zoomBackground,
                ],
                background: Container(
                  decoration: BoxDecoration(
                      color: systemColors.primary,
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                ),
                centerTitle: true,
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      'متابعة الرحلة'.tr,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Obx(() => Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: controller
                                    .socketController.socket.isConnected.value
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            controller
                                    .socketController.socket.isConnecting.value
                                ? 'جاري الاتصال...'.tr
                                : controller.socketController.socket.isConnected
                                        .value
                                    ? 'متصل'.tr
                                    : 'غير متصل'.tr,
                            style: TextStyle(
                              color: controller
                                      .socketController.socket.isConnected.value
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              leading: Container(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  final trip = controller.trip.value;
                  final Driver? driver = controller.driver.value;
                  if (trip == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: systemColors.primary,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'جاري تحميل معلومات الرحلة...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWideScreen = constraints.maxWidth > 600;
                      final cardPadding = isWideScreen ? 25.0 : 20.0;
                      final fontSize = isWideScreen ? 20.0 : 18.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // حالة الرحلة
                          Hero(
                            tag: 'trip_status',
                            child: GestureDetector(
                              onTap: () {
                                printer.w("tripId:${trip.id}");
                                controller.socketController.socket
                                    .updateUser("tripStatus", data: {
                                  "func": "tripStatus",
                                  "tripId": trip.id
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(bottom: 25),
                                padding: EdgeInsets.symmetric(
                                  vertical: cardPadding,
                                  horizontal: cardPadding * 1.2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getStatusColor(
                                          controller.currentStatus.value),
                                      _getStatusColor(
                                              controller.currentStatus.value)
                                          .withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getStatusColor(
                                              controller.currentStatus.value)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _getStatusIcon(
                                        controller.currentStatus.value),
                                    const SizedBox(width: 15),
                                    Flexible(
                                      child: Text(
                                        _getStatusMessage(
                                                controller.currentStatus.value)
                                            .tr,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSize,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          controller.currentStatus.value == TripStatus.cancelled
                              ? InkWell(
                                  onTap: () {
                                    Get.offAll(CustomerHomePage());
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.home),
                                        SizedBox(width: 10),
                                        Text("الرجوع الى الصفحة الرئيسية".tr),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                          // بطاقة معلومات الرحلة
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.all(cardPadding),
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildTripInfoRow(
                                  Icons.person,
                                  'نوع السائق'.tr,
                                  trip.driverType == DriverType.male
                                      ? 'سائق'.tr
                                      : 'سائقة'.tr,
                                  systemColors.primary,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Divider(height: 1),
                                ),
                                _buildTripInfoRow(
                                  Icons.route,
                                  'المسافة'.tr,
                                  '${trip.distance.toStringAsFixed(2)}' +
                                      'كم'.tr,
                                  Colors.blue[700]!,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Divider(height: 1),
                                ),
                                _buildTripInfoRow(
                                  Icons.attach_money,
                                  'التكلفة'.tr,
                                  '${trip.price.toStringAsFixed(2)}' +
                                      'دينار'.tr,
                                  Colors.green[600]!,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),
                          Obx(
                            () => controller.driver.value != null
                                ? // معلومات السائق
                                _buildDriverDetailsCard(
                                    controller.driver.value!)
                                : const SizedBox(),
                          ),
                          // معلومات السائق
                          // _buildDriverDetailsCard(driver),
                          // معلومات السائق
                          // _buildDriverDetailsCard(Driver(
                          //     carNumber: "123",
                          //     name: "kamal",
                          //     gender: "male",
                          //     idNumber: "123",
                          //     phone: "123")),
                          const SizedBox(height: 25),

                          // بطاقة طريقة الدفع
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: systemColors.primary
                                      .withValues(alpha: 0.1),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: systemColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.payment_rounded,
                                        color: systemColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      'طريقة الدفع'.tr,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                trip.paymentMethod == PaymentMethod.cash
                                    ? Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.money,
                                              color: Colors.green[600],
                                              size: 28,
                                            ),
                                            const SizedBox(width: 15),
                                            Text(
                                              'الدفع نقداً'.tr,
                                              style: AppTextStyles.bodyLarge
                                                  .copyWith(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'مفعل'.tr,
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                  color: Colors.green[600],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.wallet,
                                              color: Colors.blue[600],
                                              size: 28,
                                            ),
                                            const SizedBox(width: 15),
                                            Text(
                                              'من المحفظة'.tr,
                                              style: AppTextStyles.bodyLarge
                                                  .copyWith(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'مفعل'.tr,
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                  color: Colors.blue[600],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          // زر إلغاء الرحلة
                          if (controller.currentStatus.value ==
                                  TripStatus.searching ||
                              controller.currentStatus.value ==
                                  TripStatus.driverFound)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 15),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (controller.currentStatus.value ==
                                          TripStatus.searching ||
                                      controller.currentStatus.value ==
                                          TripStatus.accepted) {
                                    Get.defaultDialog(
                                      title: 'تنبيه'.tr,
                                      titleStyle:
                                          AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: systemColors.primary,
                                      ),
                                      middleText: "هل تريد الغاء الرحلة".tr,
                                      middleTextStyle: AppTextStyles.bodyMedium,
                                      confirm: ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                          controller.cancelTrip();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: systemColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          'حسناً'.tr,
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      cancel: ElevatedButton(
                                        onPressed: () => Get.back(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: systemColors.error,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text('لا'.tr),
                                      ),
                                    );
                                  } else {
                                    Get.back();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isWideScreen ? 20 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 3,
                                  shadowColor:
                                      Colors.red.withValues(alpha: 0.5),
                                ),
                                child: Text(
                                  'إلغاء الرحلة'.tr,
                                  style: AppTextStyles.buttonLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInfoRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverDetailsCard(Driver driver) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: systemColors.primary.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Code Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  systemColors.primary.withValues(alpha: 0.9),
                  systemColors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: systemColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Text(
                    'رمز الرحلة:'.tr +
                        '${controller.trip.value!.TripCode ?? 'غير متوفر'}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'معلومات السائق'.tr,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: systemColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: systemColors.primaryGoust,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: systemColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name.toString(),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 5),
                        Text(
                          driver.phone.toString(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 5),
                        Text(
                          driver.carNumber.toString(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.searching:
        return Colors.orange;
      case TripStatus.driverFound:
        return Colors.blue;
      case TripStatus.accepted:
        return Colors.green;
      case TripStatus.arrived:
        return Colors.green.shade700;
      case TripStatus.completed:
        return Colors.green.shade900;
      case TripStatus.cancelled:
      case TripStatus.rejected:
        return systemColors.error;
    }
  }

  Widget _getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.searching:
        return const CircularProgressIndicator(color: Colors.white);
      case TripStatus.driverFound:
        return const Icon(Icons.check_circle, color: Colors.white);
      case TripStatus.accepted:
        return const Icon(Icons.directions_car, color: Colors.white);
      case TripStatus.arrived:
        return const Icon(Icons.location_on, color: Colors.white);
      case TripStatus.completed:
        return const Icon(Icons.check_circle_outline, color: Colors.white);
      case TripStatus.cancelled:
      case TripStatus.rejected:
        return const Icon(Icons.cancel, color: Colors.white);
    }
  }

  String _getStatusMessage(TripStatus status) {
    switch (status) {
      case TripStatus.searching:
        return 'جاري البحث عن سائقين';
      case TripStatus.driverFound:
        return 'في انتظار قبول السائقين';
      case TripStatus.accepted:
        return 'السائق في طريقه اليك';
      case TripStatus.arrived:
        return 'السائق وصل';
      case TripStatus.completed:
        return 'تم إكمال الرحلة';
      case TripStatus.cancelled:
        return 'تم إلغاء الرحلة';
      case TripStatus.rejected:
        return 'تم رفض الرحلة';
    }
  }
}
