import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

// Model classes for AI results
class TreatmentOption {
  final String title;
  final String description;
  final String dosage;
  final String precaution;
  final int estimatedCost; // in BDT
  final String? imageUrl; // Mock image for the medicine

  TreatmentOption({
    required this.title,
    required this.description,
    required this.dosage,
    required this.precaution,
    required this.estimatedCost,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'dosage': dosage,
    'precaution': precaution,
    'estimatedCost': estimatedCost,
    'imageUrl': imageUrl,
  };

  factory TreatmentOption.fromJson(Map<String, dynamic> json) => TreatmentOption(
    title: json['title'] as String,
    description: json['description'] as String,
    dosage: json['dosage'] as String,
    precaution: json['precaution'] as String,
    estimatedCost: json['estimatedCost'] as int,
    imageUrl: json['imageUrl'] as String?,
  );
}

class CropAnalysisResult {
  final String cropName;
  final String diseaseName;
  final String diseaseBanglaName;
  final String explanation;
  final String severity; // 'কম' (Low), 'মাঝারি' (Medium), 'বেশি' (High)
  final List<TreatmentOption> organicTreatments;
  final List<TreatmentOption> chemicalTreatments;
  final List<Point<double>> affectedAreas; // OpenCV simulated coordinates (0.0 to 1.0)

  CropAnalysisResult({
    required this.cropName,
    required this.diseaseName,
    required this.diseaseBanglaName,
    required this.explanation,
    required this.severity,
    required this.organicTreatments,
    required this.chemicalTreatments,
    required this.affectedAreas,
  });
}

class AiAnalysisService {
  static final AiAnalysisService instance = AiAnalysisService._init();
  AiAnalysisService._init();

  // Simulates OpenCV contour detection & TFLite inference by reading actual pixel color distributions
  Future<CropAnalysisResult> analyzeCropImage(String imagePath) async {
    // Artificial delay to simulate TFLite processing and OpenCV contour tracing
    await Future<void>.delayed(const Duration(milliseconds: 2500));

    String detectedCrop = 'ধান'; // Default fallback
    double yellowRatio = 0.0;
    double brownRatio = 0.0;
    double greenRatio = 0.0;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);

        if (image != null) {
          // Perform basic pixel color count to mimic OpenCV thresholding
          int totalPixels = 0;
          int yellowPixels = 0;
          int brownPixels = 0;
          int greenPixels = 0;

          // Sample pixels across the image (step size to prevent OOM/slow processing on low-end devices)
          final int step = (image.width * image.height) > 1000000 ? 10 : 4;

          for (int y = 0; y < image.height; y += step) {
            for (int x = 0; x < image.width; x += step) {
              final pixel = image.getPixel(x, y);
              
              // Extract RGB
              final num r = pixel.r;
              final num g = pixel.g;
              final num b = pixel.b;

              totalPixels++;

              // Yellowing threshold: High Red and Green, Low Blue
              if (r > 130 && g > 130 && b < 100) {
                yellowPixels++;
              } 
              // Brown/Spots threshold: Muted Red/Green, Low Blue
              else if (r > 60 && r < 140 && g > 40 && g < 110 && b < 60) {
                brownPixels++;
              }
              // Healthy Green threshold: Green is dominant
              else if (g > r && g > b && g > 70) {
                greenPixels++;
              }
            }
          }

          if (totalPixels > 0) {
            yellowRatio = yellowPixels / totalPixels;
            brownRatio = brownPixels / totalPixels;
            greenRatio = greenPixels / totalPixels;
          }
        }
      }
    } catch (e) {
      debugPrint('Simulated OpenCV pixel check failed: $e');
    }

    // Determine the crop and disease based on image file name tags or color ratios
    final lowerPath = imagePath.toLowerCase();
    
    if (lowerPath.contains('potato') || lowerPath.contains('alu')) {
      detectedCrop = 'আলু';
    } else if (lowerPath.contains('tomato') || lowerPath.contains('tomato')) {
      detectedCrop = 'টমেটো';
    } else if (lowerPath.contains('jute') || lowerPath.contains('pat')) {
      detectedCrop = 'পাট';
    } else {
      // Default guess based on color thresholding
      if (yellowRatio > 0.15 && brownRatio < 0.10) {
        detectedCrop = 'টমেটো'; // Tomato leaf curl is very yellowing
      } else if (brownRatio > 0.12) {
        detectedCrop = 'আলু';   // Late blight causes brown rot
      } else {
        detectedCrop = 'ধান';   // Default crop
      }
    }

    // Generate result based on detected crop
    return _generateDiseaseResult(detectedCrop, yellowRatio, brownRatio, greenRatio);
  }

  CropAnalysisResult _generateDiseaseResult(String crop, double yellow, double brown, double green) {
    // Pre-program high quality crop descriptions in Bangla
    switch (crop) {
      case 'আলু':
        // If brown spots are high, suspect Late Blight, else Early Blight
        if (brown > 0.05 || yellow > 0.05) {
          return CropAnalysisResult(
            cropName: 'আলু',
            diseaseName: 'Late Blight',
            diseaseBanglaName: 'আলুর মড়ক রোগ (লেট ব্লাইট)',
            explanation: 'এটি আলুর একটি মারাত্মক ছত্রাকজনিত রোগ। কুয়াশাচ্ছন্ন আবহাওয়া ও অতিরিক্ত আর্দ্রতায় এটি দ্রুত ছড়ায়। প্রথমে পাতার ডগায় ও প্রান্তে কালো ছোপ ছোপ পচা দাগ পড়ে, যা পরবর্তীতে পুরো গাছ ও আলুতে ছড়িয়ে আলু পচিয়ে ফেলে।',
            severity: 'গুরুতর (লাল সতর্কতা)',
            affectedAreas: const [
              Point(0.35, 0.42),
              Point(0.58, 0.35),
              Point(0.48, 0.65),
            ],
            organicTreatments: [
              TreatmentOption(
                title: 'মেহগনি ফলের নির্যাস স্প্রে',
                description: '১০ লিটার পানিতে ১ কেজি মেহগনি ফল ছেঁচে তৈরি করা ডেকোশন ভালো করে ছেঁকে স্প্রে করুন।',
                dosage: 'প্রতি সপ্তাহে একবার পাতার উপরিভাগে ও নিচে স্প্রে করতে হবে।',
                precaution: 'রোদ উঠলে বা দুপুরের কড়া রোদে স্প্রে করবেন না, পড়ন্ত বিকেলে করুন।',
                estimatedCost: 80,
              ),
              TreatmentOption(
                title: 'ট্রাইকোডার্মা মিশ্রণ ছিটানো',
                description: 'জৈব ছত্রাকনাশক ট্রাইকোডার্মা মাটির সাথে মিশিয়ে ব্যবহার করুন যাতে বীজবাহিত রোগ ছড়াতে না পারে।',
                dosage: 'এক শতক জমিতে ৫০ গ্রাম জৈব মিশ্রণ।',
                precaution: 'কেমিক্যাল সারের সাথে এটি একই সময়ে ব্যবহার করবেন না।',
                estimatedCost: 150,
              )
            ],
            chemicalTreatments: [
              TreatmentOption(
                title: 'ডাইথেন এম-৪৫ (ছত্রাকনাশক)',
                description: 'ম্যানকোজেব গ্রুপের একটি অত্যন্ত কার্যকর রাসায়নিক ছত্রাকনাশক যা আলুর পচন প্রতিরোধ করে।',
                dosage: 'প্রতি লিটার পানিতে ২ গ্রাম পাউডার মিশিয়ে ৭-১০ দিন পর পর স্প্রে করুন।',
                precaution: 'ওষুধ স্প্রে করার সময় মুখে মাস্ক ও হাতে গ্লাভস ব্যবহার নিশ্চিত করুন। স্প্রে করার পর ১৫ দিন ফসল উঠাবেন না।',
                estimatedCost: 280,
                imageUrl: 'assets/images/placeholder_dithane.png',
              ),
              TreatmentOption(
                title: 'সিকিউর ৬০ ডব্লিউজি',
                description: 'ডাইমেথোমর্ফ ও ম্যানকোজেব সমৃদ্ধ যৌথ কার্যকরী সিস্টেমিক ছত্রাকনাশক যা পচন থামায়।',
                dosage: 'প্রতি লিটার পানিতে ১ গ্রাম সিকিউর মিশিয়ে আক্রান্ত স্থানে ভালো করে ভিজিয়ে স্প্রে করুন।',
                precaution: 'বৃষ্টি হওয়ার সম্ভাবনা থাকলে ছিটাবেন না। বাতাসের অনুকূলে স্প্রে করুন।',
                estimatedCost: 350,
              )
            ],
          );
        } else {
          return CropAnalysisResult(
            cropName: 'আলু',
            diseaseName: 'Early Blight',
            diseaseBanglaName: 'আলুর আগাম ধসা রোগ (আর্লি ব্লাইট)',
            explanation: 'এটি অলটারনারিয়া ছত্রাকের কারণে ঘটে। পাতার নিচের অংশে প্রথমে কোণাকার বাদামী দাগ দেখা যায়। দাগগুলো লক্ষ্য করলে দেখা যাবে ভেতরে চক্রাকার বলয় রয়েছে। আক্রান্ত পাতা দ্রুত শুকিয়ে ঝরে যায়।',
            severity: 'মাঝারি (হলুদ সতর্কতা)',
            affectedAreas: const [
              Point(0.25, 0.30),
              Point(0.70, 0.50),
            ],
            organicTreatments: [
              TreatmentOption(
                title: 'নিম পাতার নির্যাস স্প্রে',
                description: 'নিম পাতা গরম পানিতে ফুটিয়ে সেই পানি ঠান্ডা করে আক্রান্ত পাতায় স্প্রে করুন।',
                dosage: '৩ দিন পর পর মোট ৩ বার স্প্রে করুন।',
                precaution: 'তাজা নির্যাস তৈরি করে সাথে সাথে ব্যবহার করা উত্তম।',
                estimatedCost: 50,
              )
            ],
            chemicalTreatments: [
              TreatmentOption(
                title: 'রিডোমিল গোল্ড',
                description: 'সিস্টেমিক ও কন্ট্যাক্ট ছত্রাকনাশক যা ভেতরের ও বাইরের ছত্রাক নষ্ট করে।',
                dosage: 'প্রতি লিটার পানিতে ২ গ্রাম রিডোমিল গোল্ড মিশিয়ে স্প্রে করুন।',
                precaution: 'খালি পেটে বা তীব্র রোদে এটি ছেটানো নিষেধ। স্প্রে করার পর ভালো করে সাবান দিয়ে হাত ধুয়ে নিন।',
                estimatedCost: 320,
              )
            ],
          );
        }

      case 'টমেটো':
        return CropAnalysisResult(
          cropName: 'টমেটো',
          diseaseName: 'Leaf Curl Virus',
          diseaseBanglaName: 'টমেটোর পাতা কোঁকড়ানো রোগ',
          explanation: 'এটি মূলত সাদামাছি (Whitefly) দ্বারা ছড়ানো একটি ভাইরাসজনিত রোগ। আক্রান্ত গাছের পাতা ছোট হয়ে ভেতরের দিকে বা ওপরের দিকে কুকড়ে যায়। গাছের বৃদ্ধি থেমে যায় ও ফুল বা ফল ঠিকমতো আসে না।',
          severity: 'গুরুতর (লাল সতর্কতা)',
          affectedAreas: const [
            Point(0.40, 0.30),
            Point(0.50, 0.45),
            Point(0.62, 0.28),
          ],
          organicTreatments: [
            TreatmentOption(
              title: 'হলুদ ফাঁদ ব্যবহার',
              description: 'ক্ষেতের চারধারে হলুদ রঙের আঠালো বোর্ড টাঙিয়ে দিন যাতে ভাইরাস বহনকারী সাদামাছি পোকা আটকে মারা যায়।',
              dosage: 'প্রতি শতক জমিতে ২টি ফাঁদ স্থাপন করুন।',
              precaution: 'ফাঁদের আঠালো ভাব কমে গেলে আঠা আবার লাগিয়ে দিতে হবে।',
              estimatedCost: 60,
            ),
            TreatmentOption(
              title: 'নিম তেল ও সাবান জল স্প্রে',
              description: '১ লিটার পানিতে ৫ মিলি নিম তেল ও ২ গ্রাম হুইল পাউডার মিশিয়ে ভালো করে ঝাঁকিয়ে স্প্রে করুন।',
              dosage: 'সাদামাছি তাড়াতে ৫ দিন অন্তর অন্তর সকালে ছিটান।',
              precaution: 'তেল ভালোভাবে পানিতে মিশেছে কিনা তা স্প্রে করার আগে দেখে নিন।',
              estimatedCost: 120,
            )
          ],
          chemicalTreatments: [
            TreatmentOption(
              title: 'টিডো ২০ এসএল (ইমিডাক্লোপ্রিড)',
              description: 'পদ্ধতিগত কীটনাশক যা রস চোষক সাদামাছি পোকাকে সম্পূর্ণ দমন করে ভাইরাসের বিস্তার রোধ করে।',
              dosage: 'প্রতি লিটার পানিতে ০.৫ মিলি টিডো মিশিয়ে গাছের পাতার নিচসহ ভালো করে স্প্রে করুন।',
              precaution: 'ফুটন্ত ফুলে স্প্রে করবেন না কারণ এটি উপকারী মৌমাছিদের ক্ষতি করতে পারে।',
              estimatedCost: 180,
            ),
            TreatmentOption(
              title: 'একতারা ২৫ ডব্লিউজি',
              description: 'থিয়ামেক্সাম গ্রুপের উচ্চ ক্ষমতাসম্পন্ন কীটনাশক যা পোকা দমন করে।',
              dosage: '১০ লিটার পানিতে ২.৫ গ্রাম একতারা পাউডার মিশিয়ে পুরো জমিতে স্প্রে করুন।',
              precaution: 'ছেটানোর কমপক্ষে ৭ দিন পর্যন্ত ফল তুলে বাজারজাত করা যাবে না।',
              estimatedCost: 220,
            )
          ],
        );

      case 'পাট':
        return CropAnalysisResult(
          cropName: 'পাট',
          diseaseName: 'Stem Rot',
          diseaseBanglaName: 'পাটের কান্ড পচা রোগ',
          explanation: 'ছত্রাকজনিত এই রোগে পাটের কান্ডে গাঢ় বাদামী বা কালো রঙের দাগ দেখা যায়। ধীরে ধীরে এই দাগ পুরো কান্ডে ছড়িয়ে পড়ে আঁশ দুর্বল ও কালো করে দেয়। গাছের ডগা শুকিয়ে মারা যায়।',
          severity: 'গুরুতর (লাল সতর্কতা)',
          affectedAreas: const [
            Point(0.45, 0.50),
            Point(0.50, 0.75),
          ],
          organicTreatments: [
            TreatmentOption(
              title: 'ছাই ও চুন প্রয়োগ',
              description: 'গাছের গোড়ায় শুকনো কাঠকয়লার ছাই এবং গুঁড়ো করা চুন মিশিয়ে মাটির চারধারে ছিটিয়ে দিন।',
              dosage: '১ শতকে ৫০০ গ্রাম ছাই ও ৫০ গ্রাম চুন ছিটিয়ে দিন।',
              precaution: 'মাটি ভেজা থাকা অবস্থায় প্রয়োগ করা উত্তম।',
              estimatedCost: 40,
            )
          ],
          chemicalTreatments: [
            TreatmentOption(
              title: 'অটোস্টিন (কার্বেন্ডাজিম)',
              description: 'সিস্টেমিক ছত্রাকনাশক যা আঁশ পচা ও ডগা মরা রোগ প্রতিরোধে অত্যন্ত কার্যকর।',
              dosage: 'প্রতি লিটার পানিতে ২ গ্রাম অটোস্টিন পাউডার গুলে কান্ডের গোড়ায় ও আক্রান্ত স্থানে স্প্রে করুন।',
              precaution: 'পুকুরে বা যেখানে মাছ চাষ হয় তার পাশে স্প্রে জল নিষ্কাশন করবেন না।',
              estimatedCost: 250,
            )
          ],
        );

      case 'ধান':
      default:
        // Suspect Blast disease by default
        return CropAnalysisResult(
          cropName: 'ধান',
          diseaseName: 'Rice Blast',
          diseaseBanglaName: 'ধানের ব্লাস্ট রোগ (পাতার রোগ)',
          explanation: 'এটি ধানের পাতার একটি অত্যন্ত মারাত্মক ছত্রাকবাহী রোগ। পাতার ওপর চোখের মতো দুই প্রান্ত ছুঁচালো বাদামী রঙের দাগ দেখা যায়, দাগের মাঝখানটা ছাই রঙের হয়। এটি ছড়িয়ে পড়লে পুরো শীষ ভেঙে পড়ে এবং ফলন নষ্ট হয়।',
          severity: 'গুরুতর (লাল সতর্কতা)',
          affectedAreas: const [
            Point(0.30, 0.35),
            Point(0.48, 0.55),
            Point(0.65, 0.40),
          ],
          organicTreatments: [
            TreatmentOption(
              title: 'কাঁচা গোবর ও জলের মিশ্রণ স্প্রে',
              description: '১০ লিটার পানিতে ২ কেজি তাজা পরিষ্কার কাঁচা গোবর ভালোভাবে গুলিয়ে ৫-৬ দিন পচিয়ে সেই জল ছেঁকে পাতায় স্প্রে করুন। এটি ছত্রাক দমন করতে সাহায্য করে।',
              dosage: 'সকালে বা বিকেলে আক্রান্ত পাতার উপরিভাগে স্প্রে করুন।',
              precaution: 'মিশ্রণটি ভালো করে সুতি কাপড় দিয়ে ছেঁকে নিন যাতে স্প্রেয়ারের নজল আটকে না যায়।',
              estimatedCost: 30,
            ),
            TreatmentOption(
              title: 'পটাশ সার ছিটানো (নিরাময়ক)',
              description: 'ক্ষেতে ছত্রাকের আক্রমণ কমাতে মাটিতে জৈব পটাশ বা রাসায়নিক এমওপি পটাশ সার ব্যবহার বাড়ান।',
              dosage: 'বিঘা প্রতি ৩-৪ কেজি অতিরিক্ত পটাশ ছিটান।',
              precaution: 'ইউরিয়া সারের অতিরিক্ত ব্যবহার বন্ধ করুন, কারণ বেশি ইউরিয়া রোগ বাড়ায়।',
              estimatedCost: 110,
            )
          ],
          chemicalTreatments: [
            TreatmentOption(
              title: 'নাটিভো ৭৫ ডব্লিউজি',
              description: 'বায়ার কোম্পানির ট্রাইফ্লক্সিস্ট্রবিন ও টেবুকোনাজল সমৃদ্ধ অত্যন্ত শক্তিশালী ছত্রাকনাশক যা ব্লাস্ট রোগ সম্পূর্ণ দমন করে।',
              dosage: '১০ লিটার পানিতে ৬ গ্রাম নাটিভো মিশিয়ে ধানের শীষ বের হওয়ার মুখে একবার এবং ব্লাস্ট রোগ দেখা দেওয়ার সাথে সাথে স্প্রে করুন।',
              precaution: 'বাতাস যেদিকে বইছে তার উল্টো দিকে স্প্রে ছিটাবেন না। ওষুধ ব্যবহারের ৭ দিন পর পর্যন্ত ধান কাটবেন না।',
              estimatedCost: 380,
              imageUrl: 'assets/images/placeholder_nativo.png',
            ),
            TreatmentOption(
              title: 'ট্রুপার ৭৫ ডব্লিউপি',
              description: 'ট্রাইসাইক্লাজল গ্রুপের ট্রুপার ধানের পাতা ও নেক ব্লাস্টের বিরুদ্ধে বিশেষ প্রতিষেধক।',
              dosage: 'প্রতি লিটার পানিতে ০.৮ গ্রাম ট্রুপার মিশিয়ে আক্রান্ত মাঠে ছড়িয়ে স্প্রে করুন।',
              precaution: 'ছিটানোর পর ২ ঘন্টার মধ্যে বৃষ্টি হলে পুনরায় স্প্রে করা লাগতে পারে। মুখে হাত দেবেন না।',
              estimatedCost: 290,
            )
          ],
        );
    }
  }
}
