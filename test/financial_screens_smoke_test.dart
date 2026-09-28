import 'package:billguard/features/collision/presentation/collision_screen.dart';
import 'package:billguard/features/dashboard/presentation/dashboard_screen.dart';
import 'package:billguard/features/simulator/presentation/simulator_screen.dart';
import 'package:billguard/features/subscriptions/presentation/subscriptions_screen.dart';
import 'package:billguard/features/timeline/presentation/timeline_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard, timeline, and simulator remain renderable', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final screen in const [
      DashboardScreen(),
      TimelineScreen(),
      CollisionScreen(),
      SimulatorScreen(),
      SubscriptionsScreen(),
    ]) {
      for (final viewport in [const Size(390, 844), const Size(1440, 1000)]) {
        tester.view.physicalSize = viewport;
        await tester.pumpWidget(
          ProviderScope(child: MaterialApp(home: screen)),
        );
        await tester.pumpAndSettle();
        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason: '${screen.runtimeType} overflowed at ${viewport.width}px',
        );
      }
    }
    addTearDown(tester.view.resetPhysicalSize);
  });
}
