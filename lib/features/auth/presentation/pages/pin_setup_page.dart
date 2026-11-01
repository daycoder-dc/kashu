import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/pin_dot_indicator.dart';
import '../widgets/pin_keyboard.dart';

enum _SetupStep { create, confirm }

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

  String get _title {
    if (widget.isChange && _step == _SetupStep.create) {
      return 'Nuevo PIN';
    }
    return switch (_step) {
      _SetupStep.create => 'Crea tu PIN',
      _SetupStep.confirm => 'Confirma tu PIN',
    };
  }

  String get _subtitle {
    if (_errorMessage != null) return _errorMessage!;
    return switch (_step) {
      _SetupStep.create => 'Ingresa un PIN de $_pinLength digitos',
      _SetupStep.confirm => 'Ingresa el mismo PIN nuevamente',
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
        context.read<AuthCubit>().setupPin(_firstPin);
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
          child: Column(
            children: [
              Spacer(flex: widget.isChange ? 1 : 2),
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
