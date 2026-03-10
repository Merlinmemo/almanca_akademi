class SentencePattern {
  final String title;
  final String exampleDe; // SADECE Almanca
  final String exampleTr; // SADECE Türkçe anlam
  final String microRuleTitle;
  final String microRuleText;
  final List<String> practiceOptions; // seçenekler (DE cümleler)
  final int correctIndex;

  const SentencePattern({
    required this.title,
    required this.exampleDe,
    required this.exampleTr,
    required this.microRuleTitle,
    required this.microRuleText,
    required this.practiceOptions,
    required this.correctIndex,
  });
}

class ListeningItem {
  final String de; // SADECE Almanca cümle
  final String questionTr; // Türkçe soru / yönerge
  final List<String> optionsTr; // Türkçe şıklar
  final int correctIndex;

  const ListeningItem({
    required this.de,
    required this.questionTr,
    required this.optionsTr,
    required this.correctIndex,
  });
}