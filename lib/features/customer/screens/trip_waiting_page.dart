import 'dart:ffi' as ffi;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/models/trip.dart';
import '../../../core/utils/systemVarible.dart';
import '../../../core/utils/text_styles.dart';
import 'package:lottie/lottie.dart';
import '../controllers/trip_waiting_controller.dart';

class TripWaitingPage extends StatefulWidget {
  final Trip trip;

  const TripWaitingPage({
    Key? key,
    required this.trip,
  }) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // زر العودة مع عنوان الصفحة
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.black87),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'متابعة الرحلة',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(() {
                  final trip = controller.trip.value;
                  final driver = controller.driver.value;
                  if (trip == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // بطاقة معلومات الرحلة
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildTripInfoRow(
                                  'نوع السائق:',
                                  trip.driverType == DriverType.male
                                      ? 'سائق'
                                      : 'سائقة',
                                ),
                                const SizedBox(height: 10),
                                _buildTripInfoRow(
                                  'المسافة:',
                                  '${trip.distance.toStringAsFixed(2)} كم',
                                ),
                                const SizedBox(height: 10),
                                _buildTripInfoRow(
                                  'التكلفة:',
                                  '${trip.price.toStringAsFixed(2)} دينار',
                                  color: systemColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // حالة الرحلة
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(controller.currentStatus.value),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _getStatusIcon(controller.currentStatus.value),
                              const SizedBox(width: 10),
                              Text(
                                _getStatusMessage(
                                    controller.currentStatus.value),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // معلومات السائق
                        if (driver != null) _buildDriverDetailsCard(driver),

                        const Spacer(),

                        // زر إلغاء الرحلة
                        if (controller.currentStatus.value ==
                                TripStatus.searching ||
                            controller.currentStatus.value ==
                                TripStatus.driverFound)
                          _buildCancelTripButton(),
                      ],
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverDetailsCard(tripDriver driver) {
    if (driver.name != null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
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
                        const SizedBox(height: 5),
                        Text(
                          driver.phone.toString(),
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          driver.carNumber.toString(),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildCancelTripButton() {
    return ElevatedButton(
      onPressed: controller.cancelTrip,
      style: ElevatedButton.styleFrom(
        backgroundColor: systemColors.error,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Text(
        'إلغاء الرحلة',
        style: AppTextStyles.buttonLarge.copyWith(
          color: Colors.white,
        ),
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
        return 'جاري البحث عن سائق...';
      case TripStatus.driverFound:
        return 'في انتظار قبول السائق';
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
