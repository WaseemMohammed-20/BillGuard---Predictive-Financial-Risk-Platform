import 'dart:math' as math;

import '../../models/subscription.dart';

DateTime nextBillingOccurrence({
  required DateTime anchorDate,
  required BillingCycle cycle,
  required DateTime onOrAfter,
}) {
  final anchor = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);
  final target = DateTime(onOrAfter.year, onOrAfter.month, onOrAfter.day);

  if (cycle == BillingCycle.monthly) {
    var monthOffset = math.max(
      0,
      (target.year - anchor.year) * 12 + target.month - anchor.month,
    );
    var candidate = _monthlyDate(anchor, monthOffset);
    if (candidate.isBefore(target)) {
      monthOffset++;
      candidate = _monthlyDate(anchor, monthOffset);
    }
    return candidate;
  }

  var yearOffset = math.max(0, target.year - anchor.year);
  var candidate = _yearlyDate(anchor, yearOffset);
  if (candidate.isBefore(target)) {
    yearOffset++;
    candidate = _yearlyDate(anchor, yearOffset);
  }
  return candidate;
}

DateTime _monthlyDate(DateTime anchor, int monthOffset) {
  final absoluteMonth = anchor.year * 12 + anchor.month - 1 + monthOffset;
  final year = absoluteMonth ~/ 12;
  final month = absoluteMonth % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, math.min(anchor.day, lastDay));
}

DateTime _yearlyDate(DateTime anchor, int yearOffset) {
  final year = anchor.year + yearOffset;
  final lastDay = DateTime(year, anchor.month + 1, 0).day;
  return DateTime(year, anchor.month, math.min(anchor.day, lastDay));
}
