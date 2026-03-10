import '../../models/module_model.dart';
import '../../models/word_model.dart';

final ModuleModel modul3 = ModuleModel(
  id: 3, // ✅ int olmalı
  code: "modul3",
  title: 'Rutin ve Saatler',
  subtitle: 'Günlük düzen • Saatler • planlar',
  estimatedMinutes: 110,
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
      xpReward: 25,
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
      xpReward: 45,
    ),
  ],
  words: [
    // 50 kelime (A1 – rutin + saatler)
    WordItem(de: "aufstehen", tr: "kalkmak", trPron: "aufştehen", group: "Rutin"),
    WordItem(de: "schlafen", tr: "uyumak", trPron: "şlafın", group: "Rutin"),
    WordItem(de: "arbeiten", tr: "çalışmak", trPron: "arbaytın", group: "Rutin"),
    WordItem(de: "lernen", tr: "öğrenmek/çalışmak", trPron: "lernen", group: "Rutin"),
    WordItem(de: "essen", tr: "yemek yemek", trPron: "esen", group: "Rutin"),
    WordItem(de: "trinken", tr: "içmek", trPron: "trinken", group: "Rutin"),
    WordItem(de: "gehen", tr: "gitmek", trPron: "geyen", group: "Fiil"),
    WordItem(de: "kommen", tr: "gelmek", trPron: "komen", group: "Fiil"),
    WordItem(de: "machen", tr: "yapmak", trPron: "mahın", group: "Fiil"),
    WordItem(de: "lesen", tr: "okumak", trPron: "lezen", group: "Fiil"),

    WordItem(de: "morgens", tr: "sabahları", trPron: "morgıns", group: "Zaman"),
    WordItem(de: "mittags", tr: "öğlenleri", trPron: "mitags", group: "Zaman"),
    WordItem(de: "abends", tr: "akşamları", trPron: "abents", group: "Zaman"),
    WordItem(de: "nachts", tr: "geceleri", trPron: "nahts", group: "Zaman"),

    WordItem(de: "Uhr", tr: "saat (… Uhr)", trPron: "ua", group: "Saat"),
    WordItem(de: "Wie spät ist es?", tr: "Saat kaç?", trPron: "vi şpēt ist es", group: "Saat"),
    WordItem(de: "Es ist", tr: "Saat…", trPron: "es ist", group: "Saat"),
    WordItem(de: "halb", tr: "buçuk", trPron: "halb", group: "Saat"),
    WordItem(de: "Viertel", tr: "çeyrek", trPron: "fiartıl", group: "Saat"),

    WordItem(de: "Montag", tr: "Pazartesi", trPron: "montak", group: "Günler"),
    WordItem(de: "Dienstag", tr: "Salı", trPron: "diynstak", group: "Günler"),
    WordItem(de: "Mittwoch", tr: "Çarşamba", trPron: "mitvoh", group: "Günler"),
    WordItem(de: "Donnerstag", tr: "Perşembe", trPron: "donastak", group: "Günler"),
    WordItem(de: "Freitag", tr: "Cuma", trPron: "fraytak", group: "Günler"),
    WordItem(de: "Samstag", tr: "Cumartesi", trPron: "zamstak", group: "Günler"),
    WordItem(de: "Sonntag", tr: "Pazar", trPron: "zontak", group: "Günler"),

    WordItem(de: "früh", tr: "erken", trPron: "früh", group: "Zaman"),
    WordItem(de: "spät", tr: "geç", trPron: "şpēt", group: "Zaman"),
    WordItem(de: "immer", tr: "her zaman", trPron: "ima", group: "Zarf"),
    WordItem(de: "oft", tr: "sık sık", trPron: "oft", group: "Zarf"),
    WordItem(de: "manchmal", tr: "bazen", trPron: "manmal", group: "Zarf"),
    WordItem(de: "nie", tr: "asla", trPron: "ni", group: "Zarf"),

    WordItem(de: "zu Hause", tr: "evde", trPron: "tsu havze", group: "Yer"),
    WordItem(de: "zur Arbeit", tr: "işe", trPron: "tsur arbayt", group: "Yer"),
    WordItem(de: "in die Schule", tr: "okula", trPron: "in di şule", group: "Yer"),

    WordItem(de: "Frühstück", tr: "kahvaltı", trPron: "frühştük", group: "Yemek"),
    WordItem(de: "Mittagessen", tr: "öğle yemeği", trPron: "mitag-esen", group: "Yemek"),
    WordItem(de: "Abendessen", tr: "akşam yemeği", trPron: "abent-esen", group: "Yemek"),
    WordItem(de: "Wasser", tr: "su", trPron: "vasır", group: "İçecek"),
    WordItem(de: "Tee", tr: "çay", trPron: "te", group: "İçecek"),
    WordItem(de: "Kaffee", tr: "kahve", trPron: "kafe", group: "İçecek"),

    WordItem(de: "eins", tr: "bir", trPron: "aynz", group: "Sayı"),
    WordItem(de: "zwei", tr: "iki", trPron: "tsvay", group: "Sayı"),
    WordItem(de: "drei", tr: "üç", trPron: "dray", group: "Sayı"),
    WordItem(de: "vier", tr: "dört", trPron: "fia", group: "Sayı"),
    WordItem(de: "fünf", tr: "beş", trPron: "fünf", group: "Sayı"),
    WordItem(de: "sechs", tr: "altı", trPron: "zeks", group: "Sayı"),
    WordItem(de: "sieben", tr: "yedi", trPron: "zibın", group: "Sayı"),
    WordItem(de: "acht", tr: "sekiz", trPron: "aht", group: "Sayı"),
    WordItem(de: "neun", tr: "dokuz", trPron: "noyn", group: "Sayı"),
    WordItem(de: "zehn", tr: "on", trPron: "tseyn", group: "Sayı"),
  ],
);