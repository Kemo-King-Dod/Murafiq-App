import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:murafiq/admin/screens/transactions_management_page.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/models/transaction.dart';

class TransactionsDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  List<Transaction> allTransactions = [];
  List<Transaction> filteredTransactions = [];
  TransactionType selectedType = TransactionType.all;
  String searchQuery = '';

  double totalBalance = 0.0;
  double anisBalance = 0.0;

  late AnimationController animationController;
  late Animation<double> animation;

  void loadTransactions() async {
    print(1);
    final response = await sendRequestWithHandler(
      endpoint: "/admin/transactions",
      method: "GET",
    );
    print(response.toString());
    if (response != null && response['data'] != null) {
      totalBalance = response['data']['companyBalance'].toDouble();
      anisBalance = response['data']['anisBalance'].toDouble();
      final transactionsList = response['data']['transactions'] as List? ?? [];
      allTransactions.addAll(transactionsList
          .map((transactionData) => Transaction.fromJson(transactionData))
          .toList());
      applyFilters();
    }
    update();
  }

  void applyFilters() {
    filteredTransactions = allTransactions.where((transaction) {
      final matchesType = selectedType == TransactionType.all ||
          ((selectedType == TransactionType.credit && transaction.isCredit) ||
              (selectedType == TransactionType.debit && !transaction.isCredit));
      final matchesSearch = transaction.description
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();
    update();
  }

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting('ar');
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );
    animationController.forward();
    loadTransactions();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
