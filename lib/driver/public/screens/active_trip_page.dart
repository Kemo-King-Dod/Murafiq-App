import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/services/trip_service.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/main.dart';
import 'package:murafiq/models/trip.dart';
import 'package:murafiq/driver/public/controllers/active_trip_controller.dart';
import 'package:murafiq/driver/public/screens/driver_home_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveTripPage extends GetView<ActiveTripController> {
  final Trip trip;

  const ActiveTripPage({Key? key, required this.trip}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(ActiveTripController(trip: trip.obs));
    final RxBool isCodeVerified = trip.status == TripStatus.arrived ? true.obs : false.obs;
    final codeController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          // خريطة جوجل
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: trip.startLocation!,
                zoom: 18,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              zoomControlsEnabled: false,
              markers: {
                if (controller.carIcon != null)
                  Marker(
                    markerId: const MarkerId('start'),
                    position: trip.startLocation!,
                    icon: controller.carIcon.value,
                  ),
                if (controller.personIcon != null)
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: trip.destinationLocation!,
                    icon: controller.personIcon.value,
                  ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('trip_route'),
                  points: [
                    trip.startLocation!,
                    trip.destinationLocation!,
                  ],
                  color: systemColors.sucsses,
                  width: 5,
                  patterns: [PatternItem.dash(20), PatternItem.gap(10)],
                ),
              },
              onMapCreated: (controller) {
                controller.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest: LatLng(
                        trip.startLocation!.latitude <
                                trip.destinationLocation!.latitude
                            ? trip.startLocation!.latitude
                            : trip.destinationLocation!.latitude,
                        trip.startLocation!.longitude <
                                trip.destinationLocation!.longitude
                            ? trip.startLocation!.longitude
                            : trip.destinationLocation!.longitude,
                      ),
                      northeast: LatLng(
                        trip.startLocation!.latitude >
                                trip.destinationLocation!.latitude
                            ? trip.startLocation!.latitude
                            : trip.destinationLocation!.latitude,
                        trip.startLocation!.longitude >
                                trip.destinationLocation!.longitude
                            ? trip.startLocation!.longitude
                            : trip.destinationLocation!.longitude,
                      ),
                    ),
                    100,
                  ),
                );
              },
            ),
          ),

          // معلومات الرحلة
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // مؤشر السحب
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // معلومات العميل
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'معلومات العميل',
                            style: TextStyle(
                              color: systemColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.person,
                            'الاسم',
                            trip.customer?.name ?? 'غير متوفر',
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            Icons.phone,
                            'رقم الهاتف',
                            trip.customer?.phone ?? 'غير متوفر',
                            isPhone: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // تفاصيل الرحلة
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تفاصيل الرحلة',
                            style: TextStyle(
                              color: systemColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.location_on,
                            'نقطة الانطلاق',
                            trip.startCity,
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            Icons.flag,
                            'الوجهة',
                            trip.destinationCity,
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            Icons.route,
                            'المسافة',
                            '${trip.distance.toStringAsFixed(2)} كم',
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            Icons.attach_money,
                            'السعر',
                            '${trip.price} دينار',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // أزرار التحكم
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // فتح خريطة جوجل للملاحة
                              final url = Uri.parse(
                                'https://www.google.com/maps/dir/?api=1'
                                '&origin=${trip.startLocation!.latitude},${trip.startLocation!.longitude}'
                                '&destination=${trip.destinationLocation!.latitude},${trip.destinationLocation!.longitude}'
                                '&travelmode=driving',
                              );
                              launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('فتح الخريطة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: systemColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // الاتصال بالعميل
                              final phone = trip.customer?.phone;
                              if (phone != null) {
                                launchUrl(Uri.parse('tel:$phone'));
                              }
                            },
                            icon: const Icon(Icons.phone),
                            label: const Text('اتصال بالعميل'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // زر إنهاء الرحلة
                    Obx(
                      () => isCodeVerified.value
                          ? ElevatedButton.icon(
                              onPressed: () {
                                Get.dialog(AlertDialog(
                                  actionsAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  actions: [
                                    TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  systemColors.error)),
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text(
                                        'الغاء',
                                        style: systemTextStyle.smallLight,
                                      ),
                                    ),
                                    TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  systemColors.primary)),
                                      onPressed: () async {
                                        Get.back(); // إغلاق نافذة التأكيد
                                        final success =
                                            await TripService.completeTrip(
                                                trip.id!);
                                        if (success) {
                                          Get.offAll(() => DriverHomePage());
                                        }
                                      },
                                      child: Text(
                                        'تاكيد',
                                        style: systemTextStyle.smallLight,
                                      ),
                                    ),
                                  ],
                                  content: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'تأكيد إنهاء الرحلة',
                                            style: TextStyle(
                                              color: systemColors.primary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 24,
                                          ),
                                          Text(
                                            "هل تريد تاكيد انهاء الرحلة؟",
                                            style: TextStyle(
                                                color: systemColors.dark),
                                          ),
                                        ]),
                                  ),
                                ));
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('تم التوصيل'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            )
                          : // زقل رمز الرحلة
                          Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'رمز الرحلة',
                                    style: TextStyle(
                                      color: systemColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: codeController,
                                    decoration: InputDecoration(
                                      hintText: 'أدخل رمز الرحلة',
                                      prefixIcon: Icon(
                                          Icons.confirmation_number_outlined,
                                          color: systemColors.primary),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: systemColors.primary),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: systemColors.primary
                                                .withOpacity(0.5)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: systemColors.primary,
                                            width: 2),
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      // التحقق من رمز الرحلة
                                      final enteredCode = codeController.text;
                                      
                                      final success = await TripService
                                          .verifyTripCodeAndUpdateStatus(
                                              trip.id!, enteredCode);

                                      if (success) {
                                        isCodeVerified.value = true;
                                        // إظهار زر إنهاء الرحلة
                                        Get.dialog(
                                          AlertDialog(
                                            title: Text(
                                              'تم التحقق بنجاح',
                                              style: TextStyle(
                                                  color: systemColors.primary),
                                              textAlign: TextAlign.center,
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 50,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'الرمز صحيح، يمكنك إنهاء الرحلة الآن',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Get.back(),
                                                child: Text(
                                                  'حسناً',
                                                  style: TextStyle(
                                                      color:
                                                          systemColors.primary),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    icon:
                                        const Icon(Icons.check_circle_outline),
                                    label: const Text('تحقق من الرمز'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: systemColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value,
      {bool isPhone = false}) {
    return Row(
      children: [
        Icon(icon, color: systemColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              if (isPhone)
                InkWell(
                  onTap: () => launchUrl(Uri.parse('tel:$value')),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
