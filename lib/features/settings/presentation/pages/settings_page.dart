import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/di/injection.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import 'credits_page.dart';
import 'db_maintenance_page.dart';
import 'terms_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsCubit _cubit;
  final _budgetController = TextEditingController();
  bool _budgetLoaded = false;

  @override
  void initState() {
    super.initState();
    _cubit = sl<SettingsCubit>();
    if (_cubit.state is! SettingsLoaded) {
      _cubit.loadSettings();
    }
    final now = DateTime.now();
    _cubit.loadBudget(now.month, now.year);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracion'),
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        bloc: _cubit,
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is SettingsLoaded && !_budgetLoaded) {
            if (state.budgetAmount != null) {
              _budgetController.text =
                  state.budgetAmount!.toStringAsFixed(0);
            }
            _budgetLoaded = true;
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! SettingsLoaded) {
            return const SizedBox.shrink();
          }
          final settings = state.settings;

          return ListView(
            children: [
              const SizedBox(height: 8),
              _SectionHeader(title: 'General', theme: theme),
              ListTile(
                leading: Icon(PhosphorIconsLight.currencyDollar),
                title: const Text('Moneda'),
                subtitle: Text(settings.currencyCode),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showCurrencyPicker(settings.currencyCode),
              ),
              ListTile(
                leading: Icon(PhosphorIconsLight.palette),
                title: const Text('Tema'),
                subtitle: Text(_themeModeLabel(settings.themeMode)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showThemePicker(settings.themeMode),
              ),
              const Divider(height: 32),
              _SectionHeader(title: 'Presupuesto mensual', theme: theme),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _budgetController,
                        decoration: const InputDecoration(
                          labelText: 'Monto del presupuesto',
                          prefixIcon: Icon(PhosphorIconsLight.piggyBank),
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _saveBudget,
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Aplica para el mes actual. Puedes cambiarlo en cualquier momento.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Divider(height: 32),
              _SectionHeader(title: 'Seguridad', theme: theme),
              ListTile(
                leading: Icon(PhosphorIconsLight.lock),
                title: const Text('Cambiar PIN'),
                subtitle: const Text('Actualiza tu PIN de acceso'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.pushNamed('pinChange'),
              ),
              const Divider(height: 32),
              _SectionHeader(title: 'Datos', theme: theme),
              ListTile(
                leading: Icon(PhosphorIconsLight.database),
                title: const Text('Mantenimiento de datos'),
                subtitle: const Text('Copia de seguridad y optimizacion'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DbMaintenancePage()),
                ),
              ),
              const Divider(height: 32),
              _SectionHeader(title: 'Acerca de', theme: theme),
              ListTile(
                leading: Icon(PhosphorIconsLight.info),
                title: const Text(appName),
                subtitle: Text('v$appVersion · Finanzas personales offline'),
              ),
              ListTile(
                leading: Icon(PhosphorIconsLight.users),
                title: const Text('Creditos'),
                subtitle: const Text('Quienes hicieron esta app'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CreditsPage()),
                ),
              ),
              ListTile(
                leading: Icon(PhosphorIconsLight.shieldCheck),
                title: const Text('Privacidad y datos'),
                subtitle: const Text('Como se manejan tus datos'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TermsPage()),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showCurrencyPicker(String current) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final currencies = AppConstants.supportedCurrencies;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Seleccionar moneda',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              RadioGroup<String>(
                groupValue: current,
                onChanged: (val) {
                  if (val == null) return;
                  _cubit.updateCurrency(val);
                  Navigator.of(ctx).pop();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: currencies.entries.map((e) {
                    final config = e.value;
                    return RadioListTile<String>(
                      value: config.code,
                      title: Text('${config.code} (${config.symbol})'),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showThemePicker(ThemeMode current) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Seleccionar tema',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              RadioGroup<ThemeMode>(
                groupValue: current,
                onChanged: (val) {
                  if (val == null) return;
                  _cubit.updateThemeMode(val);
                  Navigator.of(ctx).pop();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      title: const Text('Sistema'),
                      subtitle: const Text('Sigue el tema del dispositivo'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      title: const Text('Claro'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      title: const Text('Oscuro'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _saveBudget() {
    final text = _budgetController.text.trim();
    if (text.isEmpty) return;
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto valido')),
      );
      return;
    }
    final now = DateTime.now();
    _cubit.setBudget(now.month, now.year, amount);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Presupuesto guardado')),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Oscuro',
      _ => 'Sistema',
    };
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
