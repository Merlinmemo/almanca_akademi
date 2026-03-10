import '../models/module_model.dart';

import '../modules/modul1/modul1_data.dart';
import '../modules/modul1/modul1_course_data.dart';
import '../modules/modul2/modul2_data.dart';
import '../modules/modul3/modul3_data.dart';
import '../modules/modul4/modul4_data.dart';
import '../modules/modul5/modul5_data.dart';
import '../modules/modul6/modul6_data.dart';
import '../modules/modul7/modul7_data.dart';
import '../modules/modul8/modul8_data.dart';

/// Kursun tek kaynağı: modül sırası + unlock zinciri + toplam ilerleme hesabı buna bakar.
class CourseCatalog {
  /// A1 kursu için başlangıç modülü
  static const String firstModuleCode = "modul1";

  static final List<ModuleModel> modules = [
    modul1,
    modul2,
    modul3,
    modul4,
    modul5,
    modul6,
    modul7,
    modul8,
  ];

  static List<String> get moduleCodes => modules.map((m) => m.code).toList();

  static String? nextOf(String code) {
    final i = moduleCodes.indexOf(code);
    if (i < 0) return null;
    if (i + 1 >= moduleCodes.length) return null;
    return moduleCodes[i + 1];
  }

  /// ✅ Progress hesabı için: bu modülde hangi sectionKey’ler var?
  /// Böylece “6 bölüm” sabitine bağlı kalmıyoruz.
  static List<String> sectionKeysFor(String moduleCode) {
    if (moduleCode == 'modul1') {
      return Modul1CourseData.sectionKeys;
    }

    final ModuleModel? m = modules.where((x) => x.code == moduleCode).cast<ModuleModel?>().firstWhere(
          (x) => x != null,
          orElse: () => null,
        );

    // Bulamazsa fallback
    if (m == null) {
      return const ["intro", "vocab", "sentence", "listen", "speak", "exam", "micro"];
    }

    String keyOf(ModuleSectionType t) {
      switch (t) {
        case ModuleSectionType.intro:
          return "intro";
        case ModuleSectionType.vocab:
          return "vocab";
        case ModuleSectionType.sentence:
          return "sentence";
        case ModuleSectionType.listen:
          return "listen";
        case ModuleSectionType.speak:
          return "speak";
        case ModuleSectionType.exam:
          return "exam";
        case ModuleSectionType.micro:
          return "micro";
      }
    }

    return m.sections.map((s) => keyOf(s.type)).toList();
  }
}