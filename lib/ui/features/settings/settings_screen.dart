import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/bangla_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/providers.dart';
import '../../core_widgets/primary_button.dart';
import '../../core_widgets/voice_feedback_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final textScale = ref.watch(textSizeMultiplierProvider);
    final autoSpeak = ref.watch(autoSpeakProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final infoSpeech = 'সেটিংস পাতা। এখান থেকে আপনি মোবাইল স্ক্রিনের আলো পরিবর্তন করতে পারেন, অক্ষরের আকার বড় বা ছোট করতে পারেন এবং কথা স্বয়ংক্রিয়ভাবে বলা চালু বা বন্ধ করতে পারেন।';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          BanglaStrings.settingsTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22 * textScale,
            color: isDark ? AppColors.darkTextPrimary : Colors.white,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          onPressed: () {
            ref.read(ttsControllerProvider.notifier).stop();
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Voice Feedback Card
          VoiceFeedbackCard(
            textToRead: infoSpeech,
            displayMessage: 'সেটিংসের সাহায্য অডিওতে শুনুন',
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Dark Mode Switch Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🌓', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 16),
                            Text(
                              BanglaStrings.settingsDarkMode,
                              style: TextStyle(
                                fontSize: 18 * textScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Transform.scale(
                          scale: 1.4,
                          child: Switch(
                            value: themeMode == ThemeMode.dark,
                            activeColor: AppColors.success,
                            onChanged: (value) {
                              ref.read(themeModeProvider.notifier).state =
                                  value ? ThemeMode.dark : ThemeMode.light;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),

                // Large Text Multiplier Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🔎', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 16),
                            Text(
                              BanglaStrings.settingsTextSize,
                              style: TextStyle(
                                fontSize: 18 * textScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Transform.scale(
                          scale: 1.4,
                          child: Switch(
                            value: textScale > 1.0,
                            activeColor: AppColors.success,
                            onChanged: (value) {
                              ref.read(textSizeMultiplierProvider.notifier).state =
                                  value ? 1.25 : 1.0;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Auto Speak Toggle Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('📢', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 16),
                            Text(
                              BanglaStrings.settingsAutoRead,
                              style: TextStyle(
                                fontSize: 18 * textScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Transform.scale(
                          scale: 1.4,
                          child: Switch(
                            value: autoSpeak,
                            activeColor: AppColors.success,
                            onChanged: (value) {
                              ref.read(autoSpeakProvider.notifier).state = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Visual Accessibility Preview Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'অক্ষরের সাইজের নমুনা (Preview)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'কৃষি বন্ধু AI অ্যাপটি চাষী ভাইদের সাহায্যের জন্য তৈরি।',
                        style: TextStyle(
                          fontSize: 18 * textScale,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Save and Go Back Action Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: PrimaryButton(
              text: '💾 সেটিংস সংরক্ষণ করুন',
              backgroundColor: AppColors.success,
              onPressed: () {
                ref.read(ttsControllerProvider.notifier).stop();
                context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
