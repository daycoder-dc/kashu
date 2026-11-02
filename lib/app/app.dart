import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import '../features/settings/presentation/cubit/settings_state.dart';
import 'router/app_router.dart';

class KashuApp extends StatefulWidget {
  const KashuApp({super.key});

  static bool suppressLock = false;

  @override
  State<KashuApp> createState() => _KashuAppState();
}

class _KashuAppState extends State<KashuApp> with WidgetsBindingObserver {
  final _authCubit = sl<AuthCubit>();
  final _settingsCubit = sl<SettingsCubit>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authCubit.checkAuthStatus();
    _settingsCubit.loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (KashuApp.suppressLock) return;
    if (state == AppLifecycleState.paused) {
      _authCubit.lock();
    }
    if (state == AppLifecycleState.resumed) {
      final authState = _authCubit.state;
      if (authState is! AuthAuthenticated) {
        AppRouter.router.go('/lock');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _settingsCubit),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        bloc: _settingsCubit,
        buildWhen: (prev, curr) {
          if (prev is SettingsLoaded && curr is SettingsLoaded) {
            return prev.settings.themeMode != curr.settings.themeMode;
          }
          return curr is SettingsLoaded;
        },
        builder: (context, state) {
          final themeMode = state is SettingsLoaded
              ? state.settings.themeMode
              : ThemeMode.system;

          return MaterialApp.router(
            title: 'Kashu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
