class WordItem {
  final String de;      // Almanca
  final String tr;      // Türkçe anlam
  final String trPron;  // Okunuş (TR yazım)
  final String? group;  // Kategori
  final String? exampleDe;
  final String? exampleTr;
  final String? note;

  const WordItem({
    required this.de,
    required this.tr,
    required this.trPron,
    this.group,
    this.exampleDe,
    this.exampleTr,
    this.note,
  });
}
