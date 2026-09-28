import 'package:billguard/core/constants/mock_data.dart';
import 'package:billguard/features/timeline/providers/timeline_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('timeline events are sorted and use the shared financial dataset', () {
    final container = ProviderContainer(
      overrides: [
        timelineReferenceDateProvider.overrideWithValue(DateTime(2026, 9, 28)),
      ],
    );
    final events = container.read(timelineEventsProvider);

    expect(events, isNotEmpty);
    expect(events.first.date.isBefore(events.last.date), isTrue);
    expect(events.every((event) => event.title.isNotEmpty), isTrue);
    expect(events.length, 8);
    expect(events.last.projectedBalanceAfter, -1442);
    expect(
      events.any(
        (event) => event.projectedBalanceAfter < MockData.snapshot.safetyBuffer,
      ),
      isTrue,
    );
  });
}
