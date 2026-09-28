import 'package:billguard/features/dashboard/providers/dashboard_providers.dart';
import 'package:billguard/features/subscriptions/models/subscription_insight.dart';
import 'package:billguard/features/subscriptions/providers/subscription_intelligence_provider.dart';
import 'package:billguard/models/subscription.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixedDate = DateTime(2026, 9, 28);

  ProviderContainer createContainer({List<SubscriptionModel>? subscriptions}) {
    return ProviderContainer(
      overrides: [
        subscriptionIntelligenceDateProvider.overrideWithValue(fixedDate),
        if (subscriptions != null)
          subscriptionsProvider.overrideWithValue(subscriptions),
      ],
    );
  }

  test(
    'calculates active count and monthly and annual totals from mock data',
    () {
      final container = createContainer();
      addTearDown(container.dispose);
      final summary = container.read(subscriptionSummaryProvider);

      expect(summary.activeCount, 5);
      expect(summary.monthlyTotal, 4742);
      expect(summary.annualTotal, 56904);
    },
  );

  test('identifies the largest subscription', () {
    final container = createContainer();
    addTearDown(container.dispose);
    final summary = container.read(subscriptionSummaryProvider);

    expect(summary.largestSubscription?.merchant, 'Adobe Creative Cloud');
    expect(summary.largestSubscriptionAmount, 1675);
  });

  test('orders upcoming renewals chronologically', () {
    final container = createContainer();
    addTearDown(container.dispose);
    final renewals = container
        .read(subscriptionSummaryProvider)
        .upcomingRenewals;

    expect(renewals.map((item) => item.subscription.merchant).toList(), [
      'Netflix',
      'Adobe Creative Cloud',
      'Amazon Prime',
      'Spotify',
      'Notion',
    ]);
    expect(renewals.first.nextRenewal, DateTime(2026, 10, 5));
  });

  test('generates dynamic financial insights without usage assumptions', () {
    final container = createContainer();
    addTearDown(container.dispose);
    final summary = container.read(subscriptionSummaryProvider);
    final descriptions = summary.insights
        .map((insight) => insight.description)
        .join(' ');

    expect(summary.insights, isNotEmpty);
    expect(
      summary.insights.any(
        (insight) => insight.type == SubscriptionInsightType.monthlyCommitment,
      ),
      isTrue,
    );
    expect(
      summary.insights.any(
        (insight) => insight.type == SubscriptionInsightType.annualCommitment,
      ),
      isTrue,
    );
    expect(
      summary.insights.any(
        (insight) => insight.type == SubscriptionInsightType.renewalPressure,
      ),
      isTrue,
    );
    expect(descriptions, contains('₹4,742'));
    expect(descriptions.toLowerCase(), isNot(contains('unused')));
  });

  test('handles an empty subscription list', () {
    final container = createContainer(subscriptions: const []);
    addTearDown(container.dispose);
    final summary = container.read(subscriptionSummaryProvider);

    expect(summary.activeCount, 0);
    expect(summary.monthlyTotal, 0);
    expect(summary.annualTotal, 0);
    expect(summary.largestSubscription, isNull);
    expect(summary.largestSubscriptionAmount, 0);
    expect(summary.nextRenewal, isNull);
    expect(summary.upcomingRenewals, isEmpty);
    expect(summary.renewalsWithinSevenDays, isEmpty);
    expect(summary.insights, isNotEmpty);
  });
}
