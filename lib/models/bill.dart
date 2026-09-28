enum BillCategory { creditCard, emi, rent, subscription, utilities, other }

enum BillStatus { pending, dueSoon, paid, overdue }

class Bill {
  const Bill({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.category,
    required this.status,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final BillCategory category;
  final BillStatus status;
}
