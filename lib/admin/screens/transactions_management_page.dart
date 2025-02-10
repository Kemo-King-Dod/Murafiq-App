import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/admin/controllers/transactions_details_controller.dart';
import 'package:murafiq/admin/subScreens/admin_transactions.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/driver/private/supScreens/allTransactions.dart';
import 'package:murafiq/models/transaction.dart';
import 'package:intl/intl.dart' as intl;

class TransactionsManagementPage
    extends GetView<TransactionsDetailsController> {
  const TransactionsManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(TransactionsDetailsController());
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: systemColors.primary,
        title: Text(
          'إدارة المعاملات',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: systemColors.white),
        ),
        centerTitle: true,
        elevation: 0,
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: GetBuilder<TransactionsDetailsController>(
          builder: (controller) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildCompanyBalanceCard(controller),
                SizedBox(height: 16),
                _buildAnisBalanceCard(controller),
                SizedBox(height: 16),
                _buildFilterSection(controller),
                SizedBox(height: 16),
                controller.filteredTransactions.isEmpty
                    ? Container(
                        height: 150,
                        width: 150,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: systemColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SpinKitWave(
                          color: systemColors.white,
                          size: 50.0,
                        ),
                      )
                    : _buildTransactionsList(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyBalanceCard(TransactionsDetailsController controller) {
    return FadeTransition(
      opacity: controller.animation,
      child: ScaleTransition(
        scale: controller.animation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                systemColors.primary.withValues(alpha: 0.8),
                systemColors.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: systemColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'الرصيد الإجمالي للشركة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Text(
                controller.totalBalance.toString() + "د.ل",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnisBalanceCard(TransactionsDetailsController controller) {
    return FadeTransition(
      opacity: controller.animation,
      child: ScaleTransition(
        scale: controller.animation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.withValues(alpha: 0.8),
                Colors.orange,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: systemColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'كروت انيس المعبئة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Text(
                controller.anisBalance.toString() + "د.ل",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(TransactionsDetailsController controller) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
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
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث بالوصف',
                prefixIcon: Icon(
                  Icons.search,
                  color: systemColors.primary.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                hintStyle: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.7),
                ),
              ),
              onChanged: (value) {
                controller.searchQuery = value;
                controller.applyFilters();
                controller.update();
              },
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
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
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TransactionType>(
                value: controller.selectedType,
                isExpanded: true,
                dropdownColor: Colors.white,
                style: TextStyle(
                  color: systemColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                items: TransactionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      _getTransactionTypeLabel(type),
                    ),
                  );
                }).toList(),
                onChanged: (type) {
                  controller.selectedType = type ?? TransactionType.all;
                  controller.applyFilters();
                  controller.update();
                },
                icon: Icon(
                  Icons.filter_list,
                  color: systemColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.all:
        return 'كل المعاملات';
      case TransactionType.credit:
        return 'إيداع';
      case TransactionType.debit:
        return 'سحب';
      default:
        return 'غير معروف';
    }
  }

  Widget _buildTransactionsList(TransactionsDetailsController controller) {
    return Expanded(
      child: controller.filteredTransactions.isEmpty
          ? _buildEmptyStateWidget()
          : Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.9),
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => AdminTransactions());
                    },
                    child: Text(
                      "عرض الكل",
                      style: systemTextStyle.mediumLight,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blueGrey.shade700.withValues(alpha: 0.9),
                        Colors.blueGrey.shade800.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: ListView.separated(
                    itemCount: controller.filteredTransactions.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.withValues(alpha: 0.1),
                      indent: 70,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final transaction =
                          controller.filteredTransactions[index];
                      return FadeTransition(
                        opacity: controller.animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(controller.animationController),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  spreadRadius: 1,
                                  blurRadius: 12,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  _showTransactionDetailsBottomSheet(
                                      Get.context!, transaction);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: transaction.isCredit
                                              ? Colors.greenAccent.shade400
                                                  .withValues(alpha: 0.2)
                                              : Colors.redAccent.shade400
                                                  .withValues(alpha: 0.2),
                                        ),
                                        padding: EdgeInsets.all(20),
                                        child: Icon(
                                          transaction.isCredit
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          color: transaction.isCredit
                                              ? Colors.greenAccent.shade400
                                              : Colors.redAccent.shade400,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          spacing: 4,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              transaction.description,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              intl.DateFormat(
                                                      'dd/MM/yyyy HH:mm')
                                                  .format(transaction.date),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${transaction.amount.toStringAsFixed(2)} د.ل',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: transaction.isCredit
                                                  ? Colors.greenAccent.shade400
                                                  : Colors.redAccent.shade400,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            transaction.isCredit
                                                ? 'إيداع'
                                                : 'سحب',
                                            style: TextStyle(
                                              color: transaction.isCredit
                                                  ? Colors.greenAccent.shade400
                                                  : Colors.redAccent.shade400,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showTransactionDetailsBottomSheet(
      BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: transaction.isCredit
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      transaction.isCredit
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: transaction.isCredit ? Colors.green : Colors.red,
                      size: 40,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    transaction.isCredit ? 'إيداع' : 'سحب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: transaction.isCredit ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildDetailRow('الوصف', transaction.description),
                _buildDetailRow(
                    'المبلغ', '${transaction.amount.toStringAsFixed(2)} ر.س'),
                _buildDetailRow(
                    'التاريخ',
                    intl.DateFormat('dd/MM/yyyy HH:mm')
                        .format(transaction.date)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          SizedBox(height: 20),
          Text(
            'لا توجد معاملات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'لم يتم العثور على معاملات مطابقة للبحث',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum TransactionType {
  all,
  credit,
  debit,
}
