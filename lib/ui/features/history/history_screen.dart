import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/bangla_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/providers.dart';
import '../../../core/services/ai_analysis_service.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final textScale = ref.watch(textSizeMultiplierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          BanglaStrings.welcomeHistoryBtn,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22 * textScale,
            color: isDark ? AppColors.darkTextPrimary : Colors.white,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: history.isEmpty
          ? _buildEmptyState(isDark, textScale)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final report = history[index];
                final formattedDate = '${report.dateTime.day}/${report.dateTime.month}/${report.dateTime.year}';
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Re-populate active states to view details
                      ref.read(capturedImagePathProvider.notifier).state = report.imagePath;
                      ref.read(currentAnalysisResultProvider.notifier).state = CropAnalysisResult(
                        cropName: report.cropName,
                        diseaseName: report.diseaseName,
                        diseaseBanglaName: report.diseaseBanglaName,
                        explanation: report.explanation,
                        severity: report.severity,
                        organicTreatments: report.organicTreatments,
                        chemicalTreatments: report.chemicalTreatments,
                        affectedAreas: const [], // simplified for historical views
                      );
                      context.push('/diagnosis');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Saved Crop image thumbnail
                          Container(
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: File(report.imagePath).existsSync()
                                  ? Image.file(
                                      File(report.imagePath),
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.broken_image, size: 36),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Text Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.cropName,
                                  style: TextStyle(
                                    fontSize: 16 * textScale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  report.diseaseBanglaName,
                                  style: TextStyle(
                                    fontSize: 20 * textScale,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Delete action trigger
                          IconButton(
                            icon: const Icon(Icons.delete_forever, color: AppColors.danger, size: 32),
                            tooltip: BanglaStrings.historyDeleteTooltip,
                            onPressed: () => _confirmDelete(context, ref, report.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(bool isDark, double textScale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('📁', style: TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              BanglaStrings.historyEmpty,
              style: TextStyle(
                fontSize: 20 * textScale,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            BanglaStrings.historyDeleteConfirm,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                BanglaStrings.noBtn,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 48),
              ),
              onPressed: () {
                ref.read(historyProvider.notifier).deleteReport(id);
                Navigator.of(context).pop();
              },
              child: const Text(
                BanglaStrings.yesBtn,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
