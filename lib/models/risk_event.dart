enum RiskSeverity { low, medium, high, critical }

class RiskEvent {
  const RiskEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.amount,
    required this.date,
    required this.actionLabel,
  });

  final String id;
  final String title;
  final String description;
  final RiskSeverity severity;
  final double amount;
  final DateTime date;
  final String actionLabel;
}
