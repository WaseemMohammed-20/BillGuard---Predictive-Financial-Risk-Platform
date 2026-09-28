import 'package:billguard/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BillGuard app opens on the dashboard at the root route', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BillGuardApp()));
    await tester.pumpAndSettle();

    expect(find.text('BILLGUARD'), findsWidgets);
    expect(find.text('FINANCIAL HEALTH'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);
  });
}
