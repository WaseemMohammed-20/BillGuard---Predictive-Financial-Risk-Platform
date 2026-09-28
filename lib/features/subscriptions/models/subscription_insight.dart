enum SubscriptionInsightType {
  monthlyCommitment,
  annualCommitment,
  largestSubscription,
  incomeShare,
  concentration,
  unusualCost,
  renewalPressure,
}

enum SubscriptionInsightSeverity { low, medium, high }

class SubscriptionInsight {
  const SubscriptionInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.amount,
    required this.actionLabel,
  });

  final String id;
  final String title;
  final String description;
  final SubscriptionInsightType type;
  final SubscriptionInsightSeverity severity;
  final double amount;
  final String actionLabel;
}
