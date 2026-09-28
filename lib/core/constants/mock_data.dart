import '../../models/bill.dart';
import '../../models/financial_snapshot.dart';
import '../../models/subscription.dart';
import '../../models/transaction.dart';

class MockData {
  static const snapshot = FinancialSnapshot(
    currentBalance: 45000,
    expectedIncome: 0,
    safetyBuffer: 10000,
    creditUtilization: 38,
  );

  static final bills = [
    Bill(
      id: 'bill-1',
      title: 'Credit Card',
      amount: 18500,
      dueDate: DateTime(2026, 9, 30),
      category: BillCategory.creditCard,
      status: BillStatus.dueSoon,
    ),
    Bill(
      id: 'bill-2',
      title: 'EMI',
      amount: 8200,
      dueDate: DateTime(2026, 10, 2),
      category: BillCategory.emi,
      status: BillStatus.dueSoon,
    ),
    Bill(
      id: 'bill-3',
      title: 'Rent',
      amount: 15000,
      dueDate: DateTime(2026, 10, 4),
      category: BillCategory.rent,
      status: BillStatus.dueSoon,
    ),
    Bill(
      id: 'bill-4',
      title: 'Netflix',
      amount: 649,
      dueDate: DateTime(2026, 10, 5),
      category: BillCategory.subscription,
      status: BillStatus.pending,
    ),
    Bill(
      id: 'bill-5',
      title: 'Adobe',
      amount: 1675,
      dueDate: DateTime(2026, 10, 6),
      category: BillCategory.subscription,
      status: BillStatus.pending,
    ),
  ];

  static final subscriptions = [
    SubscriptionModel(
      id: 'sub-1',
      merchant: 'Netflix',
      amount: 649,
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime(2026, 10, 5),
    ),
    SubscriptionModel(
      id: 'sub-2',
      merchant: 'Adobe Creative Cloud',
      amount: 1675,
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime(2026, 10, 6),
    ),
    SubscriptionModel(
      id: 'sub-3',
      merchant: 'Amazon Prime',
      amount: 1499,
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime(2026, 10, 15),
    ),
    SubscriptionModel(
      id: 'sub-4',
      merchant: 'Spotify',
      amount: 119,
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime(2026, 10, 18),
    ),
    SubscriptionModel(
      id: 'sub-5',
      merchant: 'Notion',
      amount: 800,
      billingCycle: BillingCycle.monthly,
      nextBillingDate: DateTime(2026, 10, 20),
    ),
  ];

  static final transactions = [
    TransactionModel(
      id: 'txn-1',
      merchant: 'Salary',
      amount: 65000,
      category: TransactionCategory.income,
      date: DateTime(2026, 9, 1),
      type: TransactionType.credit,
    ),
    TransactionModel(
      id: 'txn-2',
      merchant: 'Market Basket',
      amount: 4200,
      category: TransactionCategory.food,
      date: DateTime(2026, 9, 3),
      type: TransactionType.debit,
    ),
    TransactionModel(
      id: 'txn-3',
      merchant: 'City Metro',
      amount: 980,
      category: TransactionCategory.transport,
      date: DateTime(2026, 9, 5),
      type: TransactionType.debit,
    ),
    TransactionModel(
      id: 'txn-4',
      merchant: 'CineWorld',
      amount: 1250,
      category: TransactionCategory.entertainment,
      date: DateTime(2026, 9, 6),
      type: TransactionType.debit,
    ),
    TransactionModel(
      id: 'txn-5',
      merchant: 'Amazon',
      amount: 3299,
      category: TransactionCategory.shopping,
      date: DateTime(2026, 9, 7),
      type: TransactionType.debit,
    ),
    TransactionModel(
      id: 'txn-6',
      merchant: 'Freelance Design',
      amount: 16500,
      category: TransactionCategory.income,
      date: DateTime(2026, 9, 8),
      type: TransactionType.credit,
    ),
    TransactionModel(
      id: 'txn-7',
      merchant: 'Rent',
      amount: 15000,
      category: TransactionCategory.bills,
      date: DateTime(2026, 9, 9),
      type: TransactionType.debit,
    ),
    TransactionModel(
      id: 'txn-8',
      merchant: 'Spotify',
      amount: 119,
      category: TransactionCategory.entertainment,
      date: DateTime(2026, 9, 10),
      type: TransactionType.debit,
    ),
  ];
}
