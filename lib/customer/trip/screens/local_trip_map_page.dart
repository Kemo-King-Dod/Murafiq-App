import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/core/utils/text_styles.dart';
import 'package:murafiq/customer/trip/controllers/local_trip_map_controller.dart';
import 'package:murafiq/customer/trip/screens/trip_waiting_page.dart';
import 'package:murafiq/models/city.dart';
import 'package:murafiq/models/trip.dart';

class LocalTripMapPage extends GetView<LocalTripMapController> {
  final LatLng initialPosition;
  final CityAndBoundary city;
  final CityAndBoundary cityTo;
  final Trip? lasttrip;

  const LocalTripMapPage({
    Key? key,
    required this.initialPosition,
    required this.city,
    required this.cityTo,
    this.lasttrip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var activeGradient = LinearGradient(
      colors: [
        systemColors.primary,
        systemColors.primary,
        systemColors.primary.withValues(alpha: 0.75)
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    var disabeldGradient = LinearGradient(
      colors: [
        Colors.grey,
        Colors.grey,
        Colors.grey.withValues(alpha: 0.75),
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.bottomCenter,
    );

    var activeShadow = [
      BoxShadow(
        color: systemColors.primary.withValues(alpha: 0.3),
        spreadRadius: 1,
        blurRadius: 5,
        offset: const Offset(2, 5),
      ),
    ];

    var disabeldShadow = [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.3),
        spreadRadius: 1,
        blurRadius: 5,
        offset: const Offset(2, 5),
      ),
    ];

    // Check if controller exists, if not create it
    if (!Get.isRegistered<LocalTripMapController>()) {
      Get.put(LocalTripMapController(
        initialPosition: initialPosition,
        city: city,
        cityTo: cityTo,
        lasttrip: lasttrip, // سيكون null إذا لم يتم تمريره
      ));
    }
    Trip? trip;

    return Scaffold(
      body: Stack(
        children: [
          // Google Map Widget
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height *
                        controller.sheetPosition.value),
                child: SizedBox(
                  width: Get.width,
                  height: Get.height,
                  child: Obx(
                    () => GoogleMap(
                      zoomControlsEnabled: false,
                      rotateGesturesEnabled: false,
                      layoutDirection: TextDirection.rtl,
                      compassEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: controller.cityTo == controller.city
                            ? controller.currentPosition
                            : controller.calculateCenterPoint(
                                controller.currentPosition,
                                controller.selectedDestination ?? LatLng(0, 0)),
                        zoom: controller.cityTo == controller.city ? 15 : 8,
                      ),
                      mapType: controller.isSatelliteView
                          ? MapType.satellite
                          : MapType.normal,
                      markers: controller.markers,
                      polylines: controller.polylines,
                      onTap: controller.cityTo == controller.city &&
                              !controller.isThereTrip.value
                          ? controller.onMapTap
                          : null,
                      myLocationButtonEnabled: false,
                      polygons: controller.Boundries,
                      onMapCreated: (mapController) {
                        controller.mapController = mapController;

                        // If inter-city trip, fit markers in view
                        if (controller.cityTo != controller.city) {
                          mapController.animateCamera(
                            CameraUpdate.newLatLngBounds(
                              controller.calculateLatLngBounds(
                                  controller.currentPosition,
                                  controller.selectedDestination ??
                                      LatLng(0, 0)),
                              100,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              )),

          // Map Type Toggle Button
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Obx(() => IconButton(
                    icon: Icon(
                      controller.isSatelliteView
                          ? Icons.map_outlined
                          : Icons.satellite_alt_outlined,
                      color: systemColors.primary,
                    ),
                    onPressed: controller.toggleMapType,
                  )),
            ),
          ),

          // Current Location Button
          Positioned(
            bottom: 180,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.my_location,
                  color: systemColors.primary,
                ),
                onPressed: () {
                  controller.mapController?.animateCamera(
                    CameraUpdate.newLatLng(controller.currentPosition),
                  );
                },
              ),
            ),
          ),

          // Trip Details Sheet
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              // Debounce the position update slightly for smoother animation
              Future.delayed(const Duration(milliseconds: 16), () {
                controller.updateSheetPosition(notification.extent);
              });
              return true;
            },
            child: Obx(
              () => controller.isThereTrip.value
                  ? DraggableScrollableSheet(
                      initialChildSize: 0.4,
                      minChildSize: 0.2,
                      maxChildSize: 0.9,
                      builder: (context, scrollController) {
                        return TripWaitingPage(
                          trip: controller.waittingTrip!,
                          scrollcontroller: scrollController,
                        );
                      },
                    )
                  : DraggableScrollableSheet(
                      initialChildSize: 0.4,
                      minChildSize: 0.2,
                      maxChildSize: 0.9,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 15,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: ListView(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: [
                              // Drag Indicator
                              Center(
                                child: Container(
                                  width: 50,
                                  height: 6,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Obx(() => Column(
                                      children: [
                                        // Trip Details Title
                                        Text(
                                          'تفاصيل الرحلة'.tr,
                                          style: AppTextStyles.h3.copyWith(
                                            color: systemColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 15),

                                        // Trip Distance
                                        _buildTripDetailRow(
                                          'المسافة:'.tr,
                                          '${controller.tripDistance.toStringAsFixed(2)}' +
                                              'كم'.tr,
                                          Icons.route_rounded,
                                        ),

                                        // Short Distance Warning
                                        if (controller.selectedDestination !=
                                                null &&
                                            controller.tripDistance < 0.5)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Text(
                                              'المسافة قصيرة جدًا. يجب أن تكون المسافة أكثر من 500 متر'
                                                  .tr,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: systemColors.error,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),

                                        // Estimated Cost
                                        _buildTripDetailRow(
                                          'التكلفة التقديرية:'.tr,
                                          '${controller.tripPrice.toStringAsFixed(2)}' +
                                              'دينار'.tr,
                                          Icons.attach_money_rounded,
                                          color: systemColors.primary,
                                        ),

                                        // Driver Type Selection
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'نوع السائق:'.tr,
                                                style: AppTextStyles.bodyMedium,
                                              ),
                                              Row(
                                                children: [
                                                  _buildDriverTypeButton(
                                                    DriverType.male,
                                                    'ذكر'.tr,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  controller.userGender ==
                                                          'male'
                                                      ? Container()
                                                      : _buildDriverTypeButton(
                                                          DriverType.female,
                                                          'انثى'.tr,
                                                        ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Payment Method Selection
                                        _buildPaymentMethodSection(),

                                        // Confirm Trip Button
                                        Obx(() => Container(
                                              height: 50,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                gradient:
                                                    controller.isReady.value
                                                        ? activeGradient
                                                        : disabeldGradient,
                                                boxShadow:
                                                    controller.isReady.value
                                                        ? activeShadow
                                                        : disabeldShadow,
                                              ),
                                              child: MaterialButton(
                                                onPressed:
                                                    controller.isReady.value
                                                        ? controller.confirmTrip
                                                        : null,

                                                // style: ElevatedButton.styleFrom(
                                                //   backgroundColor: controller
                                                //           .isReady.value
                                                //       ? systemColors.primary
                                                //       : systemColors.primary
                                                //           .withValues(alpha: 0.5),
                                                //   minimumSize: const Size(
                                                //       double.infinity, 50),
                                                //   shape: RoundedRectangleBorder(
                                                //     borderRadius:
                                                //         BorderRadius.circular(15),
                                                //   ),
                                                // ),
                                                child: Text(
                                                  controller.isReady.value
                                                      ? 'تأكيد الرحلة'.tr
                                                      : 'جاري حساب السعر...'.tr,
                                                  style: AppTextStyles
                                                      .buttonLarge
                                                      .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          )
        ],
      ),
    );
  }

  // Build Trip Detail Row Widget
  Widget _buildTripDetailRow(String label, String value, IconData icon,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (color ?? Colors.grey).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color ?? Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Build Driver Type Button Widget
  Widget _buildDriverTypeButton(DriverType driverType, String label) {
    var activeGradient = LinearGradient(
      colors: [
        systemColors.primary,
        systemColors.primary,
        systemColors.primary.withValues(alpha: 0.8),
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    var disabeldGradient = LinearGradient(
      colors: [
        Colors.grey,
        Colors.grey,
        Colors.grey.withValues(alpha: 0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Obx(() => GestureDetector(
          onTap: () => controller.setDriverType(driverType),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: controller.selectedDriverType == driverType
                  ? activeGradient
                  : disabeldGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: controller.selectedDriverType == driverType
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ));
  }

  // Build Payment Method Section
  Widget _buildPaymentMethodSection() {
    var activeGradient = LinearGradient(
      colors: [
        systemColors.primary,
        systemColors.primary,
        systemColors.primary.withValues(alpha: 0.75)
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    var disabeldGradient = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.transparent,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    var activeShadow = [
      BoxShadow(
        color: systemColors.primary.withValues(alpha: 0.3),
        spreadRadius: 1,
        blurRadius: 5,
        offset: const Offset(2, 5),
      ),
    ];
    var disabeldShadow = [
      BoxShadow(
        color: Colors.transparent,
        spreadRadius: 0,
        blurRadius: 0,
        offset: const Offset(0, 0),
      ),
    ];

    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                systemColors.primaryGoust.withValues(alpha: 0.1),
                systemColors.primaryGoust.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: systemColors.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
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
                      color: systemColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.payment_rounded,
                      color: systemColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'طريقة الدفع'.tr,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: systemColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: PaymentMethod.values.map((method) {
                  IconData icon;
                  String label;

                  switch (method) {
                    case PaymentMethod.cash:
                      icon = Icons.money_rounded;
                      label = 'نقداً'.tr;
                      break;
                    case PaymentMethod.wallet:
                      icon = Icons.account_balance_wallet_rounded;
                      label = 'المحفظة'.tr;
                      break;
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.setPaymentMethod(method),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: controller.selectedPaymentMethod == method
                              ? activeGradient
                              : disabeldGradient,
                          boxShadow: controller.selectedPaymentMethod == method
                              ? activeShadow
                              : disabeldShadow,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: controller.selectedPaymentMethod == method
                                ? systemColors.primary
                                : Colors.grey.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              color: controller.selectedPaymentMethod == method
                                  ? systemColors.white
                                  : Colors.grey,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color:
                                    controller.selectedPaymentMethod == method
                                        ? systemColors.white
                                        : Colors.black87,
                                fontWeight:
                                    controller.selectedPaymentMethod == method
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ));
  }
}
