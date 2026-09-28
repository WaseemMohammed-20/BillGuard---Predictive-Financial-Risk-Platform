enum TransactionCategory {
  food,
  transport,
  entertainment,
  bills,
  shopping,
  travel,
  income,
  other,
}

enum TransactionType { debit, credit }

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });

  final String id;
  final String merchant;
  final double amount;
  final TransactionCategory category;
  final DateTime date;
  final TransactionType type;
}
