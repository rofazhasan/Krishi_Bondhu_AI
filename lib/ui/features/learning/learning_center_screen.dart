import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/bangla_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/providers.dart';
import '../../../data/datasources/mock_learning_data.dart';
import '../../core_widgets/primary_button.dart';
import '../../core_widgets/voice_feedback_card.dart';

class LearningCenterScreen extends ConsumerWidget {
  const LearningCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textScale = ref.watch(textSizeMultiplierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          BanglaStrings.welcomeLearnBtn,
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
          const VoiceFeedbackCard(
            textToRead: 'চাষাবাদ তথ্য কেন্দ্রে আপনাদের স্বাগতম। বিভিন্ন ফসল যেমন ধান, আলু, টমেটো বা পাট ভালো ফলন পেতে নিচের বিষয়গুলো দেখে নিন। কথা শুনতে ট্যাপ করতে পারেন।',
            displayMessage: 'ফসলের সঠিক যত্ন ও চাষাবাদ পদ্ধতি',
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: mockLearningTopics.length,
              itemBuilder: (context, index) {
                final topic = mockLearningTopics[index];
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ExpansionTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.green.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          topic.iconAsset,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    title: Text(
                      topic.title,
                      style: TextStyle(
                        fontSize: 20 * textScale,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightPrimary,
                      ),
                    ),
                    subtitle: Text(
                      topic.description,
                      style: TextStyle(fontSize: 15 * textScale),
                    ),
                    childrenPadding: const EdgeInsets.all(16),
                    onExpansionChanged: (isExpanded) {
                      if (isExpanded) {
                        // Play the advice aloud when expanded
                        final autoSpeak = ref.read(autoSpeakProvider);
                        if (autoSpeak) {
                          String speechText = '${topic.title}। ';
                          for (int i = 0; i < topic.keyTips.length; i++) {
                            speechText += '${i + 1} নম্বর পরামর্শ: ${topic.keyTips[i]}। ';
                          }
                          ref.read(ttsControllerProvider.notifier).speak(speechText);
                        }
                      } else {
                        ref.read(ttsControllerProvider.notifier).stop();
                      }
                    },
                    children: [
                      // Voice control to listen to instructions
                      ListTile(
                        leading: const Icon(Icons.volume_up, color: AppColors.success, size: 28),
                        title: const Text(
                          'সম্পূর্ণ বিবরণ অডিওতে শুনুন',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onTap: () {
                          String speechText = '${topic.title}। ';
                          for (int i = 0; i < topic.keyTips.length; i++) {
                            speechText += '${i + 1} নম্বর পরামর্শ: ${topic.keyTips[i]}। ';
                          }
                          ref.read(ttsControllerProvider.notifier).speak(speechText);
                        },
                      ),
                      const Divider(height: 16),
                      
                      // Tips details list
                      ...topic.keyTips.map((tip) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(
                                  fontSize: 22 * textScale,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    fontSize: 18 * textScale,
                                    height: 1.4,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: PrimaryButton(
              text: BanglaStrings.backButton,
              backgroundColor: AppColors.lightSecondary,
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
