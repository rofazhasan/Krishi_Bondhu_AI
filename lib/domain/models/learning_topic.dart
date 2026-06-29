class LearningTopic {
  final String id;
  final String title;
  final String description;
  final String cropType; // ধান, আলু, টমেটো, পাট
  final List<String> keyTips;
  final String iconAsset;

  LearningTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.cropType,
    required this.keyTips,
    required this.iconAsset,
  });
}
