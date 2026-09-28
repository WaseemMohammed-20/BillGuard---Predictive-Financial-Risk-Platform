import '../../../../core/financial_engine/risk_level.dart';

class TimelineEvent {
  const TimelineEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.amount,
    required this.category,
    required this.projectedBalanceAfter,
    required this.riskLevel,
    required this.isBreachingBuffer,
    required this.description,
  });

  final String id;
  final String title;
  final DateTime date;
  final TimelineEventType type;
  final double amount;
  final String category;
  final double projectedBalanceAfter;
  final RiskLevel riskLevel;
  final bool isBreachingBuffer;
  final String description;
}

enum TimelineEventType { income, bill, subscription, transfer }
