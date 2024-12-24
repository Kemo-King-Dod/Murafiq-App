import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/driver/public/controllers/driver_profile_controller.dart';
import 'package:murafiq/driver/public/controllers/driver_trip_history_controller.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/trip.dart';

class DriverTripHistoryPage extends GetView<DriverTripHistoryController> {
  final UserType userType;
  const DriverTripHistoryPage({
    Key? key,
    required this.userType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DriverTripHistoryController>()) {
      Get.put(DriverTripHistoryController());
    }
    return Scaffold(
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
        backgroundColor: systemColors.primary,
        title: Text(
          'سجل الرحلات',
          style: systemTextStyle.mediumLight,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.trips.isEmpty) {
          return Center(
            child: Text(
              'لا توجد رحلات سابقة',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.trips.length,
          itemBuilder: (context, index) {
            final trip = controller.trips[index];
            return _buildTripCard(trip);
          },
        );
      }),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final Color statusColor = _getTripStatusColor(trip.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.9),
            statusColor.withValues(alpha: 0.8),
            statusColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showTripDetailsBottomSheet(trip),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip Route and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: trip.startCity != trip.destinationCity
                          ? Text(
                              'رحلة من ${trip.startCity.arabicName} إلى ${trip.destinationCity.arabicName}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: systemColors.primary,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              "رحلة محلية",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: systemColors.white,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withValues(alpha: 0.9),
                            statusColor.withValues(alpha: 0.8),
                            statusColor.withValues(alpha: 0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _getTripStatusText(trip.status),
                        style: TextStyle(
                          color: systemColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Customer and Trip Details
                trip.driver != null ? _buildPersonCard(trip) : Container(),
                SizedBox(height: 8),
                _buildTripInfoSection(trip),
                SizedBox(height: 16),
                // Trip Additional Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTripDetailChip(
                      icon: Icons.calendar_today,
                      label: _formatDate(trip.createdAt),
                    ),
                    _buildTripDetailChip(
                      icon: Icons.monetization_on,
                      label: '${trip.price.toStringAsFixed(2)} د.ل',
                      color: systemColors.sucsses,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildPersonCard(Trip trip) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: systemColors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: systemColors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: systemColors.primary.withValues(alpha: 0.1),
              child: Icon(
                size: 30,
                Icons.person,
                color: systemColors.white,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userType == UserType.driver
                    ? Text(
                        "الراكب",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                            color: systemColors.white),
                      )
                    : Text(
                        "السائق",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                            color: systemColors.white),
                      ),
                Text(
                  userType == UserType.driver
                      ? trip.customer!.name
                      : trip.driver!.name,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: systemColors.white),
                ),
                userType == UserType.driver
                    ? Text(
                        trip.customer!.phone,
                        style: TextStyle(
                          color: systemColors.white,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      )
                    : Text(
                        trip.driver!.phone,
                        style: TextStyle(
                          color: systemColors.white,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoSection(Trip trip) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            systemColors.white.withValues(alpha: 0.9),
            systemColors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: systemColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: systemColors.primary.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            Icons.access_time,
            'المدة \n ${trip.estimatedTime} دقيقة',
            iconColor: Colors.deepOrange.shade500,
            textColor: Colors.deepOrange.shade800,
          ),
          Container(
            height: 40,
            width: 1,
            color: systemColors.primary.withValues(alpha: 0.15),
          ),
          _buildInfoItem(
            Icons.straighten,
            'المسافة \n ${trip.distance.toStringAsFixed(2)} كم',
            iconColor: Colors.deepPurple.shade500,
            textColor: Colors.deepPurple.shade800,
          ),
          Container(
            height: 40,
            width: 1,
            color: systemColors.primary.withValues(alpha: 0.15),
          ),
          userType == UserType.driver
              ? _buildInfoItem(
                  Icons.monetization_on_outlined,
                  'مستحقات \n ${trip.companyFee} د.ل',
                  iconColor: Colors.green.shade600,
                  textColor: Colors.green.shade900,
                )
              : _buildInfoItem(Clarity.organization_line,
                  "المدينة \n ${trip.startCity.arabicName}",
                  iconColor: Colors.blue.shade600,
                  textColor: Colors.blue.shade900),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String text, {
    Color? iconColor,
    Color? textColor,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                iconColor!.withValues(alpha: 0.9),
                iconColor.withValues(alpha: 0.7),
                iconColor.withValues(alpha: 0.8),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.4),
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
              BoxShadow(
                color: iconColor.withValues(alpha: 0.2),
                spreadRadius: -1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(12),
          child: Icon(
            icon,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: textColor ?? Colors.grey.shade700,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black.withValues(alpha: 0.1),
                offset: Offset(0.5, 0.5),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTripDetailChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (color ?? systemColors.primary).withValues(alpha: 0.8),
            (color ?? systemColors.primary).withValues(alpha: 0.7),
            (color ?? systemColors.primary).withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: (color ?? systemColors.primary).withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showTripDetailsBottomSheet(Trip trip) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تفاصيل الرحلة',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: systemColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildDetailRow('رمز الرحلة', trip.TripCode!),
              _buildDetailRow('المسافة', '${trip.distance} كم'),
              _buildDetailRow('الوقت المقدر', '${trip.estimatedTime} دقيقة'),
              _buildDetailRow(
                  'طريقة الدفع', _getPaymentMethodText(trip.paymentMethod)),
              _buildDetailRow('رسوم الشركة', '${trip.companyFee} د.ل'),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: systemColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'نقدي';
      case PaymentMethod.wallet:
        return 'محفظة';
      default:
        return 'غير محدد';
    }
  }

  IconData _getTripStatusIcon(TripStatus? status) {
    switch (status) {
      case TripStatus.completed:
        return Icons.check_circle;
      case TripStatus.cancelled:
        return Icons.cancel;
      case TripStatus.arrived:
        return Icons.directions_car;
      default:
        return Icons.trip_origin;
    }
  }

  Color _getTripStatusColor(TripStatus? status) {
    switch (status) {
      case TripStatus.completed:
        return Colors.teal;
      case TripStatus.cancelled:
        return Colors.red;
      case TripStatus.arrived:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getTripStatusText(TripStatus? status) {
    switch (status) {
      case TripStatus.completed:
        return 'مكتملة';
      case TripStatus.cancelled:
        return 'ملغاة';
      case TripStatus.arrived:
        return 'قيد التنفيذ';
      default:
        return 'غير معروف';
    }
  }
}
