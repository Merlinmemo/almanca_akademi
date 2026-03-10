import 'dart:math';
import '../../models/word_model.dart';

class WordEngine {
  WordEngine._();
  static final WordEngine I = WordEngine._();

  /// Sprint-1b: AI yok. Modüle göre tematik kelime seti üret.
  /// - deterministic (seeded)
  /// - basit çeşitlilik
  List<WordItem> generateWordSet({
    required String moduleCode,
    int count = 40,
    int level = 1,
  }) {
    final rnd = Random();

    final bank = _bankFor(moduleCode);

    // bank.words'i karıştırıp count kadar al
    final pool = List<WordItem>.from(bank.words)..shuffle(rnd);
    final take = min(count, pool.length);
    final picked = pool.take(take).toList();

    return picked;
  }

  // ---------------- helpers ----------------

  Random _seeded(String s) => Random(_hash32(s));

  int _hash32(String s) {
    int h = 2166136261;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 16777619) & 0x7fffffff;
    }
    return h;
  }

  _WordBank _bankFor(String moduleCode) {
    switch (moduleCode) {
      case "modul4":
        return _WordBank.shopping();
      case "modul5":
        return _WordBank.daily();
      case "modul8":
        return _WordBank.work();
      default:
        return _WordBank.core();
    }
  }
}

// ---------------- banks ----------------

class _WordBank {
  final List<WordItem> words;
  const _WordBank(this.words);

  factory _WordBank.core() => _WordBank([
        WordItem(de: "Hallo", tr: "Merhaba", trPron: "Halo", group: "Selamlaşma"),
        WordItem(de: "Tschüss", tr: "Hoşça kal", trPron: "Çüs", group: "Selamlaşma"),
        WordItem(de: "Bitte", tr: "Lütfen / Buyurun", trPron: "Bite", group: "Nezaket"),
        WordItem(de: "Danke", tr: "Teşekkürler", trPron: "Danke", group: "Nezaket"),
        WordItem(de: "Ja", tr: "Evet", trPron: "Ya", group: "Temel"),
        WordItem(de: "Nein", tr: "Hayır", trPron: "Nayn", group: "Temel"),
        WordItem(de: "Ich", tr: "Ben", trPron: "İh", group: "Zamir"),
        WordItem(de: "Du", tr: "Sen", trPron: "Du", group: "Zamir"),
        WordItem(de: "Wir", tr: "Biz", trPron: "Vir", group: "Zamir"),
        WordItem(de: "Er", tr: "O (erkek)", trPron: "E:r", group: "Zamir"),
        WordItem(de: "Sie", tr: "O (kadın) / Siz", trPron: "Zi:", group: "Zamir"),
        WordItem(de: "Heute", tr: "Bugün", trPron: "Hoyte", group: "Zaman"),
        WordItem(de: "Morgen", tr: "Yarın", trPron: "Morgen", group: "Zaman"),
        WordItem(de: "Jetzt", tr: "Şimdi", trPron: "Yetst", group: "Zaman"),
        WordItem(de: "Haus", tr: "Ev", trPron: "Haus", group: "Yerler"),
        WordItem(de: "Schule", tr: "Okul", trPron: "Şule", group: "Yerler"),
        WordItem(de: "Arbeit", tr: "İş", trPron: "Arbayt", group: "Yerler"),
        WordItem(de: "Wasser", tr: "Su", trPron: "Vasa", group: "Yiyecek/İçecek"),
        WordItem(de: "Kaffee", tr: "Kahve", trPron: "Kafe", group: "Yiyecek/İçecek"),
        WordItem(de: "Brot", tr: "Ekmek", trPron: "Brot", group: "Yiyecek/İçecek"),
      ]);

  factory _WordBank.shopping() => _WordBank([
        WordItem(de: "Supermarkt", tr: "Market", trPron: "Zupamarkt", group: "Alışveriş"),
        WordItem(de: "Laden", tr: "Dükkan", trPron: "Laden", group: "Alışveriş"),
        WordItem(de: "Preis", tr: "Fiyat", trPron: "Prays", group: "Alışveriş"),
        WordItem(de: "Kasse", tr: "Kasa", trPron: "Kase", group: "Alışveriş"),
        WordItem(de: "Tüte", tr: "Poşet", trPron: "Tüte", group: "Alışveriş"),
        WordItem(de: "Brot", tr: "Ekmek", trPron: "Brot", group: "Gıda"),
        WordItem(de: "Milch", tr: "Süt", trPron: "Milh", group: "Gıda"),
        WordItem(de: "Wasser", tr: "Su", trPron: "Vasa", group: "Gıda"),
        WordItem(de: "Apfel", tr: "Elma", trPron: "Apfel", group: "Gıda"),
        WordItem(de: "Banane", tr: "Muz", trPron: "Banane", group: "Gıda"),
        WordItem(de: "Käse", tr: "Peynir", trPron: "Keze", group: "Gıda"),
        WordItem(de: "Ei", tr: "Yumurta", trPron: "Ay", group: "Gıda"),
        WordItem(de: "Gemüse", tr: "Sebze", trPron: "Gemüze", group: "Gıda"),
        WordItem(de: "Obst", tr: "Meyve", trPron: "Obst", group: "Gıda"),
        WordItem(de: "Billig", tr: "Ucuz", trPron: "Bilig", group: "Sıfat"),
        WordItem(de: "Teuer", tr: "Pahalı", trPron: "Toyır", group: "Sıfat"),
        WordItem(de: "Kaufen", tr: "Satın almak", trPron: "Kaufen", group: "Fiil"),
        WordItem(de: "Brauchen", tr: "İhtiyaç duymak", trPron: "Brauhen", group: "Fiil"),
      ]);

  factory _WordBank.daily() => _WordBank([
        WordItem(de: "Frühstück", tr: "Kahvaltı", trPron: "Fryüştük", group: "Günlük"),
        WordItem(de: "Mittagessen", tr: "Öğle yemeği", trPron: "Mitağesen", group: "Günlük"),
        WordItem(de: "Abendessen", tr: "Akşam yemeği", trPron: "Abendesen", group: "Günlük"),
        WordItem(de: "Pause", tr: "Mola", trPron: "Pauze", group: "Günlük"),
        WordItem(de: "Sport", tr: "Spor", trPron: "Şport", group: "Günlük"),
        WordItem(de: "Spazieren", tr: "Gezmek", trPron: "Şpatsiren", group: "Fiil"),
        WordItem(de: "Lernen", tr: "Öğrenmek", trPron: "Lernen", group: "Fiil"),
        WordItem(de: "Schlafen", tr: "Uyumak", trPron: "Şlafen", group: "Fiil"),
        WordItem(de: "Aufstehen", tr: "Kalkmak", trPron: "Aufşteyen", group: "Fiil"),
        WordItem(de: "Dusche", tr: "Duş", trPron: "Duşe", group: "Ev"),
        WordItem(de: "Küche", tr: "Mutfak", trPron: "Kühe", group: "Ev"),
        WordItem(de: "Zimmer", tr: "Oda", trPron: "Tsimmer", group: "Ev"),
        WordItem(de: "Park", tr: "Park", trPron: "Park", group: "Yerler"),
        WordItem(de: "Straße", tr: "Cadde/Sokak", trPron: "Ştrase", group: "Yerler"),
      ]);

  factory _WordBank.work() => _WordBank([
        WordItem(de: "Büro", tr: "Ofis", trPron: "Büro", group: "İş"),
        WordItem(de: "Baustelle", tr: "Şantiye", trPron: "Bauştelle", group: "İş"),
        WordItem(de: "Werkzeug", tr: "Alet/El aleti", trPron: "Verktsöyk", group: "İş"),
        WordItem(de: "Plan", tr: "Plan", trPron: "Plan", group: "İş"),
        WordItem(de: "Termin", tr: "Randevu/Tarih", trPron: "Ter-min", group: "İş"),
        WordItem(de: "Meeting", tr: "Toplantı", trPron: "Miting", group: "İş"),
        WordItem(de: "Bericht", tr: "Rapor", trPron: "Beriht", group: "İş"),
        WordItem(de: "Kollege", tr: "İş arkadaşı", trPron: "Kolege", group: "İş"),
        WordItem(de: "Chef", tr: "Patron", trPron: "Şef", group: "İş"),
        WordItem(de: "Arbeiten", tr: "Çalışmak", trPron: "Arbayten", group: "Fiil"),
        WordItem(de: "Machen", tr: "Yapmak", trPron: "Mahen", group: "Fiil"),
        WordItem(de: "Pause", tr: "Mola", trPron: "Pauze", group: "Günlük"),
      ]);
}