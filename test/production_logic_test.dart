import 'package:billguard/core/financial_engine/financial_collision_engine.dart';
import 'package:billguard/core/constants/mock_data.dart';
import 'package:billguard/core/utils/billing_dates.dart';
import 'package:billguard/core/utils/currency_format.dart';
import 'package:billguard/models/bill.dart';
import 'package:billguard/models/subscription.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = FinancialCollisionEngine();

  test(
    'seven-day commitments use date-only inclusive bounds and omit paid bills',
    () {
      final bills = [
        Bill(
          id: 'today',
          title: 'Today',
          amount: 100,
          dueDate: DateTime(2026, 9, 28, 23, 59),
          category: BillCategory.rent,
          status: BillStatus.pending,
        ),
        Bill(
          id: 'last-day',
          title: 'Last day',
          amount: 200,
          dueDate: DateTime(2026, 10, 5, 23, 59),
          category: BillCategory.utilities,
          status: BillStatus.pending,
        ),
        Bill(
          id: 'outside',
          title: 'Outside',
          amount: 300,
          dueDate: DateTime(2026, 10, 6),
          category: BillCategory.utilities,
          status: BillStatus.pending,
        ),
        Bill(
          id: 'paid',
          title: 'Paid',
          amount: 400,
          dueDate: DateTime(2026, 10, 1),
          category: BillCategory.utilities,
          status: BillStatus.paid,
        ),
      ];

      final withinWindow = engine.commitmentsWithin7Days(
        bills,
        now: DateTime(2026, 9, 28, 23, 59),
      );
      expect(withinWindow.map((bill) => bill.id), ['today', 'last-day']);
      expect(
        engine.totalAmountWithin7Days(bills, now: DateTime(2026, 9, 28)),
        300,
      );
      expect(engine.upcomingCommitmentTotal(bills), 600);
    },
  );

  test('engine includes unique recurring subscriptions in projected risk', () {
    final result = engine.analyzeFinancialRisk(
      snapshot: MockData.snapshot,
      bills: MockData.bills,
      subscriptions: MockData.subscriptions,
      now: DateTime(2026, 9, 28),
    );

    expect(result.upcomingCommitmentTotal, 46442);
    expect(result.projectedBalance, -1442);
    expect(result.commitmentsWithin7Days, 4);
    expect(result.collisionDetected, isTrue);
  });

  test('monthly renewals retain their original month-end anchor', () {
    expect(
      nextBillingOccurrence(
        anchorDate: DateTime(2026, 1, 31),
        cycle: BillingCycle.monthly,
        onOrAfter: DateTime(2026, 3, 1),
      ),
      DateTime(2026, 3, 31),
    );
  });

  test('annual renewals handle leap-day anchors', () {
    expect(
      nextBillingOccurrence(
        anchorDate: DateTime(2024, 2, 29),
        cycle: BillingCycle.yearly,
        onOrAfter: DateTime(2026, 2, 28),
      ),
      DateTime(2026, 2, 28),
    );
  });

  test('Indian currency formatter handles grouped and negative balances', () {
    expect(formatRupees(4742), '₹4,742');
    expect(formatRupees(12345678), '₹1,23,45,678');
    expect(formatRupees(-1442), '-₹1,442');
    expect(formatRupees(double.nan), '₹0');
  });
}
