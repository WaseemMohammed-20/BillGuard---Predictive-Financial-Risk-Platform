import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

import '../../../core/financial_engine/financial_collision_engine.dart';
import '../../../core/financial_engine/risk_level.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';
import '../models/simulation_result.dart';

final plannedPurchaseProvider = StateProvider<double>((ref) => 5000);

final simulatorResultProvider = Provider<SimulationResult>((ref) {
  final snapshot = ref.watch(financialSnapshotProvider);
  final bills = ref.watch(billsProvider);
  final subscriptions = ref.watch(subscriptionsProvider);
  final purchaseAmount = ref.watch(plannedPurchaseProvider);
  final engine = const FinancialCollisionEngine();

  final currentRisk = engine.analyzeFinancialRisk(
    snapshot: snapshot,
    bills: bills,
    subscriptions: subscriptions,
  );
  final simulatedRisk = engine.analyzeFinancialRisk(
    snapshot: snapshot,
    bills: bills,
    subscriptions: subscriptions,
    plannedPurchase: purchaseAmount,
  );
  final currentProjectedBalance = currentRisk.projectedBalance;
  final simulatedProjectedBalance = simulatedRisk.projectedBalance;
  final currentRiskLevel = currentRisk.riskLevel;
  final simulatedRiskLevel = simulatedRisk.riskLevel;
  final currentCollisionDetected = currentRisk.collisionDetected;
  final simulatedCollisionDetected = simulatedRisk.collisionDetected;

  String message;
  if (simulatedProjectedBalance < 0) {
    message = 'This purchase would create a projected shortfall.';
  } else if (simulatedProjectedBalance < snapshot.safetyBuffer) {
    message = 'This purchase would push your projected balance below your safety buffer.';
  } else {
    message =
        'This purchase remains within your current financial safety margin.';
  }

  String recommendation;
  switch (simulatedRiskLevel) {
    case RiskLevel.low:
      recommendation = 'Within your current safety margin.';
      break;
    case RiskLevel.medium:
      recommendation =
          'Consider reducing the purchase or waiting for expected income.';
      break;
    case RiskLevel.high:
      recommendation = 'This purchase increases financial pressure.';
      break;
    case RiskLevel.critical:
      recommendation = 'This purchase creates a projected shortfall.';
      break;
  }

  return SimulationResult(
    plannedPurchaseAmount: purchaseAmount,
    currentProjectedBalance: currentProjectedBalance,
    simulatedProjectedBalance: simulatedProjectedBalance,
    currentRiskLevel: currentRiskLevel,
    simulatedRiskLevel: simulatedRiskLevel,
    currentCollisionDetected: currentCollisionDetected,
    simulatedCollisionDetected: simulatedCollisionDetected,
    balanceChange: simulatedProjectedBalance - currentProjectedBalance,
    safetyBuffer: snapshot.safetyBuffer,
    message: message,
    recommendation: recommendation,
  );
});
