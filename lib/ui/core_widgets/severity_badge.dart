import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class SeverityBadge extends StatelessWidget {
  final String severityText;

  const SeverityBadge({
    super.key,
    required this.severityText,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String cleanText = severityText;

    if (severityText.contains('গুরুতর') || severityText.toLowerCase().contains('high') || severityText.contains('মারাত্মক')) {
      bgColor = AppColors.dangerBg;
      textColor = AppColors.danger;
      icon = Icons.error;
      cleanText = 'গুরুতর (বিপদজনক)';
    } else if (severityText.contains('মাঝারি') || severityText.toLowerCase().contains('medium') || severityText.contains('সতর্ক')) {
      bgColor = AppColors.warningBg;
      textColor = AppColors.warning;
      icon = Icons.warning;
      cleanText = 'মাঝারি (সতর্ক থাকুন)';
    } else {
      bgColor = AppColors.successBg;
      textColor = AppColors.success;
      icon = Icons.check_circle;
      cleanText = 'সাধারণ (স্বল্প ঝুঁকি)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 10),
          Text(
            cleanText,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
