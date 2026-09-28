import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial_engine/financial_collision_engine.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';
import '../models/timeline_event.dart';

final timelineReferenceDateProvider = Provider<DateTime>(
  (ref) => DateTime.now(),
);

final timelineEventsProvider = Provider<List<TimelineEvent>>((ref) {
  final bills = ref.watch(billsProvider);
  final subscriptions = ref.watch(subscriptionsProvider);
  final snapshot = ref.watch(financialSnapshotProvider);
  final engine = const FinancialCollisionEngine();
  final now = ref.watch(timelineReferenceDateProvider);
  final commitments = engine.financialCommitments(
    bills: bills,
    subscriptions: subscriptions,
    now: now,
  );
  final nearTermCommitments = engine.commitmentsWithin7Days(
    commitments,
    now: now,
  );
  final nearTermAmount = nearTermCommitments.fold<double>(
    0,
    (sum, bill) => sum + bill.amount,
  );
  final events = <TimelineEvent>[];
  double runningBalance = snapshot.currentBalance + snapshot.expectedIncome;

  for (final commitment in commitments) {
    runningBalance -= commitment.amount;
    final projectedAfter = runningBalance;
    final riskLevel = engine.determineRiskLevel(
      projectedBalance: projectedAfter,
      safetyBuffer: snapshot.safetyBuffer,
      commitmentsWithin7Days: nearTermCommitments.length,
      commitmentsWithin7DaysAmount: nearTermAmount,
    );

    events.add(
      TimelineEvent(
        id: commitment.id,
        title: commitment.title,
        date: commitment.dueDate,
        type: commitment.category.name == 'subscription'
            ? TimelineEventType.subscription
            : TimelineEventType.bill,
        amount: commitment.amount,
        category: commitment.category.name,
        projectedBalanceAfter: projectedAfter,
        riskLevel: riskLevel,
        isBreachingBuffer: projectedAfter < snapshot.safetyBuffer,
        description: commitment.category.name == 'subscription'
            ? 'Recurring subscription'
            : 'Scheduled payment',
      ),
    );
  }

  return events;
});
