import 'package:flutter_test/flutter_test.dart';
import 'package:krishi_bondhu_ai/domain/models/crop_report.dart';
import 'package:krishi_bondhu_ai/core/services/ai_analysis_service.dart';
import 'package:krishi_bondhu_ai/core/localization/bangla_strings.dart';

void main() {
  group('Krishi Bondhu AI Model Tests', () {
    test('CropReport serialization and deserialization should match', () {
      final organic = [
        TreatmentOption(
          title: 'মেহগনি ফলের নির্যাস',
          description: 'জৈব তরল স্প্রে',
          dosage: 'সপ্তাহে একবার',
          precaution: 'রোদে ছিটাবেন না',
          estimatedCost: 80,
        )
      ];

      final chemical = [
        TreatmentOption(
          title: 'ডাইথেন এম-৪৫',
          description: 'ছত্রাকনাশক পাউডার',
          dosage: '১০ লিটারে ২০ গ্রাম',
          precaution: 'গ্লাভস ব্যবহার করুন',
          estimatedCost: 280,
        )
      ];

      final originalReport = CropReport(
        id: 'test-uuid-1234',
        cropName: 'আলু',
        diseaseName: 'Late Blight',
        diseaseBanglaName: 'আলুর মড়ক রোগ',
        explanation: 'সহজ কথায় আলু গাছ পচে যাওয়া।',
        severity: 'গুরুতর (লাল সতর্কতা)',
        imagePath: '/path/to/image.jpg',
        dateTime: DateTime(2026, 6, 29, 12, 0, 0),
        organicTreatments: organic,
        chemicalTreatments: chemical,
      );

      final dbMap = originalReport.toMap();
      final restoredReport = CropReport.fromMap(dbMap);

      expect(restoredReport.id, equals(originalReport.id));
      expect(restoredReport.cropName, equals(originalReport.cropName));
      expect(restoredReport.diseaseBanglaName, equals(originalReport.diseaseBanglaName));
      expect(restoredReport.explanation, equals(originalReport.explanation));
      expect(restoredReport.severity, equals(originalReport.severity));
      expect(restoredReport.imagePath, equals(originalReport.imagePath));
      expect(restoredReport.dateTime, equals(originalReport.dateTime));
      
      expect(restoredReport.organicTreatments.length, equals(1));
      expect(restoredReport.organicTreatments.first.title, equals('মেহগনি ফলের নির্যাস'));
      expect(restoredReport.organicTreatments.first.estimatedCost, equals(80));

      expect(restoredReport.chemicalTreatments.length, equals(1));
      expect(restoredReport.chemicalTreatments.first.title, equals('ডাইথেন এম-৪৫'));
      expect(restoredReport.chemicalTreatments.first.estimatedCost, equals(280));
    });

    test('BanglaStrings constants check', () {
      expect(BanglaStrings.welcomeTitle, equals('কৃষি বন্ধু AI'));
      expect(BanglaStrings.takaSymbol, equals('টাকা'));
    });
  });
}
