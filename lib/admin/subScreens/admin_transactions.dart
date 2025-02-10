import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';
import 'package:murafiq/admin/controllers/transactions_details_controller.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/transaction.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'dart:ui';

class AdminTransactions extends GetView<TransactionsDetailsController> {
  const AdminTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'سجل المعاملات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 28,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: IconButton(
                icon:
                    Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 78, 76, 104), // Vibrant purple
              Color.fromARGB(255, 41, 41, 51), // Electric blue
              Color.fromARGB(255, 33, 38, 42), // Bright blue
            ],
          ),
        ),
        child: GetBuilder<TransactionsDetailsController>(
          builder: (controller) {
            if (controller.filteredTransactions.isEmpty) {
              return _buildEmptyState();
            }

            final groupedTransactions =
                _groupTransactionsByDate(controller.filteredTransactions);

            return Container(
              child: ListView.builder(
                padding:
                    EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
                itemCount: groupedTransactions.length,
                cacheExtent: 1000,
                itemBuilder: (context, index) {
                  final date = groupedTransactions.keys.elementAt(index);
                  final transactions = groupedTransactions[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 16),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _formatDateHeader(date),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, idx) {
                          final transaction = transactions[idx];
                          final isFirst = idx == 0;
                          final isLast = idx == transactions.length - 1;

                          return TimelineTile(
                            alignment: TimelineAlign.manual,
                            lineXY: 0.2,
                            isFirst: isFirst,
                            isLast: isLast,
                            indicatorStyle: IndicatorStyle(
                              width: 30,
                              height: 30,
                              indicator: _buildIndicator(transaction),
                              drawGap: true,
                            ),
                            beforeLineStyle: LineStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              thickness: 3,
                            ),
                            endChild: _buildTransactionCard(transaction),
                            startChild: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    intl.DateFormat('HH:mm')
                                        .format(transaction.date),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'د.ل',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'لا توجد معاملات',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'ستظهر المعاملات هنا عند إجرائها',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(Transaction transaction) {
    final isCredit = transaction.isCredit;
    final gradientColors = isCredit
        ? [Color(0xFF00E676), Color(0xFF00C853)]
        : [Color(0xFFFF5252), Color(0xFFD50000)];

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[1].withValues(alpha: 0.5),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          transaction.isCredit ? Icons.add : Icons.remove,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isCredit = transaction.isCredit;
    final gradientColors = isCredit
        ? [
            Color(0xFF00E676).withValues(alpha: 0.2),
            Color(0xFF00C853).withValues(alpha: 0.2)
          ]
        : [
            Color(0xFFFF5252).withValues(alpha: 0.2),
            Color(0xFFD50000).withValues(alpha: 0.2)
          ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showTransactionDetails(transaction),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          transaction.description,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradientColors,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          transaction.isCredit ? 'إيداع' : 'سحب',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${transaction.amount.toStringAsFixed(2)} د.ل',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    final isCredit = transaction.isCredit;
    final gradientColors = isCredit
        ? [Color(0xFF00E676), Color(0xFF00C853)]
        : [Color(0xFFFF5252), Color(0xFFD50000)];

    Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[1].withValues(alpha: 0.5),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  transaction.isCredit ? Icons.add : Icons.remove,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '${transaction.amount.toStringAsFixed(2)} د.ل',
                style: TextStyle(
                  color: gradientColors[1],
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                transaction.isCredit ? 'إيداع' : 'سحب',
                style: TextStyle(
                  color: gradientColors[1],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              _buildDetailRow('الوصف', transaction.description),
              _buildDetailRow(
                'التاريخ والوقت',
                intl.DateFormat('dd MMMM yyyy, HH:mm', 'ar')
                    .format(transaction.date),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF2D3142),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Color(0xFF2D3142),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<Transaction>> _groupTransactionsByDate(
      List<Transaction> transactions) {
    final grouped = <DateTime, List<Transaction>>{};

    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }

    grouped.forEach((key, value) {
      value.sort((a, b) => b.date.compareTo(a.date));
    });

    return Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return 'اليوم';
    } else if (dateOnly == yesterday) {
      return 'أمس';
    } else {
      return intl.DateFormat('dd MMMM yyyy', 'ar').format(date);
    }
  }
}
