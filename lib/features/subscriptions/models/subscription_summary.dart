import '../../../models/subscription.dart';
import 'subscription_insight.dart';

class SubscriptionBreakdown {
  const SubscriptionBreakdown({
    required this.subscription,
    required this.monthlyEquivalent,
    required this.renewalAmount,
    required this.spendingSharePercent,
    required this.nextRenewal,
    required this.renewsWithinSevenDays,
  });

  final SubscriptionModel subscription;
  final double monthlyEquivalent;
  final double renewalAmount;
  final double spendingSharePercent;
  final DateTime nextRenewal;
  final bool renewsWithinSevenDays;
}

class SubscriptionSummary {
  const SubscriptionSummary({
    required this.activeCount,
    required this.monthlyTotal,
    required this.annualTotal,
    required this.largestSubscription,
    required this.largestSubscriptionAmount,
    required this.nextRenewal,
    required this.insights,
    required this.breakdown,
    required this.upcomingRenewals,
    required this.monthlyIncome,
    required this.subscriptionIncomePercentage,
    required this.concentrationPercent,
    required this.unusuallyExpensiveSubscriptions,
    required this.renewalsWithinSevenDays,
  });

  final int activeCount;
  final double monthlyTotal;
  final double annualTotal;
  final SubscriptionModel? largestSubscription;
  final double largestSubscriptionAmount;
  final DateTime? nextRenewal;
  final List<SubscriptionInsight> insights;
  final List<SubscriptionBreakdown> breakdown;
  final List<SubscriptionBreakdown> upcomingRenewals;
  final double monthlyIncome;
  final double? subscriptionIncomePercentage;
  final double concentrationPercent;
  final List<SubscriptionModel> unusuallyExpensiveSubscriptions;
  final List<SubscriptionBreakdown> renewalsWithinSevenDays;
}
