import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:murafiq/admin/controllers/customer_details_controller.dart';
import 'package:murafiq/core/constant/Constatnt.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/customer.dart';

class CustomerDetails extends StatelessWidget {
  final Customer customer;

  const CustomerDetails({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerDetailsController>(
      init: CustomerDetailsController(customer: customer),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              'تفاصيل العميل',
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
                  _buildCustomerProfileCard(controller),
                  SizedBox(height: 20),
                  _buildCustomerInfoSection(),
                  SizedBox(height: 20),
                  _buildTripHistorySection(),
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

  Widget _buildCustomerProfileCard(CustomerDetailsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              backgroundColor: systemColors.primary.withOpacity(0.1),
              backgroundImage: customer.profileImage != null
                  ? NetworkImage("${serverConstant.serverUrl}${customer.profileImage}")
                  : null,
              child: customer.profileImage == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: systemColors.primary,
                    )
                  : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    customer.phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildStatusChip(customer.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(CustomerStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case CustomerStatus.active:
        chipColor = Colors.green.shade100;
        statusText = 'نشط';
        break;
      case CustomerStatus.blocked:
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
              : Colors.red.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              'معلومات العميل',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: systemColors.primary,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow('رقم الهاتف', customer.phone),
            _buildInfoRow('الجنس', customer.gender == 'male' ? 'ذكر' : 'أنثى'),
            if (customer.rating != null)
              _buildInfoRow('التقييم', customer.rating.toString()),
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

  Widget _buildTripHistorySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              'سجل الرحلات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: systemColors.primary,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'لا توجد رحلات حتى الآن',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(CustomerDetailsController controller) {
    return Column(
      children: [
        if (customer.status == CustomerStatus.active)
          _buildActionButton(
            text: 'حظر المستخدم',
            color: Colors.red,
            icon: Icons.block,
            onPressed: () {
              controller.showConfirmationDialog(
                title: 'حظر المستخدم',
                message: 'هل أنت متأكد من حظر هذا المستخدم؟',
                onConfirm: () => controller.updateCustomerStatus(CustomerStatus.blocked),
              );
            },
          ),
        if (customer.status == CustomerStatus.blocked)
          _buildActionButton(
            text: 'فك الحظر',
            color: Colors.blue,
            icon: Icons.check_circle,
            onPressed: () {
              controller.showConfirmationDialog(
                title: 'فك حظر المستخدم',
                message: 'هل أنت متأكد من فك حظر هذا المستخدم؟',
                onConfirm: () => controller.updateCustomerStatus(CustomerStatus.active),
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