import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/financial_engine/risk_level.dart';
import '../../../core/utils/currency_format.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../../shared/widgets/app_shell.dart';

class CollisionScreen extends ConsumerWidget {
  const CollisionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(financialSnapshotProvider);
    final result = ref.watch(financialRiskResultProvider);
    final riskColor = switch (result.riskLevel) {
      RiskLevel.low => AppColors.success,
      RiskLevel.medium => AppColors.warning,
      RiskLevel.high => AppColors.danger,
      RiskLevel.critical => AppColors.critical,
    };

    return AppShell(
      currentIndex: 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Financial Collision',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.03),
                    blurRadius: 24,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.riskLevel.compactLabel,
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.riskTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _MetricRow(
                    label: 'Current balance',
                    value: _money(snapshot.currentBalance),
                  ),
                  const SizedBox(height: 12),
                  _MetricRow(
                    label: 'Upcoming commitments',
                    value: _money(result.upcomingCommitmentTotal),
                  ),
                  const SizedBox(height: 12),
                  _MetricRow(
                    label: 'Projected remaining',
                    value: _money(result.projectedBalance),
                  ),
                  const SizedBox(height: 12),
                  _MetricRow(
                    label: 'Safety buffer',
                    value: _money(snapshot.safetyBuffer),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Why this matters',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            _InfoCard(
              title: 'Upcoming concentration',
              description: result.commitmentsWithin7Days == 0
                  ? 'No unpaid commitments are due within the next 7 days.'
                  : '${result.commitmentsWithin7Days} unpaid commitments totaling ${_money(result.commitmentsWithin7DaysAmount)} are due within the next 7 days.',
            ),
            const SizedBox(height: 14),
            _InfoCard(
              title: result.bufferBreached
                  ? 'Safety buffer breached'
                  : 'Safety buffer intact',
              description: result.bufferBreached
                  ? 'The projected balance is ${_money(snapshot.safetyBuffer - result.projectedBalance)} below your safety buffer.'
                  : 'The projected balance remains ${_money(result.projectedBalance - snapshot.safetyBuffer)} above your safety buffer.',
            ),
            const SizedBox(height: 14),
            _InfoCard(
              title: 'Credit utilization',
              description:
                  'Current utilization is ${snapshot.creditUtilization.toStringAsFixed(0)}%.',
            ),
            const SizedBox(height: 14),
            _InfoCard(
              title: 'Recommended next step',
              description: result.recommendedAction,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.go('/simulator'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Simulate a Solution →',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

String _money(double amount) => formatRupees(amount);

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
