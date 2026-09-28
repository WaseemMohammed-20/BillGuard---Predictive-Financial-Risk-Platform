enum RiskLevel { low, medium, high, critical }

extension RiskLevelLabel on RiskLevel {
  String get label => switch (this) {
    RiskLevel.low => 'Low',
    RiskLevel.medium => 'Medium',
    RiskLevel.high => 'High',
    RiskLevel.critical => 'Critical',
  };

  String get compactLabel => switch (this) {
    RiskLevel.low => 'LOW',
    RiskLevel.medium => 'MEDIUM',
    RiskLevel.high => 'HIGH',
    RiskLevel.critical => 'CRITICAL',
  };
}
