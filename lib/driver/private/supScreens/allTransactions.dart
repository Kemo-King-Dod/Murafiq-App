import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;
import 'package:murafiq/driver/public/controllers/driver_wallet_controller.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/transaction.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({Key? key}) : super(key: key);

  @override
  _AllTransactionsPageState createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  final DriverWalletController _walletController = Get.find();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Transaction> _filteredTransactions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar'); // Initialize Arabic locale
    _filteredTransactions = _walletController.recentTransactions;
  }

  void _filterTransactions(String query) {
    setState(() {
      _filteredTransactions = _walletController.recentTransactions
          .where((transaction) => transaction.description
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildTransactionGroupHeader(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  systemColors.primary.withValues(alpha: 0.8),
                  systemColors.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: systemColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              intl.DateFormat('MMMM dd, yyyy', 'ar').format(date),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final bool isCredit = transaction.isCredit;
    final Color baseColor = isCredit ? Color(0xFF00B894) : Color(0xFFFF7675);
    final List<Color> gradientColors = isCredit
        ? [Color(0xFF00B894), Color(0xFF00D1A3)]
        : [Color(0xFFFF7675), Color(0xFFFF9F9E)];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            splashColor: baseColor.withValues(alpha: 0.1),
            highlightColor: baseColor.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isCredit ? Icons.add_rounded : Icons.remove_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: baseColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: baseColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                intl.DateFormat('hh:mm a', 'ar')
                                    .format(transaction.date),
                                style: TextStyle(
                                  color: baseColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
                          color: baseColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: baseColor.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          isCredit ? 'إيداع'.tr : 'سحب'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3436),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF2D3436),
        title: _isSearching
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterTransactions,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'البحث في المعاملات...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    prefixIcon:
                        Icon(Icons.search_rounded, color: Colors.white70),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              )
            : Text(
                'المعاملات'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredTransactions = _walletController.recentTransactions;
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D3436),
              Color(0xFF636E72),
            ],
          ),
        ),
        child: Obx(() {
          if (_walletController.isLoading.value) {
            return Center(
              child: SpinKitWave(
                color: systemColors.primary,
                size: 30,
              ),
            );
          }

          if (_filteredTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          systemColors.primary.withValues(alpha: 0.8),
                          systemColors.primary.withValues(alpha: 1.0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: systemColors.primary.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 5,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'لا توجد معاملات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'جميع معاملاتك المالية ستظهر هنا لسهولة المتابعة والإدارة.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Group transactions by date
          final groupedTransactions = <DateTime, List<Transaction>>{};
          for (var transaction in _filteredTransactions) {
            final date = DateTime(
              transaction.date.year,
              transaction.date.month,
              transaction.date.day,
            );
            groupedTransactions.putIfAbsent(date, () => []).add(transaction);
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: groupedTransactions.length,
            itemBuilder: (context, index) {
              final date = groupedTransactions.keys.toList()[index];
              final transactions = groupedTransactions[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTransactionGroupHeader(date),
                  ...transactions
                      .map((transaction) => _buildTransactionTile(transaction)),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
