import '../../../core/financial_engine/risk_level.dart';

class SimulationResult {
  const SimulationResult({
    required this.plannedPurchaseAmount,
    required this.currentProjectedBalance,
    required this.simulatedProjectedBalance,
    required this.currentRiskLevel,
    required this.simulatedRiskLevel,
    required this.currentCollisionDetected,
    required this.simulatedCollisionDetected,
    required this.balanceChange,
    required this.safetyBuffer,
    required this.message,
    required this.recommendation,
  });

  final double plannedPurchaseAmount;
  final double currentProjectedBalance;
  final double simulatedProjectedBalance;
  final RiskLevel currentRiskLevel;
  final RiskLevel simulatedRiskLevel;
  final bool currentCollisionDetected;
  final bool simulatedCollisionDetected;
  final double balanceChange;
  final double safetyBuffer;
  final String message;
  final String recommendation;
}
