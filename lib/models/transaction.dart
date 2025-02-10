class Transaction {
  final String description;
  final double amount;
  final bool isCredit;
  final DateTime date;

  Transaction({
    required this.description,
    required this.amount,
    required this.isCredit,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    
    return Transaction(
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      isCredit: json['type'] == 'credit',
      date: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }
}
