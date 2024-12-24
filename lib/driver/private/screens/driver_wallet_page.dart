import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/driver/private/supScreens/addBalancePage.dart';
import 'package:murafiq/driver/private/supScreens/allTransactions.dart';
import 'package:murafiq/driver/public/controllers/driver_profile_controller.dart';
import 'package:murafiq/driver/public/controllers/driver_wallet_controller.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

class DriverWalletPage extends GetView<DriverWalletController> {
  final UserType userType;
  const DriverWalletPage({Key? key, required this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DriverWalletController>()) {
      Get.put(DriverWalletController());
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
          'المحفظة',
          style: systemTextStyle.mediumLight,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBalanceCard(),
              _buildQuickActionsSection(),
              _buildTransactionsList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            systemColors.primary,
            systemColors.primary.withValues(alpha: 0.8),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الرصيد الحالي',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 30,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '${controller.balance.value.toStringAsFixed(2)} د.ل',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              'الإجراءات السريعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: systemColors.primary,
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            spacing: userType != UserType.driver ? 10.0 : 0,
            mainAxisAlignment: userType == UserType.driver
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              _buildQuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'إضافة رصيد',
                onTap: () => Get.to(() => AddbalancePage()),
                color: Colors.green,
              ),
              userType == UserType.driver
                  ? _buildQuickActionButton(
                      icon: Icons.arrow_circle_down,
                      label: 'سحب الأموال',
                      onTap: controller.withdrawFunds,
                      color: Colors.blue,
                    )
                  : Container(),
              _buildQuickActionButton(
                icon: Icons.history,
                label: 'كل المعاملات',
                onTap: () => Get.to(() => AllTransactionsPage()),
                color: Colors.blueGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Container(
      padding: EdgeInsets.only(bottom: 8),
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueGrey.shade700.withValues(alpha: 0.9),
            Colors.blueGrey.shade800.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 3,
            blurRadius: 20,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'آخر المعاملات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: controller.viewAllTransactions,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: systemColors.dark.withValues(alpha: 0.1),
                          spreadRadius: 2,
                          offset: Offset(0, -0.5),
                          blurRadius: 1,
                        ),
                        BoxShadow(
                          color: systemColors.dark.withValues(alpha: 0.7),
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'عرض الكل',
                      style: TextStyle(
                        color: systemColors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (controller.recentTransactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Colors.white38,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'لا توجد معاملات حتى الآن',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.recentTransactions.length > 5
                  ? 5
                  : controller.recentTransactions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.white10,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final transaction = controller.recentTransactions[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _buildTransactionTile(transaction),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(dynamic transaction) {
    final bool isCredit = transaction.isCredit;
    final Color tileColor = isCredit
        ? Colors.green.shade50.withValues(alpha: 0.1)
        : Colors.red.shade50.withValues(alpha: 0.1);
    final Color iconColor =
        isCredit ? Colors.greenAccent.shade400 : Colors.redAccent.shade400;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            isCredit ? Icons.arrow_upward : Icons.arrow_downward,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          transaction.description,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        subtitle: Text(
          _formatTransactionDate(transaction.date),
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            letterSpacing: 0.3,
          ),
        ),
        trailing: Text(
          '${transaction.amount} د.ل',
          style: TextStyle(
            color: isCredit ? Colors.green.shade400 : Colors.red.shade400,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  String _formatTransactionDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
