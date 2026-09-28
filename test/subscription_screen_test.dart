import 'package:billguard/features/subscriptions/presentation/subscriptions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'subscription intelligence renders summary and renewal insights without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SubscriptionsScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('SUBSCRIPTION INTELLIGENCE'), findsOneWidget);
      expect(find.text('₹4,742'), findsWidgets);
      expect(find.text('₹56,904'), findsOneWidget);
      expect(find.text('Adobe Creative Cloud'), findsWidgets);
      expect(find.text('INSIGHTS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
