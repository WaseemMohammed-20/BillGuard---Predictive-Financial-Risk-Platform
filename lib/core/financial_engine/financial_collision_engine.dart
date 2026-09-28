import '../../models/bill.dart';
import '../../models/financial_snapshot.dart';
import '../../models/risk_event.dart';
import '../../models/subscription.dart';
import '../utils/billing_dates.dart';
import 'risk_level.dart';

class FinancialRiskResult {
  const FinancialRiskResult({
    required this.projectedBalance,
    required this.upcomingCommitmentTotal,
    required this.commitmentsWithin7Days,
    required this.commitmentsWithin7DaysAmount,
    required this.safetyBuffer,
    required this.bufferBreached,
    required this.collisionDetected,
    required this.riskLevel,
    required this.riskTitle,
    required this.riskDescription,
    required this.recommendedAction,
    required this.financialHealthScore,
  });

  final double projectedBalance;
  final double upcomingCommitmentTotal;
  final int commitmentsWithin7Days;
  final double commitmentsWithin7DaysAmount;
  final double safetyBuffer;
  final bool bufferBreached;
  final bool collisionDetected;
  final RiskLevel riskLevel;
  final String riskTitle;
  final String riskDescription;
  final String recommendedAction;
  final int financialHealthScore;
}

class FinancialCollisionEngine {
  const FinancialCollisionEngine();

  double calculateProjectedBalance({
    required double currentBalance,
    required double expectedIncome,
    required double upcomingCommitments,
    required double plannedPurchase,
  }) {
    return currentBalance +
        expectedIncome -
        upcomingCommitments -
        plannedPurchase;
  }

  List<Bill> financialCommitments({
    required List<Bill> bills,
    List<SubscriptionModel> subscriptions = const [],
    DateTime? now,
  }) {
    final effectiveDate = now ?? DateTime.now();
    final commitments = bills
        .where((bill) => bill.status != BillStatus.paid)
        .toList();
    for (final subscription in subscriptions) {
      final renewalDate = nextBillingOccurrence(
        anchorDate: subscription.nextBillingDate,
        cycle: subscription.billingCycle,
        onOrAfter: effectiveDate,
      );
      final alreadyListed = bills.any(
        (bill) =>
            bill.category == BillCategory.subscription &&
            _sameDate(bill.dueDate, renewalDate) &&
            bill.amount == subscription.amount &&
            _sameMerchant(bill.title, subscription.merchant),
      );
      if (alreadyListed) continue;
      commitments.add(
        Bill(
          id: 'subscription-${subscription.id}',
          title: subscription.merchant,
          amount: subscription.amount,
          dueDate: renewalDate,
          category: BillCategory.subscription,
          status: BillStatus.pending,
        ),
      );
    }
    commitments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return commitments;
  }

  double upcomingCommitmentTotal(
    List<Bill> bills, {
    List<SubscriptionModel> subscriptions = const [],
    DateTime? now,
  }) {
    return financialCommitments(
      bills: bills,
      subscriptions: subscriptions,
      now: now,
    ).fold<double>(0, (sum, bill) => sum + bill.amount);
  }

  double projectedBalanceAtDate({
    required double currentBalance,
    required double expectedIncome,
    required List<Bill> bills,
    List<SubscriptionModel> subscriptions = const [],
    required DateTime throughDate,
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final start = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );
    final end = DateTime(throughDate.year, throughDate.month, throughDate.day);
    final commitmentsThroughDate =
        financialCommitments(
              bills: bills,
              subscriptions: subscriptions,
              now: currentDate,
            )
            .where((bill) {
              final dueDate = DateTime(
                bill.dueDate.year,
                bill.dueDate.month,
                bill.dueDate.day,
              );
              return !dueDate.isBefore(start) && !dueDate.isAfter(end);
            })
            .fold<double>(0, (sum, bill) => sum + bill.amount);

    return calculateProjectedBalance(
      currentBalance: currentBalance,
      expectedIncome: expectedIncome,
      upcomingCommitments: commitmentsThroughDate,
      plannedPurchase: 0,
    );
  }

  List<Bill> commitmentsWithin7Days(
    List<Bill> bills, {
    List<SubscriptionModel> subscriptions = const [],
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final referenceDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );
    final endDate = referenceDate.add(const Duration(days: 7));
    return financialCommitments(
          bills: bills,
          subscriptions: subscriptions,
          now: referenceDate,
        )
        .where(
          (bill) =>
              !DateTime(
                bill.dueDate.year,
                bill.dueDate.month,
                bill.dueDate.day,
              ).isBefore(referenceDate) &&
              !DateTime(
                bill.dueDate.year,
                bill.dueDate.month,
                bill.dueDate.day,
              ).isAfter(endDate),
        )
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  double totalAmountWithin7Days(
    List<Bill> bills, {
    List<SubscriptionModel> subscriptions = const [],
    DateTime? now,
  }) {
    final relevant = commitmentsWithin7Days(
      bills,
      subscriptions: subscriptions,
      now: now,
    );
    return relevant.fold<double>(0, (sum, bill) => sum + bill.amount);
  }

  RiskLevel determineRiskLevel({
    required double projectedBalance,
    required double safetyBuffer,
    required int commitmentsWithin7Days,
    required double commitmentsWithin7DaysAmount,
  }) {
    final severeConcentration =
        commitmentsWithin7Days >= 3 &&
        commitmentsWithin7DaysAmount >= safetyBuffer * 0.5;

    if (projectedBalance < 0 ||
        severeConcentration && projectedBalance < safetyBuffer * 0.25) {
      return RiskLevel.critical;
    }

    if (projectedBalance < safetyBuffer ||
        commitmentsWithin7Days >= 3 ||
        commitmentsWithin7DaysAmount >= safetyBuffer) {
      return RiskLevel.high;
    }

    if (projectedBalance < safetyBuffer * 1.25 || commitmentsWithin7Days >= 2) {
      return RiskLevel.medium;
    }

    return RiskLevel.low;
  }

  int calculateFinancialHealthScore(RiskLevel riskLevel) {
    return switch (riskLevel) {
      RiskLevel.low => 85,
      RiskLevel.medium => 68,
      RiskLevel.high => 47,
      RiskLevel.critical => 24,
    };
  }

  bool hasSafetyBufferBreach({
    required double projectedBalance,
    required double safetyBuffer,
  }) {
    return projectedBalance < safetyBuffer;
  }

  bool isCollisionDetected({
    required double projectedBalance,
    required double safetyBuffer,
    required int commitmentsWithin7Days,
  }) {
    final bufferBreach = projectedBalance < safetyBuffer;
    return projectedBalance < 0 ||
        (commitmentsWithin7Days >= 3 && bufferBreach);
  }

  FinancialRiskResult analyzeFinancialRisk({
    required FinancialSnapshot snapshot,
    required List<Bill> bills,
    List<SubscriptionModel> subscriptions = const [],
    double plannedPurchase = 0,
    DateTime? now,
  }) {
    final totalUpcoming = upcomingCommitmentTotal(
      bills,
      subscriptions: subscriptions,
      now: now,
    );
    final relevantBills = commitmentsWithin7Days(
      bills,
      subscriptions: subscriptions,
      now: now,
    );
    final relevantAmount = relevantBills.fold<double>(
      0,
      (sum, bill) => sum + bill.amount,
    );
    final projectedBalance = calculateProjectedBalance(
      currentBalance: snapshot.currentBalance,
      expectedIncome: snapshot.expectedIncome,
      upcomingCommitments: totalUpcoming,
      plannedPurchase: plannedPurchase,
    );

    final riskLevel = determineRiskLevel(
      projectedBalance: projectedBalance,
      safetyBuffer: snapshot.safetyBuffer,
      commitmentsWithin7Days: relevantBills.length,
      commitmentsWithin7DaysAmount: relevantAmount,
    );

    final bufferBreached = hasSafetyBufferBreach(
      projectedBalance: projectedBalance,
      safetyBuffer: snapshot.safetyBuffer,
    );

    final collisionDetected = isCollisionDetected(
      projectedBalance: projectedBalance,
      safetyBuffer: snapshot.safetyBuffer,
      commitmentsWithin7Days: relevantBills.length,
    );

    final title = switch (riskLevel) {
      RiskLevel.low => 'Low pressure forecast',
      RiskLevel.medium => 'Moderate pressure building',
      RiskLevel.high =>
        collisionDetected
            ? 'Financial collision'
            : 'High payment concentration',
      RiskLevel.critical => 'Critical shortfall',
    };

    final description = switch (riskLevel) {
      RiskLevel.low => 'Your upcoming obligations remain comfortably within your available runway.',
      RiskLevel.medium => riskResultDescription(
        projectedBalance: projectedBalance,
        safetyBuffer: snapshot.safetyBuffer,
        commitmentsWithin7Days: relevantBills.length,
      ),
      RiskLevel.high => riskResultDescription(
        projectedBalance: projectedBalance,
        safetyBuffer: snapshot.safetyBuffer,
        commitmentsWithin7Days: relevantBills.length,
      ),
      RiskLevel.critical => 'Your projected balance is negative or the shortfall is severe enough to create a major liquidity gap.',
    };

    final recommendedAction = switch (riskLevel) {
      RiskLevel.low =>
        'Maintain your current pacing and keep a 2-month buffer in reserve.',
      RiskLevel.medium =>
        'Review the next few payments and avoid additional large purchases.',
      RiskLevel.high =>
        'Review upcoming commitments before making another large purchase.',
      RiskLevel.critical => 'Reduce discretionary spending immediately and renegotiate any near-term obligations.',
    };

    return FinancialRiskResult(
      projectedBalance: projectedBalance,
      upcomingCommitmentTotal: totalUpcoming,
      commitmentsWithin7Days: relevantBills.length,
      commitmentsWithin7DaysAmount: relevantAmount,
      safetyBuffer: snapshot.safetyBuffer,
      bufferBreached: bufferBreached,
      collisionDetected: collisionDetected,
      riskLevel: riskLevel,
      riskTitle: title,
      riskDescription: description,
      recommendedAction: recommendedAction,
      financialHealthScore: calculateFinancialHealthScore(riskLevel),
    );
  }

  String riskResultDescription({
    required double projectedBalance,
    required double safetyBuffer,
    required int commitmentsWithin7Days,
  }) {
    final bufferBreached = projectedBalance < safetyBuffer;
    final clustered = commitmentsWithin7Days >= 3;
    if (bufferBreached && clustered) {
      return 'Your projected balance is below the safety buffer, with $commitmentsWithin7Days commitments due within 7 days.';
    }
    if (bufferBreached) {
      return 'Your projected balance is below the safety buffer.';
    }
    if (clustered) {
      return '$commitmentsWithin7Days commitments are due within 7 days, concentrating near-term cash flow.';
    }
    return 'Your forecast is approaching a tighter financial margin.';
  }

  bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  String _normalizeMerchant(String merchant) =>
      merchant.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  bool _sameMerchant(String first, String second) {
    final normalizedFirst = _normalizeMerchant(first);
    final normalizedSecond = _normalizeMerchant(second);
    return normalizedFirst == normalizedSecond ||
        normalizedFirst.startsWith(normalizedSecond) ||
        normalizedSecond.startsWith(normalizedFirst);
  }

  List<RiskEvent> detectCollisions({
    required FinancialSnapshot snapshot,
    required List<Bill> bills,
    List<SubscriptionModel> subscriptions = const [],
    required double plannedPurchase,
    DateTime? now,
  }) {
    final riskResult = analyzeFinancialRisk(
      snapshot: snapshot,
      bills: bills,
      subscriptions: subscriptions,
      plannedPurchase: plannedPurchase,
      now: now,
    );

    if (!riskResult.collisionDetected) {
      return const [];
    }

    final severity = switch (riskResult.riskLevel) {
      RiskLevel.low => RiskSeverity.low,
      RiskLevel.medium => RiskSeverity.medium,
      RiskLevel.high => RiskSeverity.high,
      RiskLevel.critical => RiskSeverity.critical,
    };

    return [
      RiskEvent(
        id: 'financial-collision',
        title: riskResult.riskTitle,
        description: riskResult.riskDescription,
        severity: severity,
        amount: riskResult.commitmentsWithin7DaysAmount,
        date: DateTime.now(),
        actionLabel: riskResult.recommendedAction,
      ),
    ];
  }
}
