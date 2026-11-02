import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/pin_dot_indicator.dart';
import '../widgets/pin_keyboard.dart';

enum _SetupStep { create, confirm, biometric }

class PinSetupPage extends StatefulWidget {
  final bool isChange;

  const PinSetupPage({super.key, this.isChange = false});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  static const _pinLength = 4;
  _SetupStep _step = _SetupStep.create;
  String _enteredPin = '';
  String _firstPin = '';
  String? _errorMessage;
  bool _biometricEnabled = true;

  String get _title {
    if (widget.isChange && _step == _SetupStep.create) {
      return 'Nuevo PIN';
    }
    return switch (_step) {
      _SetupStep.create => 'Crea tu PIN',
      _SetupStep.confirm => 'Confirma tu PIN',
      _SetupStep.biometric => 'Huella digital',
    };
  }

  String get _subtitle {
    if (_errorMessage != null) return _errorMessage!;
    return switch (_step) {
      _SetupStep.create => 'Ingresa un PIN de $_pinLength digitos',
      _SetupStep.confirm => 'Ingresa el mismo PIN nuevamente',
      _SetupStep.biometric => 'Desbloquea la app con tu huella',
    };
  }

  void _onDigit(String digit) {
    if (_enteredPin.length >= _pinLength) return;

    setState(() {
      _errorMessage = null;
      _enteredPin += digit;
    });

    if (_enteredPin.length == _pinLength) {
      _handlePinComplete();
    }
  }

  void _onDelete() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  void _handlePinComplete() {
    if (_step == _SetupStep.create) {
      setState(() {
        _firstPin = _enteredPin;
        _enteredPin = '';
        _step = _SetupStep.confirm;
      });
    } else {
      if (_enteredPin == _firstPin) {
        final authCubit = context.read<AuthCubit>();
        if (!widget.isChange && authCubit.biometricAvailable) {
          setState(() => _step = _SetupStep.biometric);
        } else {
          authCubit.setupPin(_firstPin);
        }
      } else {
        setState(() {
          _errorMessage = 'Los PIN no coinciden';
          _enteredPin = '';
          _step = _SetupStep.create;
          _firstPin = '';
        });
      }
    }
  }

  void _finishSetup() {
    final authCubit = context.read<AuthCubit>();
    authCubit.setBiometricEnabled(_biometricEnabled);
    authCubit.setupPin(_firstPin);
  }

  Widget _buildBiometricStep(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Icon(
            Icons.fingerprint_rounded,
            size: 64,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            _title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 48),
          SwitchListTile(
            title: const Text('Usar huella digital'),
            subtitle: const Text('Desbloquea la app sin ingresar el PIN'),
            value: _biometricEnabled,
            onChanged: (v) => setState(() => _biometricEnabled = v),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _finishSetup,
              child: const Text('Continuar'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = _errorMessage != null;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          setState(() => _errorMessage = state.message);
        } else if (state is AuthAuthenticated && widget.isChange) {
          if (context.mounted) {
            final nav = Navigator.of(context, rootNavigator: true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN actualizado')),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              nav.pop();
            });
          }
        }
      },
      child: Scaffold(
        appBar: widget.isChange
            ? AppBar(
                title: const Text('Cambiar PIN'),
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
              )
            : null,
        body: SafeArea(
          child: _step == _SetupStep.biometric
              ? _buildBiometricStep(colorScheme)
              : Column(
                  children: [
                    const Spacer(flex: 1),
                    Icon(
                      _step == _SetupStep.create
                          ? Icons.pin_rounded
                          : Icons.verified_rounded,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: hasError
                                ? colorScheme.error
                                : colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    PinDotIndicator(
                      pinLength: _pinLength,
                      filledCount: _enteredPin.length,
                      hasError: hasError,
                    ),
                    const Spacer(flex: 1),
                    PinKeyboard(
                      onDigitPressed: _onDigit,
                      onDeletePressed: _onDelete,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
        ),
      ),
    );
  }
}
