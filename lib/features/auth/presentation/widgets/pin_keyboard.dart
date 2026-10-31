import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinKeyboard extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;

  const PinKeyboard({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
    this.showBiometric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: 12),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: 12),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: 12),
        _buildBottomRow(context),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((d) => _DigitButton(
            digit: d,
            onPressed: () {
              HapticFeedback.lightImpact();
              onDigitPressed(d);
            },
          )).toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showBiometric)
          _ActionButton(
            icon: Icons.fingerprint_rounded,
            onPressed: () {
              HapticFeedback.mediumImpact();
              onBiometricPressed?.call();
            },
          )
        else
          const SizedBox(width: 80, height: 80),
        _DigitButton(
          digit: '0',
          onPressed: () {
            HapticFeedback.lightImpact();
            onDigitPressed('0');
          },
        ),
        _ActionButton(
          icon: Icons.backspace_outlined,
          onPressed: () {
            HapticFeedback.lightImpact();
            onDeletePressed();
          },
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  final String digit;
  final VoidCallback onPressed;

  const _DigitButton({required this.digit, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: Text(
                digit,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(icon, size: 28),
          ),
        ),
      ),
    );
  }
}
