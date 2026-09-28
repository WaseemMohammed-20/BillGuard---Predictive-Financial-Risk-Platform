import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/billing_dates.dart';
import '../../../core/utils/currency_format.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';
import '../../../models/subscription.dart';
import '../../../models/transaction.dart';
import '../models/subscription_insight.dart';
import '../models/subscription_summary.dart';

final subscriptionIntelligenceDateProvider = Provider<DateTime>(
  (ref) => DateTime.now(),
);

final subscriptionSummaryProvider = Provider<SubscriptionSummary>((ref) {
  final subscriptions = ref.watch(subscriptionsProvider);
  final transactions = ref.watch(transactionsProvider);
  final snapshot = ref.watch(financialSnapshotProvider);
  final today = _dateOnly(ref.watch(subscriptionIntelligenceDateProvider));
  final sevenDaysFromToday = today.add(const Duration(days: 7));

  final monthlyAmounts = <SubscriptionModel, double>{
    for (final subscription in subscriptions)
      subscription: subscription.billingCycle == BillingCycle.yearly
          ? subscription.amount / 12
          : subscription.amount,
  };
  final monthlyTotal = monthlyAmounts.values.fold<double>(
    0,
    (sum, amount) => sum + amount,
  );
  final annualTotal = monthlyTotal * 12;
  final largestEntry = monthlyAmounts.entries
      .fold<MapEntry<SubscriptionModel, double>?>(
        null,
        (largest, entry) =>
            largest == null || entry.value > largest.value ? entry : largest,
      );
  final monthlyIncome = _monthlyIncome(snapshot.expectedIncome, transactions);

  final sorted =
      subscriptions.map((subscription) {
        final nextRenewal = nextBillingOccurrence(
          anchorDate: subscription.nextBillingDate,
          cycle: subscription.billingCycle,
          onOrAfter: today,
        );
        final monthlyEquivalent = monthlyAmounts[subscription] ?? 0;
        return SubscriptionBreakdown(
          subscription: subscription,
          monthlyEquivalent: monthlyEquivalent,
          renewalAmount: subscription.amount,
          spendingSharePercent: monthlyTotal == 0
              ? 0
              : monthlyEquivalent / monthlyTotal * 100,
          nextRenewal: nextRenewal,
          renewsWithinSevenDays: !nextRenewal.isAfter(sevenDaysFromToday),
        );
      }).toList()..sort((a, b) {
        final dateOrder = a.nextRenewal.compareTo(b.nextRenewal);
        return dateOrder != 0
            ? dateOrder
            : a.subscription.merchant.compareTo(b.subscription.merchant);
      });

  final renewalsWithinSevenDays = sorted
      .where((item) => item.renewsWithinSevenDays)
      .toList();
  final unusualSubscriptions = _findUnusuallyExpensive(monthlyAmounts);
  final concentration = monthlyTotal == 0 || largestEntry == null
      ? 0.0
      : largestEntry.value / monthlyTotal * 100;
  final incomePercentage = monthlyIncome <= 0
      ? null
      : monthlyTotal / monthlyIncome * 100;
  final insights = _buildInsights(
    monthlyTotal: monthlyTotal,
    annualTotal: annualTotal,
    largest: largestEntry?.key,
    largestAmount: largestEntry?.value ?? 0,
    incomePercentage: incomePercentage,
    concentrationPercent: concentration,
    unusualSubscriptions: unusualSubscriptions,
    renewalsWithinSevenDays: renewalsWithinSevenDays,
    renewalAmountWithinSevenDays: renewalsWithinSevenDays.fold<double>(
      0,
      (sum, item) => sum + item.renewalAmount,
    ),
  );

  return SubscriptionSummary(
    activeCount: subscriptions.length,
    monthlyTotal: monthlyTotal,
    annualTotal: annualTotal,
    largestSubscription: largestEntry?.key,
    largestSubscriptionAmount: largestEntry?.value ?? 0,
    nextRenewal: sorted.isEmpty ? null : sorted.first.nextRenewal,
    insights: insights,
    breakdown: sorted,
    upcomingRenewals: sorted,
    monthlyIncome: monthlyIncome,
    subscriptionIncomePercentage: incomePercentage,
    concentrationPercent: concentration,
    unusuallyExpensiveSubscriptions: unusualSubscriptions,
    renewalsWithinSevenDays: renewalsWithinSevenDays,
  );
});

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

double _monthlyIncome(
  double expectedIncome,
  List<TransactionModel> transactions,
) {
  if (expectedIncome > 0) return expectedIncome;

  final creditTransactions = transactions
      .where((transaction) => transaction.type == TransactionType.credit)
      .toList();
  if (creditTransactions.isEmpty) return 0;

  creditTransactions.sort((a, b) => b.date.compareTo(a.date));
  final latestMonth = creditTransactions.first.date.month;
  final latestYear = creditTransactions.first.date.year;
  return creditTransactions
      .where(
        (transaction) =>
            transaction.date.year == latestYear &&
            transaction.date.month == latestMonth,
      )
      .fold<double>(0, (sum, transaction) => sum + transaction.amount);
}

List<SubscriptionModel> _findUnusuallyExpensive(
  Map<SubscriptionModel, double> amounts,
) {
  if (amounts.length < 3) return const [];
  final sortedAmounts = amounts.values.toList()..sort();
  final middle = sortedAmounts.length ~/ 2;
  final median = sortedAmounts.length.isOdd
      ? sortedAmounts[middle]
      : (sortedAmounts[middle - 1] + sortedAmounts[middle]) / 2;
  if (median <= 0) return const [];

  return amounts.entries
      .where((entry) => entry.value >= median * 2)
      .map((entry) => entry.key)
      .toList()
    ..sort((a, b) => (amounts[b] ?? 0).compareTo(amounts[a] ?? 0));
}

List<SubscriptionInsight> _buildInsights({
  required double monthlyTotal,
  required double annualTotal,
  required SubscriptionModel? largest,
  required double largestAmount,
  required double? incomePercentage,
  required double concentrationPercent,
  required List<SubscriptionModel> unusualSubscriptions,
  required List<SubscriptionBreakdown> renewalsWithinSevenDays,
  required double renewalAmountWithinSevenDays,
}) {
  final insights = <SubscriptionInsight>[
    SubscriptionInsight(
      id: 'monthly-commitment',
      title: 'Monthly recurring commitments',
      description: monthlyTotal == 0
          ? 'No subscription spending is currently included in your recurring monthly cash flow.'
          : 'Your recurring subscriptions total ${formatRupees(monthlyTotal)} per month.',
      type: SubscriptionInsightType.monthlyCommitment,
      severity: incomePercentage != null && incomePercentage >= 15
          ? SubscriptionInsightSeverity.high
          : incomePercentage != null && incomePercentage >= 10
          ? SubscriptionInsightSeverity.medium
          : SubscriptionInsightSeverity.low,
      amount: monthlyTotal,
      actionLabel: 'View commitments',
    ),
    SubscriptionInsight(
      id: 'annual-commitment',
      title: 'Annual recurring commitment',
      description:
          'At the current pace, subscriptions represent approximately ${formatRupees(annualTotal)} per year.',
      type: SubscriptionInsightType.annualCommitment,
      severity: SubscriptionInsightSeverity.low,
      amount: annualTotal,
      actionLabel: 'Plan ahead',
    ),
  ];

  if (largest != null) {
    insights.add(
      SubscriptionInsight(
        id: 'largest-subscription',
        title: 'Largest recurring service',
        description:
            '${largest.merchant} is currently your largest recurring subscription at ${formatRupees(largestAmount)} per month.',
        type: SubscriptionInsightType.largestSubscription,
        severity: SubscriptionInsightSeverity.low,
        amount: largestAmount,
        actionLabel: 'Review service',
      ),
    );
  }

  if (incomePercentage != null) {
    insights.add(
      SubscriptionInsight(
        id: 'income-share',
        title: 'Share of monthly income',
        description:
            'Subscriptions account for ${incomePercentage.toStringAsFixed(1)}% of the monthly income currently available in your financial data.',
        type: SubscriptionInsightType.incomeShare,
        severity: incomePercentage >= 15
            ? SubscriptionInsightSeverity.high
            : incomePercentage >= 10
            ? SubscriptionInsightSeverity.medium
            : SubscriptionInsightSeverity.low,
        amount: incomePercentage,
        actionLabel: 'Review cash flow',
      ),
    );
  }

  if (largest != null) {
    insights.add(
      SubscriptionInsight(
        id: 'subscription-concentration',
        title: 'Spending concentration',
        description:
            '${largest.merchant} represents ${concentrationPercent.toStringAsFixed(1)}% of your monthly subscription spending.',
        type: SubscriptionInsightType.concentration,
        severity: concentrationPercent >= 50
            ? SubscriptionInsightSeverity.high
            : concentrationPercent >= 35
            ? SubscriptionInsightSeverity.medium
            : SubscriptionInsightSeverity.low,
        amount: concentrationPercent,
        actionLabel: 'View breakdown',
      ),
    );
  }

  for (final subscription in unusualSubscriptions) {
    insights.add(
      SubscriptionInsight(
        id: 'unusually-expensive-${subscription.id}',
        title: 'Higher-than-typical subscription cost',
        description:
            '${subscription.merchant} costs notably more per month than the median subscription in your list. Review whether it still provides enough value for you.',
        type: SubscriptionInsightType.unusualCost,
        severity: SubscriptionInsightSeverity.medium,
        amount: subscription.billingCycle == BillingCycle.yearly
            ? subscription.amount / 12
            : subscription.amount,
        actionLabel: 'Review value',
      ),
    );
  }

  if (renewalsWithinSevenDays.isNotEmpty) {
    final renewalCount = renewalsWithinSevenDays.length;
    insights.add(
      SubscriptionInsight(
        id: 'renewal-pressure',
        title: renewalCount > 1
            ? 'Several renewals are approaching'
            : 'A renewal is approaching',
        description: renewalCount > 1
            ? '$renewalCount subscriptions renew within the next 7 days, representing ${formatRupees(renewalAmountWithinSevenDays)} in renewal charges.'
            : '${renewalsWithinSevenDays.first.subscription.merchant} renews within the next 7 days.',
        type: SubscriptionInsightType.renewalPressure,
        severity: renewalCount >= 4
            ? SubscriptionInsightSeverity.high
            : renewalCount >= 2
            ? SubscriptionInsightSeverity.medium
            : SubscriptionInsightSeverity.low,
        amount: renewalAmountWithinSevenDays,
        actionLabel: 'View next renewals',
      ),
    );
  }

  return insights;
}
