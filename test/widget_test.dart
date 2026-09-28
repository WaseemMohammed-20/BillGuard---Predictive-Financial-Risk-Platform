import 'package:billguard/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BillGuard app loads its onboarding screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BillGuardApp()));

    expect(find.text('BILLGUARD'), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
