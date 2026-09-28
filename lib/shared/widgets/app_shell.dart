import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.currentIndex});

  final Widget child;
  final int currentIndex;

  static const _tabs = [
    ('/dashboard', 'Home', Icons.home_rounded),
    ('/timeline', 'Timeline', Icons.timeline_rounded),
    ('/simulator', 'What-if', Icons.calculate_rounded),
    ('/subscriptions', 'Subscriptions', Icons.subscriptions_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: AppColors.surface,
          selectedIndex: currentIndex,
          indicatorColor: AppColors.accentSoft,
          surfaceTintColor: Colors.transparent,
          onDestinationSelected: (index) {
            final path = _tabs[index].$1;
            if (context.canPop() && path == '/dashboard') {
              context.go('/dashboard');
              return;
            }
            context.go(path);
          },
          destinations: _tabs
              .map(
                (tab) => NavigationDestination(
                  icon: Icon(
                    tab.$3,
                    color: currentIndex == _tabs.indexOf(tab)
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                  selectedIcon: Icon(tab.$3, color: AppColors.accent),
                  label: tab.$2,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
