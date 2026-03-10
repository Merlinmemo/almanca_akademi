class LessonItem {
  final String german;
  final String turkish;
  final String pronunciation;
  final String? article;
  final String? displayGermanWithArticle;
  final String? example;
  final String? exampleTranslation;
  final String? examplePronunciation;
  final String? note;

  const LessonItem({
    required this.german,
    required this.turkish,
    required this.pronunciation,
    this.article,
    this.displayGermanWithArticle,
    this.example,
    this.exampleTranslation,
    this.examplePronunciation,
    this.note,
  });

  String get titleForCard {
    if (displayGermanWithArticle != null &&
        displayGermanWithArticle!.trim().isNotEmpty) {
      return displayGermanWithArticle!;
    }
    if (article != null && article!.trim().isNotEmpty) {
      return "${article!} $german";
    }
    return german;
  }
}
