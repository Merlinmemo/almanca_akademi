import '../../models/module_model.dart';
import '../../models/word_model.dart';

final ModuleModel modul2 = ModuleModel(
  id: 2, // ✅ int olmalı
  code: "modul2",
  title: 'Günlük Hayat',
  subtitle: 'Temel kelimeler • Basit cümleler',
  estimatedMinutes: 90,
  sections: [
    ModuleSection(
      type: ModuleSectionType.intro,
      title: "Giriş (Intro)",
      description: '',
      xpReward: 10,
    ),
    ModuleSection(
      type: ModuleSectionType.vocab,
      title: "Wortschatz (Kelime)",
      description: '',
      xpReward: 20,
    ),
    ModuleSection(
      type: ModuleSectionType.sentence,
      title: "Satzbau (Cümle Kurma)",
      description: '',
      xpReward: 25,
    ),
    ModuleSection(
      type: ModuleSectionType.listen,
      title: "Hören (Dinleme)",
      description: '',
      xpReward: 25,
    ),
    ModuleSection(
      type: ModuleSectionType.speak,
      title: "Sprechen (Konuşma)",
      description: '',
      xpReward: 25,
    ),
    ModuleSection(
      type: ModuleSectionType.exam,
      title: "Mini Prüfung",
      description: '',
      xpReward: 40,
    ),
  ],
  words: [
    // 50 kelime (A1 – günlük temel)
    WordItem(de: "Hallo", tr: "Merhaba", trPron: "halo", group: "Selam"),
    WordItem(de: "Tschüss", tr: "Hoşça kal", trPron: "çüs", group: "Selam"),
    WordItem(de: "Bitte", tr: "Lütfen / Rica ederim", trPron: "bite", group: "Nezaket"),
    WordItem(de: "Danke", tr: "Teşekkürler", trPron: "danke", group: "Nezaket"),
    WordItem(de: "Ja", tr: "Evet", trPron: "ya", group: "Cevap"),
    WordItem(de: "Nein", tr: "Hayır", trPron: "nayn", group: "Cevap"),
    WordItem(de: "Guten Morgen", tr: "Günaydın", trPron: "guten morgen", group: "Selam"),
    WordItem(de: "Guten Abend", tr: "İyi akşamlar", trPron: "guten abent", group: "Selam"),
    WordItem(de: "Wie geht's?", tr: "Nasılsın?", trPron: "vi gets", group: "Soru"),
    WordItem(de: "Gut", tr: "İyi", trPron: "gut", group: "Cevap"),
    WordItem(de: "Schlecht", tr: "Kötü", trPron: "şleht", group: "Cevap"),
    WordItem(de: "Ich", tr: "Ben", trPron: "ih", group: "Zamir"),
    WordItem(de: "Du", tr: "Sen", trPron: "du", group: "Zamir"),
    WordItem(de: "Er", tr: "O (erkek)", trPron: "ea", group: "Zamir"),
    WordItem(de: "Sie", tr: "O (kadın) / Siz", trPron: "zi", group: "Zamir"),
    WordItem(de: "Wir", tr: "Biz", trPron: "via", group: "Zamir"),
    WordItem(de: "Ihr", tr: "Siz (çoğul)", trPron: "ia", group: "Zamir"),
    WordItem(de: "Sie (pl.)", tr: "Onlar", trPron: "zi", group: "Zamir"),

    WordItem(de: "heißen", tr: "adı olmak", trPron: "haysın", group: "Fiil"),
    WordItem(de: "kommen", tr: "gelmek", trPron: "komen", group: "Fiil"),
    WordItem(de: "wohnen", tr: "oturmak/yaşamak", trPron: "vonın", group: "Fiil"),
    WordItem(de: "arbeiten", tr: "çalışmak", trPron: "arbaytın", group: "Fiil"),
    WordItem(de: "sein", tr: "olmak", trPron: "zayn", group: "Fiil"),
    WordItem(de: "haben", tr: "sahip olmak", trPron: "habın", group: "Fiil"),

    WordItem(de: "Name", tr: "İsim", trPron: "nâme", group: "Temel"),
    WordItem(de: "Land", tr: "Ülke", trPron: "lant", group: "Temel"),
    WordItem(de: "Stadt", tr: "Şehir", trPron: "ştat", group: "Temel"),
    WordItem(de: "Türkei", tr: "Türkiye", trPron: "türkay", group: "Ülke"),
    WordItem(de: "Deutschland", tr: "Almanya", trPron: "doyçlant", group: "Ülke"),
    WordItem(de: "Köln", tr: "Köln", trPron: "kölın", group: "Şehir"),
    WordItem(de: "Izmir", tr: "İzmir", trPron: "izmir", group: "Şehir"),

    WordItem(de: "Mann", tr: "Erkek", trPron: "man", group: "Kişi"),
    WordItem(de: "Frau", tr: "Kadın", trPron: "frov", group: "Kişi"),
    WordItem(de: "Kind", tr: "Çocuk", trPron: "kint", group: "Kişi"),
    WordItem(de: "Freund", tr: "Erkek arkadaş", trPron: "froint", group: "Kişi"),
    WordItem(de: "Freundin", tr: "Kız arkadaş", trPron: "froindin", group: "Kişi"),

    WordItem(de: "Elektriker", tr: "Elektrikçi", trPron: "elektriker", group: "Meslek"),
    WordItem(de: "Mechaniker", tr: "Mekanikçi", trPron: "mehaniker", group: "Meslek"),
    WordItem(de: "Arbeit", tr: "İş", trPron: "arbayt", group: "Meslek"),

    WordItem(de: "heute", tr: "bugün", trPron: "hoyte", group: "Zaman"),
    WordItem(de: "morgen", tr: "yarın", trPron: "morgen", group: "Zaman"),
    WordItem(de: "gestern", tr: "dün", trPron: "geştan", group: "Zaman"),

    WordItem(de: "eins", tr: "bir", trPron: "aynz", group: "Sayı"),
    WordItem(de: "zwei", tr: "iki", trPron: "tsvay", group: "Sayı"),
    WordItem(de: "drei", tr: "üç", trPron: "dray", group: "Sayı"),
    WordItem(de: "vier", tr: "dört", trPron: "fia", group: "Sayı"),
    WordItem(de: "fünf", tr: "beş", trPron: "fünf", group: "Sayı"),

    WordItem(de: "und", tr: "ve", trPron: "unt", group: "Bağlaç"),
    WordItem(de: "oder", tr: "veya", trPron: "oda", group: "Bağlaç"),
    WordItem(de: "aber", tr: "ama", trPron: "aba", group: "Bağlaç"),
  ],
);