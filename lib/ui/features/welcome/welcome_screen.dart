import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/bangla_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/providers.dart';
import '../../core_widgets/primary_button.dart';
import '../../core_widgets/voice_feedback_card.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Auto speak welcome greeting on launch if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final autoSpeak = ref.read(autoSpeakProvider);
      if (autoSpeak) {
        ref.read(ttsControllerProvider.notifier).speak(BanglaStrings.welcomeGreeting);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textScale = ref.watch(textSizeMultiplierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          BanglaStrings.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24 * textScale,
            color: isDark ? AppColors.darkTextPrimary : Colors.white,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 30, color: Colors.white),
            onPressed: () {
              ref.read(ttsControllerProvider.notifier).stop();
              context.push('/settings');
            },
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Spoken instruction guide card
            const VoiceFeedbackCard(
              textToRead: BanglaStrings.welcomeGreeting,
              displayMessage: BanglaStrings.welcomeGreeting,
            ),
            const SizedBox(height: 16),
            
            // Friendly cartoon farmer mascot
            Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.green.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  width: 3,
                ),
              ),
              child: const Center(
                child: Text(
                  '👨‍🌾',
                  style: TextStyle(fontSize: 100),
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            Text(
              BanglaStrings.welcomeSubtitle,
              style: TextStyle(
                fontSize: 22 * textScale,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightPrimary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Core Action Buttons list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  PrimaryButton(
                    text: BanglaStrings.welcomeActionBtn,
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      ref.read(ttsControllerProvider.notifier).stop();
                      context.push('/camera');
                    },
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: BanglaStrings.welcomeHistoryBtn,
                    backgroundColor: AppColors.lightSecondary,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      ref.read(ttsControllerProvider.notifier).stop();
                      context.push('/history');
                    },
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: BanglaStrings.welcomeLearnBtn,
                    backgroundColor: Colors.teal[800],
                    foregroundColor: Colors.white,
                    onPressed: () {
                      ref.read(ttsControllerProvider.notifier).stop();
                      context.push('/learning');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
