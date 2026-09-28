String formatRupees(num amount) {
  if (!amount.isFinite) return '₹0';
  final rounded = amount.round();
  final negative = rounded < 0;
  final digits = rounded.abs().toString();
  if (digits.length <= 3) return '${negative ? '-' : ''}₹$digits';

  final lastThree = digits.substring(digits.length - 3);
  var prefix = digits.substring(0, digits.length - 3);
  final groups = <String>[lastThree];
  while (prefix.length > 2) {
    groups.insert(0, prefix.substring(prefix.length - 2));
    prefix = prefix.substring(0, prefix.length - 2);
  }
  if (prefix.isNotEmpty) groups.insert(0, prefix);
  return '${negative ? '-' : ''}₹${groups.join(',')}';
}
