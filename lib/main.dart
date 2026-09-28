import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  usePathUrlStrategy();
  runApp(const ProviderScope(child: BillGuardApp()));
}

class BillGuardApp extends ConsumerWidget {
  const BillGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BillGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
