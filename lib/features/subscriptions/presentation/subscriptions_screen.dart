import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../../../models/subscription.dart';
import '../../../shared/widgets/app_shell.dart';
import '../models/subscription_insight.dart';
import '../models/subscription_summary.dart';
import '../providers/subscription_intelligence_provider.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(subscriptionSummaryProvider);

    return AppShell(
      currentIndex: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 22, bottom: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SUBSCRIPTION INTELLIGENCE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.7,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Understand the recurring commitments hiding in your monthly cash flow.',
              style: TextStyle(
                fontSize: 24,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            _SummarySection(summary: summary),
            const SizedBox(height: 30),
            _SectionHeading(
              eyebrow: 'RECURRING COMMITMENTS',
              title: 'Your services',
              trailing: '${summary.activeCount} active',
            ),
            const SizedBox(height: 8),
            if (summary.breakdown.isEmpty)
              const _EmptyMessage(
                message: 'No recurring subscriptions are currently listed.',
              )
            else
              _CommitmentsList(summary: summary),
            const SizedBox(height: 30),
            _SectionHeading(eyebrow: 'NEXT RENEWALS', title: 'Coming up'),
            const SizedBox(height: 8),
            if (summary.upcomingRenewals.isEmpty)
              const _EmptyMessage(
                message:
                    'There are no upcoming renewals in your subscription data.',
              )
            else
              _RenewalsList(
                renewals: summary.upcomingRenewals.take(3).toList(),
              ),
            const SizedBox(height: 30),
            _SectionHeading(
              eyebrow: 'MONTHLY MIX',
              title: 'Spending breakdown',
            ),
            const SizedBox(height: 8),
            _SpendingBreakdown(summary: summary),
            const SizedBox(height: 30),
            _SectionHeading(
              eyebrow: 'INSIGHTS',
              title: 'What stands out',
              trailing: '${summary.insights.length} insights',
            ),
            const SizedBox(height: 8),
            if (summary.insights.isEmpty)
              const _EmptyMessage(
                message: 'Add subscription details to see spending insights.',
              )
            else
              ...summary.insights.map(
                (insight) => _InsightRow(insight: insight),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});

  final SubscriptionSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final metrics = [
          _Metric(
            label: 'MONTHLY COMMITMENT',
            value: _money(summary.monthlyTotal),
            prominent: true,
          ),
          _Metric(
            label: 'ANNUAL COMMITMENT',
            value: _money(summary.annualTotal),
          ),
          _Metric(label: 'ACTIVE SERVICES', value: '${summary.activeCount}'),
        ];

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 18 : 22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.035),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    metrics.first,
                    const Divider(height: 26, color: AppColors.border),
                    Row(
                      children: [
                        Expanded(child: metrics[1]),
                        Expanded(child: metrics[2]),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: metrics[0]),
                    _metricDivider(),
                    Expanded(child: metrics[1]),
                    _metricDivider(),
                    Expanded(child: metrics[2]),
                  ],
                ),
        );
      },
    );
  }

  Widget _metricDivider() => Container(
    height: 48,
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 18),
    color: AppColors.border,
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.prominent = false,
  });

  final String label;
  final String value;
  final bool prominent;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
      const SizedBox(height: 7),
      Text(
        value,
        style: TextStyle(
          fontSize: prominent ? 30 : 23,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
      ),
    ],
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      if (trailing != null)
        Text(
          trailing!,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
    ],
  );
}

class _CommitmentsList extends StatelessWidget {
  const _CommitmentsList({required this.summary});

  final SubscriptionSummary summary;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        for (var index = 0; index < summary.breakdown.length; index++) ...[
          _CommitmentRow(item: summary.breakdown[index]),
          if (index < summary.breakdown.length - 1)
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Divider(height: 1, color: AppColors.border),
            ),
        ],
      ],
    ),
  );
}

class _CommitmentRow extends StatelessWidget {
  const _CommitmentRow({required this.item});

  final SubscriptionBreakdown item;

  @override
  Widget build(BuildContext context) {
    final subscription = item.subscription;
    final withinWeek = item.renewsWithinSevenDays;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _serviceIcon(subscription.merchant),
              color: AppColors.accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.merchant,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_cycleLabel(subscription.billingCycle)} · Renews ${_formatDate(item.nextRenewal)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_money(item.monthlyEquivalent)} / mo',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              _RenewalBadge(
                withinWeek: withinWeek,
                renewalDate: item.nextRenewal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RenewalsList extends StatelessWidget {
  const _RenewalsList({required this.renewals});

  final List<SubscriptionBreakdown> renewals;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        for (var index = 0; index < renewals.length; index++) ...[
          _RenewalRow(item: renewals[index]),
          if (index < renewals.length - 1)
            const Divider(height: 1, color: AppColors.border),
        ],
      ],
    ),
  );
}

class _RenewalRow extends StatelessWidget {
  const _RenewalRow({required this.item});

  final SubscriptionBreakdown item;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 13),
    child: Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            _shortDate(item.nextRenewal),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            item.subscription.merchant,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        _RenewalBadge(
          withinWeek: item.renewsWithinSevenDays,
          renewalDate: item.nextRenewal,
        ),
        const SizedBox(width: 12),
        Text(
          _money(item.renewalAmount),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _RenewalBadge extends StatelessWidget {
  const _RenewalBadge({required this.withinWeek, required this.renewalDate});

  final bool withinWeek;
  final DateTime renewalDate;

  @override
  Widget build(BuildContext context) {
    final color = withinWeek ? AppColors.warning : AppColors.success;
    final background = withinWeek
        ? AppColors.warning.withValues(alpha: 0.13)
        : AppColors.success.withValues(alpha: 0.1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        withinWeek ? 'Within 7 days' : 'Upcoming',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SpendingBreakdown extends StatelessWidget {
  const _SpendingBreakdown({required this.summary});

  final SubscriptionSummary summary;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: summary.breakdown.isEmpty
        ? const Text(
            'No monthly subscription spending to display.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          )
        : Column(
            children: summary.breakdown.map((item) {
              final fraction = (item.spendingSharePercent / 100).clamp(
                0.0,
                1.0,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    SizedBox(
                      width: 112,
                      child: Text(
                        item.subscription.merchant,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 7,
                          backgroundColor: AppColors.backgroundAlt,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 42,
                      child: Text(
                        '${item.spendingSharePercent.toStringAsFixed(0)}%',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
  );
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.insight});

  final SubscriptionInsight insight;

  @override
  Widget build(BuildContext context) {
    final color = switch (insight.severity) {
      SubscriptionInsightSeverity.low => AppColors.success,
      SubscriptionInsightSeverity.medium => AppColors.warning,
      SubscriptionInsightSeverity.high => AppColors.danger,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  insight.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  insight.actionLabel.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      message,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
    ),
  );
}

String _money(double amount) => formatRupees(amount);

String _cycleLabel(BillingCycle cycle) => switch (cycle) {
  BillingCycle.monthly => 'Monthly',
  BillingCycle.yearly => 'Yearly',
};

IconData _serviceIcon(String merchant) {
  final normalized = merchant.toLowerCase();
  if (normalized.contains('music') || normalized.contains('spotify')) {
    return Icons.music_note_rounded;
  }
  if (normalized.contains('video') ||
      normalized.contains('netflix') ||
      normalized.contains('prime')) {
    return Icons.play_circle_outline_rounded;
  }
  if (normalized.contains('adobe')) {
    return Icons.palette_outlined;
  }
  if (normalized.contains('notion')) {
    return Icons.edit_note_rounded;
  }
  return Icons.autorenew_rounded;
}

String _formatDate(DateTime date) => '${_monthName(date.month)} ${date.day}';

String _shortDate(DateTime date) =>
    '${_monthName(date.month).substring(0, 3).toUpperCase()} ${date.day}';

String _monthName(int month) => const [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][month - 1];
