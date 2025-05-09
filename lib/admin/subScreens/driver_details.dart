import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:murafiq/admin/controllers/driver_details_controller.dart';
import 'package:murafiq/core/constant/Constatnt.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/driver.dart';

class DriverDetails extends StatelessWidget {
  final Driver driver;

  const DriverDetails({Key? key, required this.driver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(driver.licenseImage);
    return GetBuilder<DriverDetailsController>(
      init: DriverDetailsController(driver: driver),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              'تفاصيل السائق',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: systemColors.primary,
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
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDriverProfileCard(controller),
                  SizedBox(height: 20),
                  _buildDriverInfoSection(),
                  SizedBox(height: 20),
                  _buildIdentityDocumentsSection(),
                  SizedBox(height: 20),
                  _buildActionButtons(controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDriverProfileCard(DriverDetailsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: systemColors.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 50,
                color: systemColors.primary,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    driver.phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildStatusChip(driver.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(DriverStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case DriverStatus.active:
        chipColor = Colors.green.shade100;
        statusText = 'نشط';
        break;
      case DriverStatus.pending:
        chipColor = Colors.orange.shade100;
        statusText = 'معلق';
        break;
      case DriverStatus.blocked:
        chipColor = Colors.red.shade100;
        statusText = 'محظور';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor == Colors.green.shade100
              ? Colors.green.shade800
              : chipColor == Colors.orange.shade100
                  ? Colors.orange.shade800
                  : Colors.red.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDriverInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات السائق',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: systemColors.primary,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow('رقم الرخصة', driver.licenseNumber),
            _buildInfoRow('رقم السيارة', driver.carNumber),
            _buildInfoRow('الجنس', driver.gender == 'male' ? 'ذكر' : 'أنثى'),
            _buildInfoRow('رقم الهاتف', driver.phone),
            _buildInfoRow('الرصيد', driver.balance.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityDocumentsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'وثائق الهوية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: systemColors.primary,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: driver.licenseImage != null
                      ? _buildDocumentImage(driver.passPortImage!)
                      : _buildDocumentPlaceholder('صورة الهوية'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: driver.licenseImage != null
                      ? _buildDocumentImage(driver.licenseImage!)
                      : _buildDocumentPlaceholder('رخصة القيادة'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: driver.licenseImage != null
                      ? _buildDocumentImage(driver.backLicenseImage!)
                      : _buildDocumentPlaceholder('صورة الهوية'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: driver.licenseImage != null
                      ? _buildDocumentImage(driver.vehicleBookImage!)
                      : _buildDocumentPlaceholder('كتابة السيارة'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: driver.licenseImage != null
                      ? _buildDocumentImage(driver.vehicleImage!)
                      : _buildDocumentPlaceholder('صورة السيارة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPlaceholder(String title) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: Colors.grey[500],
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentImage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        Get.dialog(
          Dialog(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(Get.context!).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Get.back(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.fullscreen),
                          onPressed: () {
                            Get.back();
                            Get.to(
                              Scaffold(
                                appBar: AppBar(
                                  title: const Text('عرض الصورة'),
                                  backgroundColor: systemColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                body: InteractiveViewer(
                                  minScale: 0.5,
                                  maxScale: 4.0,
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        "${serverConstant.serverUrl}$imageUrl",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: CachedNetworkImage(
                        imageUrl: "${serverConstant.serverUrl}$imageUrl",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: CachedNetworkImage(
          imageUrl: "${serverConstant.serverUrl}$imageUrl",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildActionButtons(DriverDetailsController controller) {
    return Column(
      children: [
        if (driver.status == DriverStatus.pending)
          _buildActionButton(
            text: 'قبول الطلب',
            color: Colors.green,
            icon: Icons.check,
            onPressed: () {
              controller.showConfirmationDialog(
                title: 'قبول طلب السائق',
                message: 'هل أنت متأكد من قبول طلب هذا السائق؟',
                onConfirm: () =>
                    controller.updateDriverStatus(DriverStatus.active),
              );
            },
          ),
        if (driver.status == DriverStatus.active)
          Column(
            children: [
              _buildActionButton(
                text: 'حظر السائق',
                color: Colors.red,
                icon: Icons.block,
                onPressed: () {
                  controller.showConfirmationDialog(
                    title: 'حظر السائق',
                    message: 'هل أنت متأكد من حظر هذا السائق؟',
                    onConfirm: () =>
                        controller.updateDriverStatus(DriverStatus.blocked),
                  );
                },
              ),
              _buildActionButton(
                  text: 'سحب الرصيد',
                  color: systemColors.primary,
                  icon: Icons.money_off,
                  onPressed: () => controller.discountDriverWalletfun(
                      balance: driver.balance)),
            ],
          ),
        if (driver.status == DriverStatus.blocked)
          _buildActionButton(
            text: 'فك الحظر',
            color: Colors.blue,
            icon: Icons.check_circle,
            onPressed: () {
              controller.showConfirmationDialog(
                title: 'فك حظر السائق',
                message: 'هل أنت متأكد من فك حظر هذا السائق؟',
                onConfirm: () =>
                    controller.updateDriverStatus(DriverStatus.active),
              );
            },
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
