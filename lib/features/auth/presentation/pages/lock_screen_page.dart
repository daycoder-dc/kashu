import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/pin_dot_indicator.dart';
import '../widgets/pin_keyboard.dart';

class LockScreenPage extends StatefulWidget {
  const LockScreenPage({super.key});

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  static const _pinLength = 4;
  String _enteredPin = '';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthLocked && authState.biometricAvailable) {
        context.read<AuthCubit>().authenticateWithBiometrics();
      }
    });
  }

  void _onDigit(String digit) {
    if (_enteredPin.length >= _pinLength) return;

    setState(() {
      _hasError = false;
      _enteredPin += digit;
    });

    if (_enteredPin.length == _pinLength) {
      _submitPin();
    }
  }

  void _onDelete() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _hasError = false;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  void _submitPin() {
    context.read<AuthCubit>().authenticateWithPin(_enteredPin);
  }

  void _onBiometric() {
    context.read<AuthCubit>().authenticateWithBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPinError) {
          setState(() {
            _hasError = true;
            _enteredPin = '';
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),
              Icon(
                Icons.lock_rounded,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Kashu',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final message = state is AuthPinError
                      ? state.message
                      : 'Ingresa tu PIN';
                  final isError = state is AuthPinError;
                  return Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isError
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                  );
                },
              ),
              const SizedBox(height: 32),
              PinDotIndicator(
                pinLength: _pinLength,
                filledCount: _enteredPin.length,
                hasError: _hasError,
              ),
              const Spacer(flex: 1),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final showBiometric = state is AuthLocked
                      ? state.biometricAvailable
                      : state is AuthPinError
                          ? state.biometricAvailable
                          : false;
                  return PinKeyboard(
                    onDigitPressed: _onDigit,
                    onDeletePressed: _onDelete,
                    showBiometric: showBiometric,
                    onBiometricPressed: _onBiometric,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
