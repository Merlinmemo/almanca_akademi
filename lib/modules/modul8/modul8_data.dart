import '../../models/module_model.dart';
import '../../models/word_model.dart';

/// A1 - Modül 8: İş & Meslek
final ModuleModel modul8 = ModuleModel(
  id: 8,
  code: "modul8",
  title: 'İş ve Meslek',
  subtitle: 'İş yeri • meslek • kısa konuşmalar',
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
    WordItem(de: "die Arbeit", tr: "iş", trPron: "di aabayt", group: "İş"),
    WordItem(de: "arbeiten", tr: "çalışmak", trPron: "aabaytın", group: "Fiil"),
    WordItem(de: "der Beruf", tr: "meslek", trPron: "dea be-ruuf", group: "İş"),
    WordItem(de: "der Chef", tr: "patron", trPron: "dea şef", group: "İş"),
    WordItem(de: "die Kollegin", tr: "kadın iş arkadaşı", trPron: "di kollegin", group: "İş"),
    WordItem(de: "der Kollege", tr: "erkek iş arkadaşı", trPron: "dea kollegə", group: "İş"),
    WordItem(de: "die Firma", tr: "şirket", trPron: "di firma", group: "İş"),
    WordItem(de: "das Büro", tr: "ofis", trPron: "das büro", group: "İş"),
    WordItem(de: "die Werkstatt", tr: "atölye", trPron: "di verk-ştat", group: "İş"),
    WordItem(de: "der Elektriker", tr: "elektrikçi", trPron: "dea elekt-rika", group: "Meslek"),
    WordItem(de: "der Mechaniker", tr: "mekanikçi", trPron: "dea meha-nika", group: "Meslek"),
    WordItem(de: "die Maschine", tr: "makine", trPron: "di ma-şine", group: "İş"),
    WordItem(de: "die Sicherheit", tr: "güvenlik", trPron: "di ziha-hayt", group: "İş"),
    WordItem(de: "die Pause", tr: "mola", trPron: "di pauze", group: "İş"),
    WordItem(de: "Ich arbeite.", tr: "Çalışıyorum.", trPron: "ih aabaytə", group: "Kalıp"),
    WordItem(de: "Ich arbeite als ...", tr: "... olarak çalışıyorum", trPron: "ih aabaytə als", group: "Kalıp"),
    WordItem(de: "Ich arbeite in einer Firma.", tr: "Bir şirkette çalışıyorum.", trPron: "ih aabaytə in aynaa firma", group: "Kalıp"),
    WordItem(de: "Ich habe heute frei.", tr: "Bugün izinliyim.", trPron: "ih habe hoyte fray", group: "Kalıp"),
    WordItem(de: "Können Sie mir helfen?", tr: "Bana yardım eder misiniz?", trPron: "können zi mia helfen", group: "Kalıp"),
    WordItem(de: "Ich brauche Werkzeug.", tr: "Alete ihtiyacım var.", trPron: "ih brauhe tserk-tsoyk", group: "İş"),
  ],
);
