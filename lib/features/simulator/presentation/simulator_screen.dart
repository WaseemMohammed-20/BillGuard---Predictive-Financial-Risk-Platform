import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/financial_engine/risk_level.dart';
import '../../../core/utils/currency_format.dart';
import '../../../shared/widgets/app_shell.dart';
import '../providers/simulator_provider.dart';

class SimulatorScreen extends ConsumerWidget {
  const SimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulation = ref.watch(simulatorResultProvider);
    final purchaseAmount = simulation.plannedPurchaseAmount;
    final riskColor = switch (simulation.simulatedRiskLevel) {
      RiskLevel.low => AppColors.success,
      RiskLevel.medium => AppColors.warning,
      RiskLevel.high => AppColors.danger,
      RiskLevel.critical => AppColors.critical,
    };

    final riskBackground = switch (simulation.simulatedRiskLevel) {
      RiskLevel.low => AppColors.accentSoft,
      RiskLevel.medium => AppColors.warning.withValues(alpha: 0.18),
      RiskLevel.high => AppColors.danger.withValues(alpha: 0.18),
      RiskLevel.critical => AppColors.critical.withValues(alpha: 0.2),
    };

    return AppShell(
      currentIndex: 2,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WHAT-IF',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Can you afford this purchase?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Planned purchase',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller:
                                TextEditingController(
                                    text: purchaseAmount.round().toString(),
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: purchaseAmount
                                        .round()
                                        .toString()
                                        .length,
                                  ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value) ?? 0;
                              ref.read(plannedPurchaseProvider.notifier).state =
                                  parsed.clamp(0, 30000);
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _QuickAmountChip(value: 1000),
                        _QuickAmountChip(value: 5000),
                        _QuickAmountChip(value: 10000),
                        _QuickAmountChip(value: 25000),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.accent,
                        inactiveTrackColor: AppColors.border,
                        thumbColor: AppColors.accent,
                        overlayColor: AppColors.accent.withValues(alpha: 0.18),
                      ),
                      child: Slider(
                        value: purchaseAmount,
                        min: 0,
                        max: 30000,
                        divisions: 300,
                        label: '₹${purchaseAmount.round()}',
                        onChanged: (value) {
                          ref.read(plannedPurchaseProvider.notifier).state =
                              value;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '₹0',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Text(
                          '₹30,000',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT FORECAST',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ForecastMetric(
                      label: 'Projected balance',
                      value: formatRupees(simulation.currentProjectedBalance),
                    ),
                    const SizedBox(height: 8),
                    _ForecastMetric(
                      label: 'Risk level',
                      value: simulation.currentRiskLevel.compactLabel,
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 18),
                    const Text(
                      'AFTER THIS PURCHASE',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ForecastMetric(
                      label: 'Projected balance',
                      value: formatRupees(simulation.simulatedProjectedBalance),
                    ),
                    const SizedBox(height: 8),
                    _ForecastMetric(
                      label: 'Risk level',
                      value: simulation.simulatedRiskLevel.compactLabel,
                    ),
                    const SizedBox(height: 18),
                    _ForecastMetric(
                      label: 'Balance change',
                      value: formatRupees(simulation.balanceChange.abs()),
                      valueColor: simulation.balanceChange < 0
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: riskBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        simulation.simulatedRiskLevel.compactLabel,
                        style: TextStyle(
                          color: riskColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      simulation.message,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Recommendation',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      simulation.recommendation,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForecastMetric extends StatelessWidget {
  const _ForecastMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w700, color: valueColor),
        ),
      ),
    ],
  );
}

class _QuickAmountChip extends ConsumerWidget {
  const _QuickAmountChip({required this.value});

  final double value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(plannedPurchaseProvider) == value;

    return GestureDetector(
      onTap: () => ref.read(plannedPurchaseProvider.notifier).state = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentSoft : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '₹${value.toInt().toString()}',
          style: TextStyle(
            color: isSelected ? AppColors.accent : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
