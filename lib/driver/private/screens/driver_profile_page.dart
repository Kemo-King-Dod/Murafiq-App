import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/driver/public/controllers/driver_profile_controller.dart';
import 'package:murafiq/driver/public/widgets/profile_bottom_sheets.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

class DriverProfilePage extends GetView<DriverProfileController> {
  UserType? userType;
  DriverProfilePage({Key? key, this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DriverProfileController>()) {
      Get.put(DriverProfileController(userType: userType!));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: Container(
              margin: EdgeInsets.all(7),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: systemColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                color: systemColors.white,
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: systemColors.primary),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
            expandedHeight: 200,
            floating: false,
            pinned: true,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'الملف الشخصي',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Obx(() => Stack(
                    fit: StackFit.expand,
                    children: [
                      controller.profileImageUrl.value.isNotEmpty
                          ? Image.network(
                              controller.profileImageUrl.value,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: systemColors.primary,
                              child: Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.white,
                              ),
                            ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              systemColors.white.withValues(alpha: 0.1),
                              systemColors.primary.withValues(alpha: 0.2),
                              systemColors.primary.withValues(alpha: 0.1),
                              systemColors.white.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(12),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileSummaryCard(),
                SizedBox(height: 16),
                _buildProfileActionButtons(),
                SizedBox(height: 16),
                _buildProfileStatistics(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            systemColors.primary.withValues(alpha: 0.7),
            systemColors.primary.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: systemColors.primary.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: systemColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.driverName.value,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Text(
                            userType == UserType.driver ? 'سائق' : 'راكب',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildDetailRow(
                  title: "رقم الهاتف",
                  icon: HeroIcons.device_phone_mobile,
                  text: controller.phoneNumber.value,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                ),
                SizedBox(height: 10),
                userType == UserType.driver
                    ? _buildDetailRow(
                        title: "نوع السيارة",
                        icon: Icons.car_rental,
                        text: controller.vehicleType.value,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      )
                    : SizedBox(),
                _buildDetailRow(
                  icon: Iconsax.calendar_2_outline,
                  text: controller.createdAt.value,
                  title: "تاريخ التسجيل",
                  iconColor: Colors.white,
                  textColor: Colors.white,
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    Color? iconColor,
    Color? textColor,
    String? title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? systemColors.primary,
          size: 24,
        ),
        SizedBox(width: 15),
        title == null
            ? Container()
            : Text(
                title,
                style: systemTextStyle.smallLight,
              ),
        title == null
            ? Container()
            : SizedBox(
                width: 10,
              ),
        Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGlassButton(
          onPressed: controller.editProfile,
          icon: Icons.edit,
          label: 'تعديل الملف',
          primaryColor: systemColors.primary,
        ),
        SizedBox(height: 10),
        _buildGlassButton(
          onPressed: controller.changePassword,
          icon: Icons.lock,
          label: 'تغيير كلمة المرور',
          primaryColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildGlassButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color primaryColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.7),
            primaryColor.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStatistics() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            systemColors.dark,
            systemColors.dark.withValues(alpha: 0.8),
            systemColors.dark.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: systemColors.primary.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Obx(() => Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إحصائيات الرحلات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: systemColors.white,
                      ),
                    ),
                    Icon(
                      Icons.analytics_outlined,
                      color: systemColors.white,
                      size: 30,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: userType == UserType.driver
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.center,
                  children: [
                    _buildEnhancedStatItem(
                      color: Colors.indigo.shade900,
                      icon: BoxIcons.bx_car,
                      label: 'عدد الرحلات',
                      value: controller.totalTrips.value.toString(),
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.withValues(alpha: 0.7),
                          Colors.indigo.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                    userType == UserType.driver
                        ? _buildEnhancedStatItem(
                            color: systemColors.sucsses.withValues(alpha: 0.5),
                            icon: Icons.monetization_on,
                            label: 'إجمالي الأرباح',
                            value:
                                '${controller.totalEarnings.value.toStringAsFixed(2)} د.ل',
                            gradient: LinearGradient(
                              colors: [
                                systemColors.sucsses.withValues(alpha: 0.7),
                                systemColors.sucsses.withValues(alpha: 0.9),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildEnhancedStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              padding: EdgeInsets.all(12),
              child: Icon(
                icon,
                color: Colors.white,
                size: 40,
              ),
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
