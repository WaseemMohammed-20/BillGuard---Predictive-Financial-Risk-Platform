class FinancialSnapshot {
  const FinancialSnapshot({
    required this.currentBalance,
    required this.expectedIncome,
    required this.safetyBuffer,
    this.creditUtilization = 0,
  });

  final double currentBalance;
  final double expectedIncome;
  final double safetyBuffer;
  final double creditUtilization;
}
