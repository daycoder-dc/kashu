import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_notifier.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/lock_screen_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/pin_setup_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/fixed_expenses/presentation/pages/fixed_expenses_page.dart';
import '../../features/debts/presentation/pages/debt_detail_page.dart';
import '../../features/debts/presentation/pages/debts_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../features/transactions/presentation/pages/transaction_list_page.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final _authNotifier = AuthNotifier(sl<AuthCubit>());

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: _authRedirect,
    refreshListenable: _authNotifier,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/lock',
        name: 'lock',
        builder: (context, state) => const LockScreenPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => OnboardingPage(
          onComplete: () => sl<AuthCubit>().completeOnboarding(),
        ),
      ),
      GoRoute(
        path: '/pin-setup',
        name: 'pinSetup',
        builder: (context, state) => const PinSetupPage(),
      ),
      GoRoute(
        path: '/pin-change',
        name: 'pinChange',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _fadePage(state, const PinSetupPage(isChange: true)),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/transactions',
              name: 'transactions',
              builder: (context, state) => const TransactionListPage(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'addTransaction',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final existing = state.extra as TransactionEntity?;
                    return _fadePage(
                        state, AddTransactionPage(existing: existing));
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/fixed-expenses',
              name: 'fixedExpenses',
              builder: (context, state) => const FixedExpensesPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/debts',
              name: 'debts',
              builder: (context, state) => const DebtsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'debtDetail',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return _fadePage(state, DebtDetailPage(debtId: id));
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/statistics',
              name: 'statistics',
              builder: (context, state) => const StatisticsPage(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadePage(state, const SettingsPage()),
      ),
    ],
  );

  static CustomTransitionPage<void> _fadePage(
      GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static String? _authRedirect(BuildContext context, GoRouterState state) {
    final authCubit = sl<AuthCubit>();
    final authState = authCubit.state;
    final currentPath = state.matchedLocation;

    final isOnAuthPage = currentPath == '/splash' ||
        currentPath == '/lock' ||
        currentPath == '/pin-setup' ||
        currentPath == '/onboarding';

    if (authState is AuthAuthenticated) {
      if (isOnAuthPage) return '/dashboard';
      return null;
    }

    if (authState is AuthOnboarding) {
      if (currentPath != '/onboarding') return '/onboarding';
      return null;
    }

    if (authState is AuthPinSetupRequired) {
      if (currentPath != '/pin-setup') return '/pin-setup';
      return null;
    }

    if (authState is AuthLocked ||
        authState is AuthPinError ||
        authState is AuthPinVerifying) {
      if (currentPath != '/lock') return '/lock';
      return null;
    }

    return null;
  }
}
