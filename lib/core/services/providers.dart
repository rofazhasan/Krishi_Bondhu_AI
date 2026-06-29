import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/crop_report.dart';
import '../../data/repositories/crop_repository_impl.dart';
import 'tts_service.dart';
import 'ai_analysis_service.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Accessibility settings: Large text multiplier
final textSizeMultiplierProvider = StateProvider<double>((ref) => 1.0);

// Auto speak settings (default to true for illiterate users)
final autoSpeakProvider = StateProvider<bool>((ref) => true);

// Crop repository provider
final cropRepositoryProvider = Provider((ref) => CropRepositoryImpl());

// Saved history list notifier
class HistoryNotifier extends StateNotifier<List<CropReport>> {
  final CropRepositoryImpl _repository;

  HistoryNotifier(this._repository) : super([]) {
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      final list = await _repository.getSavedReports();
      state = list;
    } catch (e) {
      debugPrint('Error loading reports: $e');
    }
  }

  Future<void> addReport(CropReport report) async {
    try {
      await _repository.saveReport(report);
      await loadReports();
    } catch (e) {
      debugPrint('Error saving report: $e');
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _repository.deleteReport(id);
      await loadReports();
    } catch (e) {
      debugPrint('Error deleting report: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAllReports();
      state = [];
    } catch (e) {
      debugPrint('Error clearing reports: $e');
    }
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<CropReport>>((ref) {
  final repo = ref.watch(cropRepositoryProvider);
  return HistoryNotifier(repo);
});

// Currently analyzed image path
final capturedImagePathProvider = StateProvider<String?>((ref) => null);

// Current AI analysis results
final currentAnalysisResultProvider = StateProvider<CropAnalysisResult?>((ref) => null);

// TTS controller state wrapper
class TtsController extends StateNotifier<bool> {
  final TtsService _ttsService = TtsService.instance;

  TtsController() : super(false) {
    _ttsService.addListener(_onTtsChange);
  }

  void _onTtsChange() {
    state = _ttsService.isSpeaking;
  }

  Future<void> speak(String text) async {
    await _ttsService.speak(text);
  }

  Future<void> stop() async {
    await _ttsService.stop();
  }

  @override
  void dispose() {
    _ttsService.removeListener(_onTtsChange);
    super.dispose();
  }
}

final ttsControllerProvider = StateNotifierProvider<TtsController, bool>((ref) {
  return TtsController();
});
