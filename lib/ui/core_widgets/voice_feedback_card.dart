import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/providers.dart';
import '../../core/localization/bangla_strings.dart';
import '../../core/theme/colors.dart';

class VoiceFeedbackCard extends ConsumerWidget {
  final String textToRead;
  final String displayMessage;

  const VoiceFeedbackCard({
    super.key,
    required this.textToRead,
    required this.displayMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpeaking = ref.watch(ttsControllerProvider);
    final textScale = ref.watch(textSizeMultiplierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSpeaking ? AppColors.success : (isDark ? Colors.white10 : Colors.green.withOpacity(0.2)),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSpeaking ? AppColors.success.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: isSpeaking ? 4 : 1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (isSpeaking) {
              ref.read(ttsControllerProvider.notifier).stop();
            } else {
              ref.read(ttsControllerProvider.notifier).speak(textToRead);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Cartoon Mascot avatar with speech pulse
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isSpeaking)
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withOpacity(0.15),
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 800.ms),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSpeaking ? AppColors.success : AppColors.lightSecondary,
                      ),
                      child: Center(
                        child: Text(
                          isSpeaking ? '🗣️' : '👨‍🌾',
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayMessage,
                        style: TextStyle(
                          fontSize: 18 * textScale,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isSpeaking ? BanglaStrings.stopAudio : BanglaStrings.playAudio,
                        style: TextStyle(
                          fontSize: 15 * textScale,
                          fontWeight: FontWeight.w600,
                          color: isSpeaking ? AppColors.success : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                // Audio icon indicator
                Icon(
                  isSpeaking ? Icons.volume_up : Icons.play_circle_filled,
                  size: 40,
                  color: isSpeaking ? AppColors.success : AppColors.lightPrimary,
                )
                    .animate(target: isSpeaking ? 1 : 0)
                    .custom(duration: 500.ms, builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * 0.1),
                    child: child,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
