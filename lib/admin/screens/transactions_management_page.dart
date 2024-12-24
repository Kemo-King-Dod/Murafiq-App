import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/transaction.dart';
import 'package:intl/intl.dart' as intl;

class TransactionsManagementPage extends StatefulWidget {
  const TransactionsManagementPage({Key? key}) : super(key: key);

  @override
  _TransactionsManagementPageState createState() =>
      _TransactionsManagementPageState();
}

class _TransactionsManagementPageState extends State<TransactionsManagementPage>
    with SingleTickerProviderStateMixin {
  List<Transaction> allTransactions = [];
  List<Transaction> filteredTransactions = [];
  TransactionType _selectedType = TransactionType.all;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _animation;
  double totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadTransactions() async {
    print(1);
    final response = await sendRequestWithHandler(
      endpoint: "/admin/transactions",
      method: "GET",
    );
    if (response != null && response['data'] != null) {
      totalBalance = response['data']['companyBalance']["balance"].toDouble();
      final transactionsList = response['data']['transactions'] as List? ?? [];
      allTransactions.addAll(transactionsList
          .map((transactionData) => Transaction.fromJson(transactionData))
          .toList());
    }
    setState(() {
      // allTransactions = [
      //   Transaction(
      //     description: 'سحب من محفظة السائق',
      //     amount: 500.0,
      //     isCredit: false,
      //     date: DateTime.now(),
      //   ),
      //   Transaction(
      //     description: 'دفعة من العميل',
      //     amount: 250.0,
      //     isCredit: true,
      //     date: DateTime.now().subtract(Duration(days: 2)),
      //   ),
      // ];

      _applyFilters();
    });
  }

  void _applyFilters() {
    filteredTransactions = allTransactions.where((transaction) {
      final matchesType = _selectedType == TransactionType.all ||
          ((_selectedType == TransactionType.credit && transaction.isCredit) ||
              (_selectedType == TransactionType.debit &&
                  !transaction.isCredit));
      final matchesSearch = transaction.description
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();
  }

  Widget _buildCompanyBalanceCard() {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                systemColors.primary.withOpacity(0.8),
                systemColors.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: systemColors.primary.withOpacity(0.4),
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
                totalBalance.toString() + "د.ل",
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

  Widget _buildFilterSection() {
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
                  color: Colors.grey.withOpacity(0.1),
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
                  color: systemColors.primary.withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.7),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
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
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TransactionType>(
                value: _selectedType,
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
                  setState(() {
                    _selectedType = type ?? TransactionType.all;
                    _applyFilters();
                  });
                },
                icon: Icon(
                  Icons.filter_list,
                  color: systemColors.primary.withOpacity(0.7),
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

  Widget _buildTransactionsList() {
    return Expanded(
      child: filteredTransactions.isEmpty
          ? _buildEmptyStateWidget()
          : Container(
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
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: ListView.separated(
                itemCount: filteredTransactions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.withOpacity(0.1),
                  indent: 70,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final transaction = filteredTransactions[index];
                  return FadeTransition(
                    opacity: _animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(_animationController),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
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
                              _showTransactionDetailsBottomSheet(transaction);
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
                                          intl.DateFormat('dd/MM/yyyy HH:mm')
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
                                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                        transaction.isCredit ? 'إيداع' : 'سحب',
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
    );
  }

  void _showTransactionDetailsBottomSheet(Transaction transaction) {
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
                color: Colors.grey.withOpacity(0.2),
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
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
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
            color: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 20),
          Text(
            'لا توجد معاملات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'لم يتم العثور على معاملات مطابقة للبحث',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCompanyBalanceCard(),
              SizedBox(height: 16),
              _buildFilterSection(),
              SizedBox(height: 16),
              filteredTransactions.isEmpty
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
                  : _buildTransactionsList(),
            ],
          ),
        ),
      ),
    );
  }
}

enum TransactionType {
  all,
  credit,
  debit,
}
