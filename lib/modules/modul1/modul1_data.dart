import '../../models/module_model.dart';
import 'modul1_course_data.dart';

/// A1 - Modül 1: Temeller
/// Bu dosya artık sadece eski 6-7 bölüm mantığına sıkışmıyor.
/// Asıl öğretici akış modul1_course_data.dart içinden yönetiliyor.
final ModuleModel modul1 = ModuleModel(
  id: 1,
  code: 'modul1',
  title: 'Başlangıç',
  subtitle: 'Alfabe • Sayılar • Takvim • Tanışma',
  estimatedMinutes: 210,
  sections: const [
    ModuleSection(type: ModuleSectionType.intro, title: 'Giriş', description: '', xpReward: 5),
  ],
  words: Modul1CourseData.allWords,
);
