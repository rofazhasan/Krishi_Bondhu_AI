import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/bangla_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/providers.dart';
import '../../../core/services/ai_analysis_service.dart';
import '../../core_widgets/voice_feedback_card.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  int _analysisStep = 0;
  String _currentMessage = BanglaStrings.analysisStep1;

  @override
  void initState() {
    super.initState();
    _startAnalysisWorkflow();
  }

  Future<void> _startAnalysisWorkflow() async {
    final imagePath = ref.read(capturedImagePathProvider);
    if (imagePath == null) {
      context.go('/');
      return;
    }

    // Step 1 updates
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _analysisStep = 1;
      _currentMessage = BanglaStrings.analysisStep2;
    });

    // Step 2 updates
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _analysisStep = 2;
      _currentMessage = BanglaStrings.analysisStep3;
    });

    // Step 3 trigger analysis service call
    try {
      final results = await AiAnalysisService.instance.analyzeCropImage(imagePath);
      
      if (!mounted) return;
      ref.read(currentAnalysisResultProvider.notifier).state = results;
      
      setState(() {
        _analysisStep = 3;
        _currentMessage = BanglaStrings.analysisComplete;
      });

      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      context.pushReplacement('/diagnosis');
    } catch (e) {
      debugPrint('Analysis error: $e');
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = ref.watch(capturedImagePathProvider);
    final textScale = ref.watch(textSizeMultiplierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          BanglaStrings.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22 * textScale,
            color: isDark ? AppColors.darkTextPrimary : Colors.white,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightPrimary,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const VoiceFeedbackCard(
            textToRead: 'কৃষি বন্ধু আপনার ফসল পরীক্ষা করছে। কিছুক্ষণ অপেক্ষা করুন।',
            displayMessage: BanglaStrings.analysisScanning,
          ),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 3,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imagePath != null)
                      Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      ),
                    
                    // Scanning laser light simulation using flutter_animate
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.success.withOpacity(0.0),
                              AppColors.success.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45, 0.5, 0.55],
                          ),
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .align(
                            begin: const Alignment(0, -1.2),
                            end: const Alignment(0, 1.2),
                            duration: 1800.ms,
                            curve: Curves.easeInOut,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Steps container panel
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Circular loader animation
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: AppColors.success,
                      strokeWidth: 5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Current running step copy
                  Text(
                    _currentMessage,
                    style: TextStyle(
                      fontSize: 22 * textScale,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Progress dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = index <= _analysisStep;
                      return Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? AppColors.success : Colors.grey[400],
                        ),
                      )
                          .animate(target: isActive ? 1.0 : 0.0)
                          .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 200.ms);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
