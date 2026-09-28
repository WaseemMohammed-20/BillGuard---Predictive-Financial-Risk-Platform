import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/mock_data.dart';
import '../../../core/financial_engine/financial_collision_engine.dart';
import '../../../models/bill.dart';
import '../../../models/financial_snapshot.dart';
import '../../../models/subscription.dart';
import '../../../models/transaction.dart';

final financialSnapshotProvider = Provider<FinancialSnapshot>(
  (ref) => MockData.snapshot,
);

final billsProvider = Provider<List<Bill>>((ref) => MockData.bills);

final upcomingCommitmentsProvider = Provider<List<Bill>>((ref) {
  final currentBills = const FinancialCollisionEngine().financialCommitments(
    bills: ref.watch(billsProvider),
    subscriptions: ref.watch(subscriptionsProvider),
  );
  return currentBills;
});

final transactionsProvider = Provider<List<TransactionModel>>(
  (ref) => MockData.transactions,
);

final subscriptionsProvider = Provider<List<SubscriptionModel>>(
  (ref) => MockData.subscriptions,
);

final projectedCashFlowProvider = Provider<List<double>>((ref) {
  final snapshot = ref.watch(financialSnapshotProvider);
  final bills = ref.watch(billsProvider);
  final subscriptions = ref.watch(subscriptionsProvider);
  final engine = const FinancialCollisionEngine();
  final now = DateTime.now();
  return List<double>.generate(8, (index) {
    final throughDate = DateTime(now.year, now.month, now.day + index * 2);
    return engine.projectedBalanceAtDate(
      currentBalance: snapshot.currentBalance,
      expectedIncome: snapshot.expectedIncome,
      bills: bills,
      subscriptions: subscriptions,
      throughDate: throughDate,
      now: now,
    );
  });
});

final financialRiskResultProvider = Provider<FinancialRiskResult>((ref) {
  final snapshot = ref.watch(financialSnapshotProvider);
  final bills = ref.watch(billsProvider);
  final subscriptions = ref.watch(subscriptionsProvider);
  return const FinancialCollisionEngine().analyzeFinancialRisk(
    snapshot: snapshot,
    bills: bills,
    subscriptions: subscriptions,
  );
});
