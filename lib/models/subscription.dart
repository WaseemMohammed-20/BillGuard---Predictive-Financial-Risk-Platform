enum BillingCycle { monthly, yearly }

class SubscriptionModel {
  const SubscriptionModel({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.billingCycle,
    required this.nextBillingDate,
  });

  final String id;
  final String merchant;
  final double amount;
  final BillingCycle billingCycle;
  final DateTime nextBillingDate;
}
