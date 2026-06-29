import 'dart:convert';
import '../../core/services/ai_analysis_service.dart';

class CropReport {
  final String id;
  final String cropName;
  final String diseaseName;
  final String diseaseBanglaName;
  final String explanation;
  final String severity;
  final String imagePath;
  final DateTime dateTime;
  final List<TreatmentOption> organicTreatments;
  final List<TreatmentOption> chemicalTreatments;

  CropReport({
    required this.id,
    required this.cropName,
    required this.diseaseName,
    required this.diseaseBanglaName,
    required this.explanation,
    required this.severity,
    required this.imagePath,
    required this.dateTime,
    required this.organicTreatments,
    required this.chemicalTreatments,
  });

  // DB serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropName': cropName,
      'diseaseName': diseaseName,
      'diseaseBanglaName': diseaseBanglaName,
      'explanation': explanation,
      'severity': severity,
      'imagePath': imagePath,
      'dateTime': dateTime.toIso8601String(),
      'treatmentOrganic': jsonEncode(organicTreatments.map((t) => t.toJson()).toList()),
      'treatmentChemical': jsonEncode(chemicalTreatments.map((t) => t.toJson()).toList()),
    };
  }

  factory CropReport.fromMap(Map<String, dynamic> map) {
    final organicList = jsonDecode(map['treatmentOrganic'] as String) as List<dynamic>;
    final chemicalList = jsonDecode(map['treatmentChemical'] as String) as List<dynamic>;

    return CropReport(
      id: map['id'] as String,
      cropName: map['cropName'] as String,
      diseaseName: map['diseaseName'] as String,
      diseaseBanglaName: map['diseaseBanglaName'] as String,
      explanation: map['explanation'] as String,
      severity: map['severity'] as String,
      imagePath: map['imagePath'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      organicTreatments: organicList.map((t) => TreatmentOption.fromJson(t as Map<String, dynamic>)).toList(),
      chemicalTreatments: chemicalList.map((t) => TreatmentOption.fromJson(t as Map<String, dynamic>)).toList(),
    );
  }
}
