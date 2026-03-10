import 'word_model.dart';

enum ModuleSectionType { intro, vocab, micro, sentence, listen, speak, exam }

class ModuleSection {
  final ModuleSectionType type;
  final String title;
  final String description;
  final int xpReward;

  const ModuleSection({
    required this.type,
    required this.title,
    required this.description,
    required this.xpReward,
  });
}

class ModuleModel {
  final int id;
  final String code;
  final String title;
  final String subtitle;
  final int estimatedMinutes;
  final List<ModuleSection> sections;
  final List<WordItem> words;

  const ModuleModel({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.estimatedMinutes,
    required this.sections,
    required this.words,
  });
}