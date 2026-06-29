import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/localization/bangla_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/providers.dart';
import '../../../domain/models/crop_report.dart';
import '../../core_widgets/primary_button.dart';
import '../../core_widgets/voice_feedback_card.dart';
import '../../core_widgets/severity_badge.dart';

class DiagnosisScreen extends ConsumerStatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  ConsumerState<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends ConsumerState<DiagnosisScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    // Auto speak the diagnosis explanation on screen launch if configured
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final results = ref.read(currentAnalysisResultProvider);
      final autoSpeak = ref.read(autoSpeakProvider);
      if (results != null && autoSpeak) {
        final speakText = '${results.cropName} এর রোগ সনাক্ত করা হয়েছে। রোগের নাম: ${results.diseaseBanglaName}। তীব্রতা: ${results.severity}। ${results.explanation} প্রতিকার দেখতে সবুজ বোতাম চাপুন।';
        ref.read(ttsControllerProvider.notifier).speak(speakText);
      }
    });
  }

  Future<void> _saveReportToDb() async {
    final results = ref.read(currentAnalysisResultProvider);
    final imagePath = ref.read(capturedImagePathProvider);
    
    if (results == null || imagePath == null) return;

    final newReport = CropReport(
      id: const Uuid().v4(),
      cropName: results.cropName,
      diseaseName: results.diseaseName,
      diseaseBanglaName: results.diseaseBanglaName,
      explanation: results.explanation,
      severity: results.severity,
      imagePath: imagePath,
      dateTime: DateTime.now(),
      organicTreatments: results.organicTreatments,
      chemicalTreatments: results.chemicalTreatments,
    );

    await ref.read(historyProvider.notifier).addReport(newReport);

    if (!mounted) return;

    setState(() {
      _isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          BanglaStrings.diagnosisSaveSuccess,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(currentAnalysisResultProvider);
    final imagePath = ref.watch(capturedImagePathProvider);
    final textScale = ref.watch(textSizeMultiplierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (results == null || imagePath == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final speechContent = '${results.cropName} এর রোগ সনাক্ত করা হয়েছে। রোগের নাম: ${results.diseaseBanglaName}। তীব্রতা: ${results.severity}। ${results.explanation} প্রতিকার দেখতে সবুজ বোতাম চাপুন।';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          BanglaStrings.diagnosisTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22 * textScale,
            color: isDark ? AppColors.darkTextPrimary : Colors.white,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightPrimary,
        leading: IconButton(
          icon: const Icon(Icons.home, size: 30, color: Colors.white),
          onPressed: () {
            ref.read(ttsControllerProvider.notifier).stop();
            context.go('/');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Voice Feedback Card
            VoiceFeedbackCard(
              textToRead: speechContent,
              displayMessage: '${results.cropName} এর রোগ সনাক্ত করা হয়েছে। কথা শুনতে ট্যাপ করুন।',
            ),

            // Image Preview with Highlighted Affected Areas (OpenCV coordinates mapping overlay)
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                    
                    // Contours overlay: Draw red pulsing warning rings on coordinates returned from AI Service
                    ...results.affectedAreas.map((Point<double> point) {
                      return Positioned(
                        left: point.x * 280, // rough offset mapping for container size
                        top: point.y * 280,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.redAccent, width: 3),
                            color: Colors.red.withOpacity(0.15),
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3), duration: 800.ms)
                            .fadeIn(duration: 400.ms),
                      );
                    }),
                    
                    // Warning overlay caption
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.center_focus_weak, color: Colors.redAccent, size: 20),
                            SizedBox(width: 6),
                            Text(
                              BanglaStrings.diagnosisAffectedArea,
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Severity Badge Container
            Center(
              child: SeverityBadge(severityText: results.severity),
            ),

            const SizedBox(height: 16),

            // Diagnostic Bangla explanation Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        results.diseaseBanglaName,
                        style: TextStyle(
                          fontSize: 24 * textScale,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightPrimary,
                        ),
                      ),
                      const Divider(height: 24),
                      Text(
                        BanglaStrings.diagnosisExplanationHeader,
                        style: TextStyle(
                          fontSize: 16 * textScale,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        results.explanation,
                        style: TextStyle(
                          fontSize: 18 * textScale,
                          height: 1.5,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Panel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // View treatments/medicines screen
                  PrimaryButton(
                    text: '👉 সমাধান ও ওষুধ দেখুন',
                    icon: Icons.healing,
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      ref.read(ttsControllerProvider.notifier).stop();
                      context.push('/medicine');
                    },
                  ),
                  const SizedBox(height: 10),
                  
                  // Save Report Button
                  if (!_isSaved)
                    PrimaryButton(
                      text: BanglaStrings.diagnosisSaveBtn,
                      icon: Icons.save,
                      backgroundColor: AppColors.lightSecondary,
                      foregroundColor: Colors.white,
                      onPressed: _saveReportToDb,
                    )
                  else
                    Container(
                      height: 76,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey, width: 1.5),
                      ),
                      child: Text(
                        '✓ সংরক্ষিত করা হয়েছে',
                        style: TextStyle(
                          fontSize: 20 * textScale,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
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
