import '../../models/module_model.dart';
import '../../models/word_model.dart';

/// A1 - Modül 7: Ev & Aile
final ModuleModel modul7 = ModuleModel(
  id: 7,
  code: "modul7",
  title: 'Ev ve Aile',
  subtitle: 'Ev • odalar • aile konuşmaları',
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
    WordItem(de: "die Familie", tr: "aile", trPron: "di familiye", group: "Aile"),
    WordItem(de: "der Vater", tr: "baba", trPron: "dea faata", group: "Aile"),
    WordItem(de: "die Mutter", tr: "anne", trPron: "di muta", group: "Aile"),
    WordItem(de: "der Bruder", tr: "erkek kardeş", trPron: "dea bruda", group: "Aile"),
    WordItem(de: "die Schwester", tr: "kız kardeş", trPron: "di şvesta", group: "Aile"),
    WordItem(de: "das Kind", tr: "çocuk", trPron: "das kind", group: "Aile"),
    WordItem(de: "die Tochter", tr: "kız evlat", trPron: "di toh-ta", group: "Aile"),
    WordItem(de: "der Sohn", tr: "erkek evlat", trPron: "dea zoon", group: "Aile"),
    WordItem(de: "das Haus", tr: "ev", trPron: "das haus", group: "Ev"),
    WordItem(de: "die Wohnung", tr: "daire", trPron: "di vo-nung", group: "Ev"),
    WordItem(de: "das Zimmer", tr: "oda", trPron: "das tsima", group: "Ev"),
    WordItem(de: "die Küche", tr: "mutfak", trPron: "di kühe", group: "Ev"),
    WordItem(de: "das Bad", tr: "banyo", trPron: "das baat", group: "Ev"),
    WordItem(de: "das Bett", tr: "yatak", trPron: "das bet", group: "Ev"),
    WordItem(de: "der Tisch", tr: "masa", trPron: "dea tiş", group: "Ev"),
    WordItem(de: "der Stuhl", tr: "sandalye", trPron: "dea ştuul", group: "Ev"),
    WordItem(de: "Ich habe ...", tr: "... var (bende)", trPron: "ih habe", group: "Kalıp"),
    WordItem(de: "Ich wohne in einer Wohnung.", tr: "Bir dairede yaşıyorum.", trPron: "ih vone in aynaa vo-nung", group: "Kalıp"),
    WordItem(de: "Ich stehe auf.", tr: "Kalkıyorum.", trPron: "ih ştehe auf", group: "Rutin"),
    WordItem(de: "Ich frühstücke.", tr: "Kahvaltı yapıyorum.", trPron: "ih frü-ştükə", group: "Rutin"),
    WordItem(de: "Ich gehe schlafen.", tr: "Uyumaya gidiyorum.", trPron: "ih gehe şlaafın", group: "Rutin"),
  ],
);
