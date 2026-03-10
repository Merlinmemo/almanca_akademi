import '../../models/module_model.dart';
import '../../models/word_model.dart';

/// A1 - Modül 6: Zaman & Randevu
final ModuleModel modul6 = ModuleModel(
  id: 6,
  code: "modul6",
  title: 'Randevu ve Zaman',
  subtitle: 'Saat • gün • randevu',
  estimatedMinutes: 60,
  sections: const [
    ModuleSection(type: ModuleSectionType.intro, title: "Giriş", description: '', xpReward: 5),
    ModuleSection(type: ModuleSectionType.vocab, title: "Wortschatz", description: '', xpReward: 25),
    ModuleSection(type: ModuleSectionType.sentence, title: "Satzbau", description: '', xpReward: 20),
    ModuleSection(type: ModuleSectionType.listen, title: "Hören", description: '', xpReward: 20),
    ModuleSection(type: ModuleSectionType.speak, title: "Sprechen", description: '', xpReward: 25),
    ModuleSection(type: ModuleSectionType.exam, title: "Mini Prüfung", description: '', xpReward: 35),
  ],
  words: const [
    WordItem(de: "heute", tr: "bugün", trPron: "hoyte", group: "Zaman"),
    WordItem(de: "morgen", tr: "yarın", trPron: "morgen", group: "Zaman"),
    WordItem(de: "gestern", tr: "dün", trPron: "gestern", group: "Zaman"),
    WordItem(de: "jetzt", tr: "şimdi", trPron: "yets", group: "Zaman"),
    WordItem(de: "später", tr: "sonra", trPron: "şpeeta", group: "Zaman"),
    WordItem(de: "die Uhr", tr: "saat", trPron: "di ua", group: "Zaman"),
    WordItem(de: "Wie spät ist es?", tr: "Saat kaç?", trPron: "vi şpeet ist es", group: "Soru"),
    WordItem(de: "Es ist ... Uhr.", tr: "Saat ...", trPron: "es ist ua", group: "Kalıp"),
    WordItem(de: "die Minute", tr: "dakika", trPron: "di minuute", group: "Zaman"),
    WordItem(de: "der Termin", tr: "randevu", trPron: "dea ter-min", group: "Randevu"),
    WordItem(de: "einen Termin haben", tr: "randevusu olmak", trPron: "aynın ter-min haabın", group: "Randevu"),
    WordItem(de: "einen Termin machen", tr: "randevu almak", trPron: "aynın ter-min mahın", group: "Randevu"),
    WordItem(de: "am Montag", tr: "pazartesi", trPron: "am montaak", group: "Gün"),
    WordItem(de: "am Dienstag", tr: "salı", trPron: "am diinstaak", group: "Gün"),
    WordItem(de: "am Mittwoch", tr: "çarşamba", trPron: "am mitvoh", group: "Gün"),
    WordItem(de: "am Donnerstag", tr: "perşembe", trPron: "am donas-taak", group: "Gün"),
    WordItem(de: "am Freitag", tr: "cuma", trPron: "am fraytaak", group: "Gün"),
    WordItem(de: "am Samstag", tr: "cumartesi", trPron: "am zamstaak", group: "Gün"),
    WordItem(de: "am Sonntag", tr: "pazar", trPron: "am zonntaak", group: "Gün"),
    WordItem(de: "Passt das?", tr: "Uyar mı?", trPron: "past das", group: "Kalıp"),
    WordItem(de: "Ich habe Zeit.", tr: "Vaktim var.", trPron: "ih habe tsayt", group: "Kalıp"),
    WordItem(de: "Ich habe keine Zeit.", tr: "Vaktim yok.", trPron: "ih habe kaynə tsayt", group: "Kalıp"),
  ],
);
