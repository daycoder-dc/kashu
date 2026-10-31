import 'package:flutter/material.dart';

class PinDotIndicator extends StatelessWidget {
  final int pinLength;
  final int filledCount;
  final bool hasError;

  const PinDotIndicator({
    super.key,
    required this.pinLength,
    required this.filledCount,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filledColor =
        hasError ? colorScheme.error : colorScheme.primary;
    final emptyColor = colorScheme.outlineVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pinLength, (index) {
        final isFilled = index < filledCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: isFilled ? 16 : 14,
          height: isFilled ? 16 : 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? filledColor : Colors.transparent,
            border: Border.all(
              color: isFilled ? filledColor : emptyColor,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}
