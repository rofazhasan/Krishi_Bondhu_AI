import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/bangla_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/providers.dart';
import '../../../core/services/ai_analysis_service.dart';
import '../../core_widgets/primary_button.dart';
import '../../core_widgets/voice_feedback_card.dart';

class MedicineScreen extends ConsumerStatefulWidget {
  const MedicineScreen({super.key});

  @override
  ConsumerState<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends ConsumerState<MedicineScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Auto speak the default tab recommendation (Organic) on launch if configured
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final results = ref.read(currentAnalysisResultProvider);
      final autoSpeak = ref.read(autoSpeakProvider);
      if (results != null && autoSpeak) {
        _speakTabRecommendation(0);
      }
    });

    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        _speakTabRecommendation(_tabController!.index);
      }
    });
  }

  void _speakTabRecommendation(int index) {
    final results = ref.read(currentAnalysisResultProvider);
    if (results == null) return;

    String speakText = '';
    if (index == 0) {
      speakText = 'প্রাকৃতিক উপায়ে সমাধানের পরামর্শ: ';
      for (var t in results.organicTreatments) {
        speakText += '${t.title}। এটি তৈরির নিয়ম: ${t.description}। প্রয়োগের নিয়ম: ${t.dosage}। ';
      }
    } else {
      speakText = 'রাসায়নিক ওষুধের পরামর্শ: ';
      for (var t in results.chemicalTreatments) {
        speakText += '${t.title}। ব্যবহারের নিয়ম: ${t.dosage}। আনুমানিক খরচ ${t.estimatedCost} টাকা। বিশেষ সতর্কতা: ${t.precaution}। ';
      }
    }
    ref.read(ttsControllerProvider.notifier).speak(speakText);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(currentAnalysisResultProvider);
    final textScale = ref.watch(textSizeMultiplierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (results == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          BanglaStrings.treatmentTitle,
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontSize: 20 * textScale, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: BanglaStrings.organicTab, icon: Icon(Icons.nature, size: 26)),
            Tab(text: BanglaStrings.chemicalTab, icon: Icon(Icons.science, size: 26)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Voice Feedback Instruction
          const VoiceFeedbackCard(
            textToRead: 'সমাধান দেখতে উপরে প্রাকৃতিক বা রাসায়নিক বোতাম চাপুন। কথা শুনতে এখানে চাপ দিন।',
            displayMessage: 'প্রতিকার ও ঔষধের তালিকা',
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Organic remedies view
                _buildRemedyList(results.organicTreatments, isDark, textScale, isOrganic: true),
                
                // Chemical remedies view
                _buildRemedyList(results.chemicalTreatments, isDark, textScale, isOrganic: false),
              ],
            ),
          ),
          
          // Main Home Back Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: PrimaryButton(
              text: '🏠 প্রধান পাতায় ফিরে যান',
              backgroundColor: AppColors.lightPrimary,
              foregroundColor: Colors.white,
              onPressed: () {
                ref.read(ttsControllerProvider.notifier).stop();
                context.go('/');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemedyList(List<TreatmentOption> treatments, bool isDark, double textScale, {required bool isOrganic}) {
    if (treatments.isEmpty) {
      return const Center(
        child: Text(
          'কোনো তথ্য পাওয়া যায়নি',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: treatments.length,
      itemBuilder: (context, index) {
        final t = treatments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medicine details row with graphic placeholder
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isOrganic ? AppColors.successBg : AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isOrganic ? AppColors.success : AppColors.danger,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isOrganic ? '🍃' : '🧴',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: TextStyle(
                              fontSize: 22 * textScale,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightPrimary,
                            ),
                          ),
                          if (!isOrganic) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue, width: 1),
                              ),
                              child: Text(
                                '${BanglaStrings.costLabel} ~${t.estimatedCost} ${BanglaStrings.takaSymbol}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                
                // Description block
                Text(
                  isOrganic ? 'তৈরির নিয়ম:' : 'বিবরণ:',
                  style: TextStyle(fontSize: 16 * textScale, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  t.description,
                  style: TextStyle(fontSize: 18 * textScale, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
                const SizedBox(height: 12),

                // Dosage directions
                Text(
                  BanglaStrings.dosageLabel,
                  style: TextStyle(fontSize: 16 * textScale, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  t.dosage,
                  style: TextStyle(fontSize: 18 * textScale, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Precaution details if any
                if (t.precaution.isNotEmpty) ...[
                  Text(
                    BanglaStrings.precautionLabel,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.danger),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withOpacity(0.5), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.gpp_maybe, color: AppColors.danger, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.precaution,
                            style: TextStyle(
                              fontSize: 16 * textScale,
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
