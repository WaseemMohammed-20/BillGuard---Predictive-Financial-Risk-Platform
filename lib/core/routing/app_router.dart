import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/collision/presentation/collision_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/simulator/presentation/simulator_screen.dart';
import '../../features/subscriptions/presentation/subscriptions_screen.dart';
import '../../features/timeline/presentation/timeline_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/timeline',
        builder: (context, state) => const TimelineScreen(),
      ),
      GoRoute(
        path: '/collision',
        builder: (context, state) => const CollisionScreen(),
      ),
      GoRoute(
        path: '/simulator',
        builder: (context, state) => const SimulatorScreen(),
      ),
      GoRoute(
        path: '/subscriptions',
        builder: (context, state) => const SubscriptionsScreen(),
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) => AppRouter.router);
