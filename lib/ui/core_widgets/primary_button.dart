import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/providers.dart';

class PrimaryButton extends ConsumerWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textScale = ref.watch(textSizeMultiplierProvider);
    final theme = Theme.of(context);

    final bg = backgroundColor ?? theme.elevatedButtonTheme.style?.backgroundColor?.resolve({}) ?? theme.primaryColor;
    final fg = foregroundColor ?? theme.elevatedButtonTheme.style?.foregroundColor?.resolve({}) ?? Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 6,
          minimumSize: const Size(double.infinity, 76), // Extremely large touch target
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.black.withOpacity(0.08), width: 1.5),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 30 * textScale),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 22 * textScale,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
