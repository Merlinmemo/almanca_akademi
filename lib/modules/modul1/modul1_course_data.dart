import 'package:flutter/material.dart';

import '../../models/word_model.dart';

class Modul1LessonEntry {
  final String de;
  final String tr;
  final String pron;
  final String exampleDe;
  final String exampleTr;
  final String note;
  final String category;

  const Modul1LessonEntry({
    required this.de,
    required this.tr,
    required this.pron,
    required this.exampleDe,
    required this.exampleTr,
    required this.note,
    required this.category,
  });

  WordItem toWordItem() => WordItem(
        de: de,
        tr: tr,
        trPron: pron,
        group: category,
        exampleDe: exampleDe,
        exampleTr: exampleTr,
        note: note,
      );
}

Modul1LessonEntry _entry({
  required String de,
  required String tr,
  required String pron,
  required String exampleDe,
  required String exampleTr,
  required String note,
  required String category,
}) =>
    Modul1LessonEntry(
      de: de,
      tr: tr,
      pron: pron,
      exampleDe: exampleDe,
      exampleTr: exampleTr,
      note: note,
      category: category,
    );

enum Modul1UnitMode { lesson, listen, speak, exam }

class Modul1Unit {
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final int xpReward;
  final Modul1UnitMode mode;
  final List<Modul1LessonEntry> entries;

  const Modul1Unit({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.mode,
    this.entries = const [],
  });
}

class Modul1CourseData {
  Modul1CourseData._();

  static final List<Modul1Unit> units = [
    Modul1Unit(
      key: 'alphabet',
      title: 'Alfabe',
      description: 'Tüm temel harfler, umlautlar ve ß ile başlangıç.',
      icon: Icons.sort_by_alpha_rounded,
      xpReward: 8,
      mode: Modul1UnitMode.lesson,
      entries: _alphabet,
    ),
    Modul1Unit(
      key: 'sounds',
      title: 'Telaffuz Sesleri',
      description: 'sch, ch, ei, ie, eu gibi Alman seslerini kulağa oturt.',
      icon: Icons.record_voice_over_rounded,
      xpReward: 8,
      mode: Modul1UnitMode.lesson,
      entries: _sounds,
    ),
    Modul1Unit(
      key: 'numbers',
      title: 'Sayılar',
      description: '0–20, onlar ve günlük kullanım sayıları.',
      icon: Icons.pin_rounded,
      xpReward: 10,
      mode: Modul1UnitMode.lesson,
      entries: _numbers,
    ),
    Modul1Unit(
      key: 'days',
      title: 'Günler',
      description: 'Haftanın günleri ve günlük plan cümleleri.',
      icon: Icons.calendar_view_week_rounded,
      xpReward: 8,
      mode: Modul1UnitMode.lesson,
      entries: _days,
    ),
    Modul1Unit(
      key: 'months_seasons',
      title: 'Aylar ve Mevsimler',
      description: 'Yıl akışını kur: aylar, mevsimler, hangi aydayız?',
      icon: Icons.calendar_month_rounded,
      xpReward: 8,
      mode: Modul1UnitMode.lesson,
      entries: _monthsAndSeasons,
    ),
    Modul1Unit(
      key: 'dates_time',
      title: 'Tarihler ve Zaman',
      description: 'Bugün ayın kaçı, saat kaç, sabah mı akşam mı?',
      icon: Icons.schedule_rounded,
      xpReward: 10,
      mode: Modul1UnitMode.lesson,
      entries: _datesAndTime,
    ),
    Modul1Unit(
      key: 'greetings',
      title: 'Selamlaşma',
      description: 'Günün saatine göre selam ver, doğal başla.',
      icon: Icons.waving_hand_rounded,
      xpReward: 8,
      mode: Modul1UnitMode.lesson,
      entries: _greetings,
    ),
    Modul1Unit(
      key: 'introductions',
      title: 'Tanışma',
      description: 'İsim sorma, tanışma ve ilk temas kalıpları.',
      icon: Icons.people_alt_rounded,
      xpReward: 8,
      mode: Modul1UnitMode.lesson,
      entries: _introductions,
    ),
    Modul1Unit(
      key: 'self_intro',
      title: 'Kendini Tanıtma',
      description: 'Kimsin, nerelisin, ne yapıyorsun?',
      icon: Icons.badge_rounded,
      xpReward: 10,
      mode: Modul1UnitMode.lesson,
      entries: _selfIntro,
    ),
    Modul1Unit(
      key: 'places',
      title: 'Ülkeler / Şehirler',
      description: 'Nereden geliyorum, nerede yaşıyorum?',
      icon: Icons.public_rounded,
      xpReward: 8,
      mode: Modul1UnitMode.lesson,
      entries: _places,
    ),
    Modul1Unit(
      key: 'goodbyes',
      title: 'Vedalaşma',
      description: 'Kapanış cümleleri ve doğal ayrılış.',
      icon: Icons.logout_rounded,
      xpReward: 8,
      mode: Modul1UnitMode.lesson,
      entries: _goodbyes,
    ),
    Modul1Unit(
      key: 'politeness',
      title: 'Nezaket Kalıpları',
      description: 'Lütfen, teşekkürler, özür ve rica.',
      icon: Icons.favorite_border_rounded,
      xpReward: 8,
      mode: Modul1UnitMode.lesson,
      entries: _politeness,
    ),
    Modul1Unit(
      key: 'questions',
      title: 'Soru Kalıpları',
      description: 'Basit soru cümleleriyle iletişimi aç.',
      icon: Icons.help_outline_rounded,
      xpReward: 8,
      mode: Modul1UnitMode.lesson,
      entries: _questions,
    ),
    Modul1Unit(
      key: 'pronouns',
      title: 'Kişi Zamirleri',
      description: 'ich, du, er... cümle iskeletini kur.',
      icon: Icons.account_tree_rounded,
      xpReward: 8,
      mode: Modul1UnitMode.lesson,
      entries: _pronouns,
    ),
    Modul1Unit(
      key: 'verbs',
      title: 'Temel Fiiller',
      description: 'sein, haben, kommen, wohnen, lernen ve günlük fiiller.',
      icon: Icons.bolt_rounded,
      xpReward: 10,
      mode: Modul1UnitMode.lesson,
      entries: _verbs,
    ),
    Modul1Unit(
      key: 'daily_sentences',
      title: 'Günlük Mini Cümleler',
      description: 'Kısa, net ve hemen kullanılabilir günlük cümleler.',
      icon: Icons.chat_bubble_outline_rounded,
      xpReward: 10,
      mode: Modul1UnitMode.lesson,
      entries: _dailySentences,
    ),
    Modul1Unit(
      key: 'listen',
      title: 'Dinleme',
      description: 'Duy, eşleştir ve kulağı Alman ritmine alıştır.',
      icon: Icons.headphones_rounded,
      xpReward: 14,
      mode: Modul1UnitMode.listen,
    ),
    Modul1Unit(
      key: 'speak',
      title: 'Konuşma',
      description: 'Tekrar et, sesli söyle, refleks kazan.',
      icon: Icons.mic_rounded,
      xpReward: 14,
      mode: Modul1UnitMode.speak,
    ),
    Modul1Unit(
      key: 'exam',
      title: 'Test',
      description: 'Kelime + anlam + kullanım + dinleme karışık final.',
      icon: Icons.fact_check_rounded,
      xpReward: 24,
      mode: Modul1UnitMode.exam,
    ),
  ];

  static List<String> get sectionKeys => units.map((e) => e.key).toList();
  static List<WordItem> get allWords => units.expand((u) => u.entries).map((e) => e.toWordItem()).toList();

  static Modul1Unit byKey(String key) => units.firstWhere((u) => u.key == key);

  static final List<Modul1LessonEntry> _alphabet = [
    _entry(de: 'A', tr: 'a harfi', pron: 'aa', exampleDe: 'A wie Abend.', exampleTr: 'A, Abend kelimesindeki gibi.', note: 'Açık ve uzun a sesi.', category: 'Alfabe'),
    _entry(de: 'B', tr: 'be harfi', pron: 'bee', exampleDe: 'B wie Brot.', exampleTr: 'B, Brot kelimesindeki gibi.', note: 'Türkçedeki b gibi temiz çıkar.', category: 'Alfabe'),
    _entry(de: 'C', tr: 'tse harfi', pron: 'tse', exampleDe: 'C wie Café.', exampleTr: 'Café kelimesinde duyulur.', note: 'Tek başına nadir, çoğu zaman yabancı kelimelerde görülür.', category: 'Alfabe'),
    _entry(de: 'D', tr: 'de harfi', pron: 'dee', exampleDe: 'D wie Deutsch.', exampleTr: 'Deutsch kelimesindeki gibi.', note: 'Kelime sonunda bazen daha sert duyulur.', category: 'Alfabe'),
    _entry(de: 'E', tr: 'e harfi', pron: 'ee', exampleDe: 'E wie Essen.', exampleTr: 'Essen kelimesindeki gibi.', note: 'Bazen kısa, bazen uzun duyulur.', category: 'Alfabe'),
    _entry(de: 'F', tr: 'ef harfi', pron: 'ef', exampleDe: 'F wie Frau.', exampleTr: 'Frau kelimesindeki gibi.', note: 'Türkçedeki f ile benzerdir.', category: 'Alfabe'),
    _entry(de: 'G', tr: 'ge harfi', pron: 'gee', exampleDe: 'G wie gut.', exampleTr: 'gut kelimesindeki gibi.', note: 'Bazı kelime sonlarında daha sert duyulabilir.', category: 'Alfabe'),
    _entry(de: 'H', tr: 'ha harfi', pron: 'haa', exampleDe: 'H wie Haus.', exampleTr: 'Haus kelimesindeki gibi.', note: 'Bazen sesi uzatır, bazen net h olarak duyulur.', category: 'Alfabe'),
    _entry(de: 'I', tr: 'i harfi', pron: 'ii', exampleDe: 'I wie ich.', exampleTr: 'ich kelimesindeki gibi.', note: 'İnce i sesi verir.', category: 'Alfabe'),
    _entry(de: 'J', tr: 'yot harfi', pron: 'yot', exampleDe: 'J wie ja.', exampleTr: 'ja kelimesindeki gibi.', note: 'Almancada çoğu zaman y gibi okunur.', category: 'Alfabe'),
    _entry(de: 'K', tr: 'ka harfi', pron: 'kaa', exampleDe: 'K wie Kaffee.', exampleTr: 'Kaffee kelimesindeki gibi.', note: 'Sert ve net k sesi.', category: 'Alfabe'),
    _entry(de: 'L', tr: 'el harfi', pron: 'el', exampleDe: 'L wie lernen.', exampleTr: 'lernen kelimesindeki gibi.', note: 'Temiz bir l sesi kullan.', category: 'Alfabe'),
    _entry(de: 'M', tr: 'em harfi', pron: 'em', exampleDe: 'M wie Montag.', exampleTr: 'Montag kelimesindeki gibi.', note: 'Dudakları kapatıp net m çıkar.', category: 'Alfabe'),
    _entry(de: 'N', tr: 'en harfi', pron: 'en', exampleDe: 'N wie Name.', exampleTr: 'Name kelimesindeki gibi.', note: 'Türkçedeki n ile benzerdir.', category: 'Alfabe'),
    _entry(de: 'O', tr: 'o harfi', pron: 'oo', exampleDe: 'O wie Orange.', exampleTr: 'Orange kelimesindeki gibi.', note: 'Yuvarlak ve temiz söyle.', category: 'Alfabe'),
    _entry(de: 'P', tr: 'pe harfi', pron: 'pee', exampleDe: 'P wie Park.', exampleTr: 'Park kelimesindeki gibi.', note: 'Türkçedeki p sesine benzer.', category: 'Alfabe'),
    _entry(de: 'Q', tr: 'ku harfi', pron: 'kuu', exampleDe: 'Q kommt oft mit U: Quelle.', exampleTr: 'Q çoğu zaman U ile gelir: Quelle.', note: 'Tek başına çok az görülür.', category: 'Alfabe'),
    _entry(de: 'R', tr: 'er harfi', pron: 'er', exampleDe: 'R wie rot.', exampleTr: 'rot kelimesindeki gibi.', note: 'Boğazdan hafif titreşimli duyulabilir.', category: 'Alfabe'),
    _entry(de: 'S', tr: 'es harfi', pron: 'es', exampleDe: 'S wie Sonne.', exampleTr: 'Sonne kelimesindeki gibi.', note: 'Bazı kelime başlarında z gibi de duyulur.', category: 'Alfabe'),
    _entry(de: 'T', tr: 'te harfi', pron: 'tee', exampleDe: 'T wie Tag.', exampleTr: 'Tag kelimesindeki gibi.', note: 'Sert ama temiz t sesi.', category: 'Alfabe'),
    _entry(de: 'U', tr: 'u harfi', pron: 'uu', exampleDe: 'U wie gut.', exampleTr: 'gut kelimesindeki gibi.', note: 'Yuvarlak u sesi.', category: 'Alfabe'),
    _entry(de: 'V', tr: 'fau harfi', pron: 'fau', exampleDe: 'V wie Vater.', exampleTr: 'Vater kelimesindeki gibi.', note: 'Çoğu zaman f gibi okunur.', category: 'Alfabe'),
    _entry(de: 'W', tr: 've harfi', pron: 'vee', exampleDe: 'W wie Wasser.', exampleTr: 'Wasser kelimesindeki gibi.', note: 'Almancada v gibi okunur.', category: 'Alfabe'),
    _entry(de: 'X', tr: 'iks harfi', pron: 'iks', exampleDe: 'X wie Taxi.', exampleTr: 'Taxi kelimesindeki gibi.', note: 'Genelde ks sesi verir.', category: 'Alfabe'),
    _entry(de: 'Y', tr: 'ypsilon harfi', pron: 'üpsilon', exampleDe: 'Y wie Yoga.', exampleTr: 'Yoga kelimesindeki gibi.', note: 'Yabancı kelimelerde daha sık görülür.', category: 'Alfabe'),
    _entry(de: 'Z', tr: 'tset harfi', pron: 'tset', exampleDe: 'Z wie Zeit.', exampleTr: 'Zeit kelimesindeki gibi.', note: 'Almancada çoğu zaman ts sesi verir.', category: 'Alfabe'),
    _entry(de: 'Ä', tr: 'umlaut a', pron: 'e/ae', exampleDe: 'Ä wie spät.', exampleTr: 'spät kelimesindeki gibi.', note: 'A ile e arası bir sestir.', category: 'Alfabe'),
    _entry(de: 'Ö', tr: 'umlaut o', pron: 'ö', exampleDe: 'Ö wie Köln.', exampleTr: 'Köln kelimesindeki gibi.', note: 'Türkçedeki ö’ye çok yakındır.', category: 'Alfabe'),
    _entry(de: 'Ü', tr: 'umlaut u', pron: 'ü', exampleDe: 'Ü wie Tür.', exampleTr: 'Tür kelimesindeki gibi.', note: 'Türkçedeki ü’ye çok yakındır.', category: 'Alfabe'),
    _entry(de: 'ß', tr: 'es-tset', pron: 's keskin', exampleDe: 'ß wie Straße.', exampleTr: 'Straße kelimesindeki gibi.', note: 'Uzun s sesi verir; ss gibi düşün.', category: 'Alfabe'),
  ];

  static final List<Modul1LessonEntry> _sounds = [
    _entry(de: 'sch', tr: 'ş sesi', pron: 'ş', exampleDe: 'Schule', exampleTr: 'okul', note: 'sch gördüğünde çoğu zaman ş diye düşün.', category: 'Telaffuz'),
    _entry(de: 'ch', tr: 'hırıltılı ses', pron: 'hıh', exampleDe: 'ich / Buch', exampleTr: 'ich ve Buch içinde farklı tonları vardır.', note: 'İlk gün tam oturmaz; kulak alıştıkça gelir.', category: 'Telaffuz'),
    _entry(de: 'ei', tr: 'ay sesi', pron: 'ay', exampleDe: 'eins', exampleTr: 'bir', note: 'ei genelde ay diye okunur.', category: 'Telaffuz'),
    _entry(de: 'ie', tr: 'uzun i', pron: 'ii', exampleDe: 'wie', exampleTr: 'nasıl', note: 'ie çoğu zaman uzun i verir.', category: 'Telaffuz'),
    _entry(de: 'eu', tr: 'oy sesi', pron: 'oy', exampleDe: 'heute', exampleTr: 'bugün', note: 'eu çoğu zaman oy gibi okunur.', category: 'Telaffuz'),
    _entry(de: 'sp / st', tr: 'şp / şt', pron: 'şp / şt', exampleDe: 'Sport / Straße', exampleTr: 'spor / sokak', note: 'Kelime başında sp ve st çoğu zaman şp ve şt duyulur.', category: 'Telaffuz'),
    _entry(de: 'z', tr: 'ts sesi', pron: 'ts', exampleDe: 'Zeit', exampleTr: 'zaman', note: 'z harfi Almancada tek başına z değil, ts verir.', category: 'Telaffuz'),
    _entry(de: 'w', tr: 'v sesi', pron: 'v', exampleDe: 'Wasser', exampleTr: 'su', note: 'w harfi çoğu zaman v diye okunur.', category: 'Telaffuz'),
  ];

  static final List<Modul1LessonEntry> _numbers = [
    _entry(de: 'null', tr: 'sıfır', pron: 'nul', exampleDe: 'Meine Nummer beginnt mit null.', exampleTr: 'Numaram sıfır ile başlıyor.', note: 'Telefon ve numaralarda çok geçer.', category: 'Sayılar'),
    _entry(de: 'eins', tr: 'bir', pron: 'ayns', exampleDe: 'Ich habe ein Handy.', exampleTr: 'Bir telefonum var.', note: 'ein/eine ile karışabilir; bağlamı dinle.', category: 'Sayılar'),
    _entry(de: 'zwei', tr: 'iki', pron: 'tsvay', exampleDe: 'Ich habe zwei Kinder.', exampleTr: 'İki çocuğum var.', note: 'zw = tsv gibi duyulur.', category: 'Sayılar'),
    _entry(de: 'drei', tr: 'üç', pron: 'dray', exampleDe: 'Wir sind drei Personen.', exampleTr: 'Biz üç kişiyiz.', note: 'ei burada ay sesi verir.', category: 'Sayılar'),
    _entry(de: 'vier', tr: 'dört', pron: 'fia', exampleDe: 'Der Tisch hat vier Beine.', exampleTr: 'Masanın dört ayağı var.', note: 'r sesi sonlarda yutulabilir.', category: 'Sayılar'),
    _entry(de: 'fünf', tr: 'beş', pron: 'fünf', exampleDe: 'Ich arbeite fünf Tage.', exampleTr: 'Beş gün çalışıyorum.', note: 'ü sesini net çıkar.', category: 'Sayılar'),
    _entry(de: 'sechs', tr: 'altı', pron: 'zeks', exampleDe: 'Es ist sechs Uhr.', exampleTr: 'Saat altı.', note: 'chs birleşik duyulur.', category: 'Sayılar'),
    _entry(de: 'sieben', tr: 'yedi', pron: 'ziibın', exampleDe: 'Ich komme um sieben.', exampleTr: 'Yedide geliyorum.', note: 'ie uzun i verir.', category: 'Sayılar'),
    _entry(de: 'acht', tr: 'sekiz', pron: 'aht', exampleDe: 'Heute ist der achte März.', exampleTr: 'Bugün sekiz Mart.', note: 'ch boğazdan çıkar.', category: 'Sayılar'),
    _entry(de: 'neun', tr: 'dokuz', pron: 'noyn', exampleDe: 'Der Termin ist um neun.', exampleTr: 'Randevu saat dokuzda.', note: 'eu çoğu zaman oyna yakın duyulur.', category: 'Sayılar'),
    _entry(de: 'zehn', tr: 'on', pron: 'tseyn', exampleDe: 'Ich habe zehn Euro.', exampleTr: 'On avrom var.', note: 'z burada ts diye okunur.', category: 'Sayılar'),
    _entry(de: 'elf', tr: 'on bir', pron: 'elf', exampleDe: 'Es ist elf Uhr.', exampleTr: 'Saat on bir.', note: 'Kısa ve net bir kelime.', category: 'Sayılar'),
    _entry(de: 'zwölf', tr: 'on iki', pron: 'tsvölf', exampleDe: 'Zwölf Monate sind ein Jahr.', exampleTr: 'On iki ay bir yıldır.', note: 'ö sesine dikkat et.', category: 'Sayılar'),
    _entry(de: 'dreizehn', tr: 'on üç', pron: 'dray-tseyn', exampleDe: 'Ich bin dreizehn Minuten spät.', exampleTr: 'On üç dakika geç kaldım.', note: '-zehn son eki 13–19 arası sık görülür.', category: 'Sayılar'),
    _entry(de: 'zwanzig', tr: 'yirmi', pron: 'tsvantsih', exampleDe: 'Ich bin zwanzig Jahre alt.', exampleTr: 'Yirmi yaşındayım.', note: 'Günlük yaş söylemede çok gerekir.', category: 'Sayılar'),
    _entry(de: 'dreißig', tr: 'otuz', pron: 'draysih', exampleDe: 'Der Bus kommt in dreißig Minuten.', exampleTr: 'Otobüs otuz dakika sonra geliyor.', note: 'ß burada uzun s verir.', category: 'Sayılar'),
    _entry(de: 'vierzig', tr: 'kırk', pron: 'fiatsih', exampleDe: 'Vierzig Euro sind zu viel.', exampleTr: 'Kırk avro çok fazla.', note: 'Fiyatlarda çok geçer.', category: 'Sayılar'),
    _entry(de: 'fünfzig', tr: 'elli', pron: 'fünftsih', exampleDe: 'Ich lerne fünfzig Wörter.', exampleTr: 'Elli kelime öğreniyorum.', note: 'Hedef cümlelerinde işe yarar.', category: 'Sayılar'),
    _entry(de: 'hundert', tr: 'yüz', pron: 'hundert', exampleDe: 'Hundert Prozent.', exampleTr: 'Yüzde yüz.', note: 'Yüzde ve sayı sisteminde temel.', category: 'Sayılar'),
  ];

  static final List<Modul1LessonEntry> _days = [
    _entry(de: 'Montag', tr: 'Pazartesi', pron: 'montaak', exampleDe: 'Am Montag arbeite ich.', exampleTr: 'Pazartesi çalışıyorum.', note: 'am + gün kalıbını erken öğren.', category: 'Günler'),
    _entry(de: 'Dienstag', tr: 'Salı', pron: 'diinstaak', exampleDe: 'Am Dienstag lerne ich Deutsch.', exampleTr: 'Salı Almanca öğreniyorum.', note: 'ie uzun i verir.', category: 'Günler'),
    _entry(de: 'Mittwoch', tr: 'Çarşamba', pron: 'mitvoh', exampleDe: 'Heute ist Mittwoch.', exampleTr: 'Bugün Çarşamba.', note: 'Ortadaki h sonu yumuşatır.', category: 'Günler'),
    _entry(de: 'Donnerstag', tr: 'Perşembe', pron: 'donırstaak', exampleDe: 'Am Donnerstag habe ich Zeit.', exampleTr: 'Perşembe vaktim var.', note: 'Uzun ama çok kullanışlı bir gün adı.', category: 'Günler'),
    _entry(de: 'Freitag', tr: 'Cuma', pron: 'fraytaak', exampleDe: 'Am Freitag fahre ich nach Hause.', exampleTr: 'Cuma eve gidiyorum.', note: 'ei yine ay sesi verir.', category: 'Günler'),
    _entry(de: 'Samstag', tr: 'Cumartesi', pron: 'zamstaak', exampleDe: 'Am Samstag habe ich frei.', exampleTr: 'Cumartesi boşum.', note: 'Bazı bölgelerde Sonnabend da duyulur.', category: 'Günler'),
    _entry(de: 'Sonntag', tr: 'Pazar', pron: 'zontaak', exampleDe: 'Am Sonntag ruhe ich mich aus.', exampleTr: 'Pazar dinleniyorum.', note: 'Hafta sonu planlarında temel kelime.', category: 'Günler'),
  ];

  static final List<Modul1LessonEntry> _monthsAndSeasons = [
    _entry(de: 'Januar', tr: 'Ocak', pron: 'yanuar', exampleDe: 'Im Januar ist es kalt.', exampleTr: 'Ocakta hava soğuktur.', note: 'im + ay kalıbı işine yarar.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'Februar', tr: 'Şubat', pron: 'februar', exampleDe: 'Im Februar ist der Winter noch da.', exampleTr: 'Şubatta kış hâlâ sürer.', note: 'r seslerini çok zorlamadan söyle.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'März', tr: 'Mart', pron: 'merts', exampleDe: 'Im März beginnt der Frühling.', exampleTr: 'Martta ilkbahar başlar.', note: 'ä ve z sesine dikkat.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'April', tr: 'Nisan', pron: 'april', exampleDe: 'Im April regnet es oft.', exampleTr: 'Nisanda sık yağmur yağar.', note: 'Hava durumu cümlelerinde geçer.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'Mai', tr: 'Mayıs', pron: 'may', exampleDe: 'Im Mai ist es schöner.', exampleTr: 'Mayısta hava daha güzeldir.', note: 'Kısa ama çok kolay bir ay adı.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'Juni', tr: 'Haziran', pron: 'yuni', exampleDe: 'Im Juni wird es warm.', exampleTr: 'Haziranda hava ısınır.', note: 'J harfi y gibi duyulur.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'Juli', tr: 'Temmuz', pron: 'yuli', exampleDe: 'Im Juli habe ich Urlaub.', exampleTr: 'Temmuzda tatilim var.', note: 'Tatil cümleleriyle bağla.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'August', tr: 'Ağustos', pron: 'august', exampleDe: 'Im August ist es sehr heiß.', exampleTr: 'Ağustosta hava çok sıcak olur.', note: 'Sıcaklık cümlelerinde geçer.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'September', tr: 'Eylül', pron: 'zeptember', exampleDe: 'Im September beginne ich einen Kurs.', exampleTr: 'Eylülde bir kursa başlıyorum.', note: 's başta z gibi duyulabilir.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'Oktober', tr: 'Ekim', pron: 'oktobır', exampleDe: 'Im Oktober ist es kühler.', exampleTr: 'Ekimde hava daha serin olur.', note: 'Son r yumuşayabilir.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'November', tr: 'Kasım', pron: 'novembır', exampleDe: 'Im November regnet es viel.', exampleTr: 'Kasımda çok yağmur yağar.', note: 'Hava durumu için iyi örnek.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'Dezember', tr: 'Aralık', pron: 'detsembır', exampleDe: 'Im Dezember ist Weihnachten.', exampleTr: 'Aralıkta Noel vardır.', note: 'z = ts unutma.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'der Frühling', tr: 'ilkbahar', pron: 'dea früüling', exampleDe: 'Im Frühling blühen die Blumen.', exampleTr: 'İlkbaharda çiçekler açar.', note: 'Mevsimlerde der artikeliyle gör.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'der Sommer', tr: 'yaz', pron: 'dea zomır', exampleDe: 'Im Sommer ist es heiß.', exampleTr: 'Yazın hava sıcaktır.', note: 'En temel mevsim cümlesi.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'der Herbst', tr: 'sonbahar', pron: 'dea herbst', exampleDe: 'Im Herbst fallen die Blätter.', exampleTr: 'Sonbaharda yapraklar düşer.', note: 'Herbst kelimesi Almanya’da çok duyulur.', category: 'Aylar ve Mevsimler'),
    _entry(de: 'der Winter', tr: 'kış', pron: 'dea vintır', exampleDe: 'Im Winter ist es kalt.', exampleTr: 'Kışın hava soğuktur.', note: 'w harfi v gibi okunur.', category: 'Aylar ve Mevsimler'),
  ];

  static final List<Modul1LessonEntry> _datesAndTime = [
    _entry(de: 'heute', tr: 'bugün', pron: 'hoytı', exampleDe: 'Heute lerne ich Deutsch.', exampleTr: 'Bugün Almanca öğreniyorum.', note: 'En temel zaman zarfı.', category: 'Tarih ve Zaman'),
    _entry(de: 'morgen', tr: 'yarın / sabah', pron: 'morgın', exampleDe: 'Morgen arbeite ich nicht.', exampleTr: 'Yarın çalışmıyorum.', note: 'Bağlama göre sabah veya yarın anlamına gelebilir.', category: 'Tarih ve Zaman'),
    _entry(de: 'gestern', tr: 'dün', pron: 'gestern', exampleDe: 'Gestern war ich müde.', exampleTr: 'Dün yorgundum.', note: 'Basit geçmiş hissi verir.', category: 'Tarih ve Zaman'),
    _entry(de: 'am Morgen', tr: 'sabah', pron: 'am morgın', exampleDe: 'Am Morgen trinke ich Tee.', exampleTr: 'Sabah çay içerim.', note: 'am + bölüm kalıbı çok işine yarar.', category: 'Tarih ve Zaman'),
    _entry(de: 'am Abend', tr: 'akşam', pron: 'am aabınt', exampleDe: 'Am Abend telefoniere ich.', exampleTr: 'Akşam telefonla konuşurum.', note: 'Günlük rutin cümlesi için ideal.', category: 'Tarih ve Zaman'),
    _entry(de: 'um acht Uhr', tr: 'saat sekizde', pron: 'um aht uur', exampleDe: 'Ich beginne um acht Uhr.', exampleTr: 'Saat sekizde başlıyorum.', note: 'Saat söylemenin çekirdeği: um + saat + Uhr.', category: 'Tarih ve Zaman'),
    _entry(de: 'Wie spät ist es?', tr: 'Saat kaç?', pron: 'vi şpeet ist es', exampleDe: 'Entschuldigung, wie spät ist es?', exampleTr: 'Affedersiniz, saat kaç?', note: 'Sokakta çok kullanılır.', category: 'Tarih ve Zaman'),
    _entry(de: 'Heute ist Montag.', tr: 'Bugün Pazartesi.', pron: 'hoytı ist montaak', exampleDe: 'Heute ist Montag und ich arbeite.', exampleTr: 'Bugün Pazartesi ve çalışıyorum.', note: 'Gün söylemek için temel iskelet.', category: 'Tarih ve Zaman'),
    _entry(de: 'Heute ist der dritte März.', tr: 'Bugün üç Mart.', pron: 'hoytı ist dea drite merts', exampleDe: 'Heute ist der dritte März.', exampleTr: 'Bugün üç Mart.', note: 'Tarihlerde der + sıra sayısı kalıbı kullanılır.', category: 'Tarih ve Zaman'),
    _entry(de: 'am Wochenende', tr: 'hafta sonunda', pron: 'am vohınende', exampleDe: 'Am Wochenende ruhe ich mich aus.', exampleTr: 'Hafta sonunda dinleniyorum.', note: 'Plan cümlelerinde çok gerekli.', category: 'Tarih ve Zaman'),
  ];

  static final List<Modul1LessonEntry> _greetings = [
    _entry(de: 'Hallo', tr: 'Merhaba', pron: 'halo', exampleDe: 'Hallo, wie geht es dir?', exampleTr: 'Merhaba, nasılsın?', note: 'En nötr ve güvenli selamdır.', category: 'Selamlaşma'),
    _entry(de: 'Guten Morgen', tr: 'Günaydın', pron: 'gutın morgen', exampleDe: 'Guten Morgen, Mehmet.', exampleTr: 'Günaydın Mehmet.', note: 'Sabah saatlerinde kullanılır.', category: 'Selamlaşma'),
    _entry(de: 'Guten Tag', tr: 'İyi günler', pron: 'gutın taag', exampleDe: 'Guten Tag, Frau Keller.', exampleTr: 'İyi günler Bayan Keller.', note: 'Resmî ve güvenli bir kalıptır.', category: 'Selamlaşma'),
    _entry(de: 'Guten Abend', tr: 'İyi akşamlar', pron: 'gutın aabınt', exampleDe: 'Guten Abend zusammen.', exampleTr: 'İyi akşamlar herkese.', note: 'Akşam giriş cümlesidir.', category: 'Selamlaşma'),
    _entry(de: 'Hi', tr: 'Selam', pron: 'hay', exampleDe: 'Hi, alles gut?', exampleTr: 'Selam, her şey yolunda mı?', note: 'Daha samimi ve kısa kullanım.', category: 'Selamlaşma'),
    _entry(de: 'Servus', tr: 'Selam / hoşça kal', pron: 'zervus', exampleDe: 'Servus, bis später!', exampleTr: 'Selam, sonra görüşürüz!', note: 'Daha çok güney Almanya ve Avusturya tarafında duyulur.', category: 'Selamlaşma'),
  ];

  static final List<Modul1LessonEntry> _introductions = [
    _entry(de: 'Wie heißt du?', tr: 'Adın ne?', pron: 'vi hayst du', exampleDe: 'Hallo, wie heißt du?', exampleTr: 'Merhaba, adın ne?', note: 'Samimi hitapta kullanılır.', category: 'Tanışma'),
    _entry(de: 'Ich heiße Mehmet.', tr: 'Benim adım Mehmet.', pron: 'ih haysı mehmet', exampleDe: 'Hallo, ich heiße Mehmet.', exampleTr: 'Merhaba, benim adım Mehmet.', note: 'İlk tanışmada en temel kalıptır.', category: 'Tanışma'),
    _entry(de: 'Freut mich.', tr: 'Memnun oldum.', pron: 'froyt mih', exampleDe: 'Freut mich, dich kennenzulernen.', exampleTr: 'Tanıştığımıza memnun oldum.', note: 'Kısa ve çok kullanışlı bir kalıp.', category: 'Tanışma'),
    _entry(de: 'Und du?', tr: 'Ya sen?', pron: 'unt du', exampleDe: 'Ich komme aus Izmir. Und du?', exampleTr: 'Ben İzmir’den geliyorum. Ya sen?', note: 'Sohbeti karşı tarafa paslar.', category: 'Tanışma'),
    _entry(de: 'Wer bist du?', tr: 'Sen kimsin?', pron: 'vea bist du', exampleDe: 'Hallo, wer bist du?', exampleTr: 'Merhaba, sen kimsin?', note: 'Günlük hayatta daha az, ama bilmek faydalı.', category: 'Tanışma'),
    _entry(de: 'Ich bin neu hier.', tr: 'Ben burada yeniyim.', pron: 'ih bin noy hia', exampleDe: 'Ich bin neu hier in Köln.', exampleTr: 'Ben burada, Köln’de yeniyim.', note: 'Yeni ortam cümlesi.', category: 'Tanışma'),
  ];

  static final List<Modul1LessonEntry> _selfIntro = [
    _entry(de: 'Ich bin Mehmet.', tr: 'Ben Mehmet’im.', pron: 'ih bin mehmet', exampleDe: 'Ich bin Mehmet und ich lerne Deutsch.', exampleTr: 'Ben Mehmet’im ve Almanca öğreniyorum.', note: 'Kimlik bildiren en temel yapı.', category: 'Kendini Tanıtma'),
    _entry(de: 'Ich komme aus der Türkei.', tr: 'Türkiye’den geliyorum.', pron: 'ih komme aus dea türkay', exampleDe: 'Ich komme aus der Türkei, aus Izmir.', exampleTr: 'Türkiye’den, İzmir’den geliyorum.', note: 'Köken belirtirken kullanılır.', category: 'Kendini Tanıtma'),
    _entry(de: 'Ich wohne in Izmir.', tr: 'İzmir’de yaşıyorum.', pron: 'ih vone in izmir', exampleDe: 'Ich wohne in Izmir, aber ich will nach Köln.', exampleTr: 'İzmir’de yaşıyorum ama Köln’e gitmek istiyorum.', note: 'wohnen = bir yerde yaşamak.', category: 'Kendini Tanıtma'),
    _entry(de: 'Ich arbeite in einer Werkstatt.', tr: 'Bir atölyede çalışıyorum.', pron: 'ih arbayte in ayner verkştat', exampleDe: 'Heute arbeite ich in einer Werkstatt.', exampleTr: 'Bugün bir atölyede çalışıyorum.', note: 'Senin hayatına direkt değen kalıp.', category: 'Kendini Tanıtma'),
    _entry(de: 'Ich lerne Deutsch.', tr: 'Almanca öğreniyorum.', pron: 'ih lerne doyç', exampleDe: 'Ich lerne jeden Abend Deutsch.', exampleTr: 'Her akşam Almanca öğreniyorum.', note: 'Öğrenme motivasyon cümlesi.', category: 'Kendini Tanıtma'),
    _entry(de: 'Ich bin dreißig Jahre alt.', tr: 'Otuz yaşındayım.', pron: 'ih bin draysih yaare alt', exampleDe: 'Ich bin dreißig Jahre alt.', exampleTr: 'Otuz yaşındayım.', note: 'Yaş söylerken standart kalıp.', category: 'Kendini Tanıtma'),
  ];

  static final List<Modul1LessonEntry> _places = [
    _entry(de: 'die Türkei', tr: 'Türkiye', pron: 'di türkay', exampleDe: 'Ich komme aus der Türkei.', exampleTr: 'Türkiye’den geliyorum.', note: 'Ülkelerde çoğu zaman artikel de öğrenmek faydalı.', category: 'Ülkeler ve Şehirler'),
    _entry(de: 'Deutschland', tr: 'Almanya', pron: 'doyçlant', exampleDe: 'Ich möchte nach Deutschland gehen.', exampleTr: 'Almanya’ya gitmek istiyorum.', note: 'Hedef ülke cümlesi.', category: 'Ülkeler ve Şehirler'),
    _entry(de: 'Köln', tr: 'Köln', pron: 'köln', exampleDe: 'Meine Freundin lebt in Köln.', exampleTr: 'Sevgilim Köln’de yaşıyor.', note: 'Ö sesini net çıkar.', category: 'Ülkeler ve Şehirler'),
    _entry(de: 'Izmir', tr: 'İzmir', pron: 'izmir', exampleDe: 'Ich wohne in Izmir.', exampleTr: 'İzmir’de yaşıyorum.', note: 'Şehirlerle in kullanılır.', category: 'Ülkeler ve Şehirler'),
    _entry(de: 'in der Stadt', tr: 'şehirde', pron: 'in dea ştat', exampleDe: 'Ich bin in der Stadt.', exampleTr: 'Şehirdeyim.', note: 'Yer bildiren kısa kalıp.', category: 'Ülkeler ve Şehirler'),
    _entry(de: 'zu Hause', tr: 'evde', pron: 'tsu hauze', exampleDe: 'Heute bin ich zu Hause.', exampleTr: 'Bugün evdeyim.', note: 'Çok temel bir günlük ifade.', category: 'Ülkeler ve Şehirler'),
  ];

  static final List<Modul1LessonEntry> _goodbyes = [
    _entry(de: 'Tschüss', tr: 'Hoşça kal', pron: 'çüs', exampleDe: 'Tschüss, bis morgen!', exampleTr: 'Hoşça kal, yarın görüşürüz!', note: 'En temel vedalaşma kalıbı.', category: 'Vedalaşma'),
    _entry(de: 'Auf Wiedersehen', tr: 'Görüşmek üzere', pron: 'auf viidırzeen', exampleDe: 'Auf Wiedersehen, Frau Meier.', exampleTr: 'Görüşmek üzere Bayan Meier.', note: 'Daha resmî vedalaşma.', category: 'Vedalaşma'),
    _entry(de: 'Bis später', tr: 'Sonra görüşürüz', pron: 'bis şpeeter', exampleDe: 'Bis später, ich rufe dich an.', exampleTr: 'Sonra görüşürüz, seni ararım.', note: 'Yakın zamanda tekrar görüşeceksen kullan.', category: 'Vedalaşma'),
    _entry(de: 'Bis morgen', tr: 'Yarın görüşürüz', pron: 'bis morgın', exampleDe: 'Bis morgen in der Arbeit.', exampleTr: 'Yarın işte görüşürüz.', note: 'İş ve okul için çok kullanılır.', category: 'Vedalaşma'),
    _entry(de: 'Schönen Tag noch', tr: 'İyi günler dilerim', pron: 'şönın taak noh', exampleDe: 'Danke, schönen Tag noch!', exampleTr: 'Teşekkürler, iyi günler!', note: 'Kibar kapanış cümlesi.', category: 'Vedalaşma'),
  ];

  static final List<Modul1LessonEntry> _politeness = [
    _entry(de: 'bitte', tr: 'lütfen / buyurun', pron: 'bite', exampleDe: 'Bitte sprechen Sie langsam.', exampleTr: 'Lütfen yavaş konuşun.', note: 'Hem rica hem cevap olarak kullanılır.', category: 'Nezaket'),
    _entry(de: 'danke', tr: 'teşekkürler', pron: 'danke', exampleDe: 'Danke für Ihre Hilfe.', exampleTr: 'Yardımınız için teşekkürler.', note: 'Günlük Alman nezaketinin temeli.', category: 'Nezaket'),
    _entry(de: 'danke schön', tr: 'çok teşekkür ederim', pron: 'danke şöön', exampleDe: 'Danke schön, das ist sehr nett.', exampleTr: 'Çok teşekkür ederim, bu çok nazikçe.', note: 'Bir tık daha sıcak teşekkür.', category: 'Nezaket'),
    _entry(de: 'entschuldigung', tr: 'affedersiniz / özür dilerim', pron: 'entşuldigung', exampleDe: 'Entschuldigung, wo ist der Bahnhof?', exampleTr: 'Affedersiniz, istasyon nerede?', note: 'Yol sormada çok kullanılır.', category: 'Nezaket'),
    _entry(de: 'kein Problem', tr: 'sorun değil', pron: 'kayn problem', exampleDe: 'Kein Problem, ich helfe dir.', exampleTr: 'Sorun değil, sana yardım ederim.', note: 'Rahat ve dostça bir cevap.', category: 'Nezaket'),
    _entry(de: 'gern', tr: 'memnuniyetle / seve seve', pron: 'gern', exampleDe: 'Gern, ich wiederhole es.', exampleTr: 'Memnuniyetle, tekrar ederim.', note: 'Nazik ama kısa cevap.', category: 'Nezaket'),
  ];

  static final List<Modul1LessonEntry> _questions = [
    _entry(de: 'Wie geht es dir?', tr: 'Nasılsın?', pron: 'vi geet es dia', exampleDe: 'Hallo, wie geht es dir heute?', exampleTr: 'Merhaba, bugün nasılsın?', note: 'İlk temas cümlelerinden biri.', category: 'Soru Kalıpları'),
    _entry(de: 'Wo wohnst du?', tr: 'Nerede yaşıyorsun?', pron: 'vo vonst du', exampleDe: 'Wo wohnst du jetzt?', exampleTr: 'Şu an nerede yaşıyorsun?', note: 'wo = nerede.', category: 'Soru Kalıpları'),
    _entry(de: 'Woher kommst du?', tr: 'Nereden geliyorsun?', pron: 'vohea komst du', exampleDe: 'Woher kommst du ursprünglich?', exampleTr: 'Aslen nereden geliyorsun?', note: 'woher = nereden.', category: 'Soru Kalıpları'),
    _entry(de: 'Was machst du?', tr: 'Ne yapıyorsun?', pron: 'vas mahst du', exampleDe: 'Was machst du heute?', exampleTr: 'Bugün ne yapıyorsun?', note: 'Günlük konuşmada çok geçer.', category: 'Soru Kalıpları'),
    _entry(de: 'Kannst du das wiederholen?', tr: 'Bunu tekrar edebilir misin?', pron: 'kanst du das vidırholen', exampleDe: 'Entschuldigung, kannst du das wiederholen?', exampleTr: 'Affedersiniz, bunu tekrar edebilir misiniz?', note: 'Dil öğrenirken hayat kurtarır.', category: 'Soru Kalıpları'),
    _entry(de: 'Was bedeutet das?', tr: 'Bu ne demek?', pron: 'vas bedoytet das', exampleDe: 'Was bedeutet dieses Wort?', exampleTr: 'Bu kelime ne demek?', note: 'Kelime sorarken kullan.', category: 'Soru Kalıpları'),
    _entry(de: 'Wer bist du?', tr: 'Sen kimsin?', pron: 'vea bist du', exampleDe: 'Hallo, wer bist du?', exampleTr: 'Merhaba, sen kimsin?', note: 'wer kişi sorar.', category: 'Soru Kalıpları'),
    _entry(de: 'Wann kommst du?', tr: 'Ne zaman geliyorsun?', pron: 'van komst du', exampleDe: 'Wann kommst du nach Hause?', exampleTr: 'Eve ne zaman geliyorsun?', note: 'wann zaman sorar.', category: 'Soru Kalıpları'),
    _entry(de: 'Warum lernst du Deutsch?', tr: 'Neden Almanca öğreniyorsun?', pron: 'varum lernst du doyç', exampleDe: 'Warum lernst du Deutsch jeden Tag?', exampleTr: 'Neden her gün Almanca öğreniyorsun?', note: 'warum = neden.', category: 'Soru Kalıpları'),
    _entry(de: 'Wie viel kostet das?', tr: 'Bu ne kadar?', pron: 'vi fiil kostet das', exampleDe: 'Entschuldigung, wie viel kostet das?', exampleTr: 'Affedersiniz, bu ne kadar?', note: 'Alışverişte lazım olur.', category: 'Soru Kalıpları'),
    _entry(de: 'Wohin gehst du?', tr: 'Nereye gidiyorsun?', pron: 'vohin geyst du', exampleDe: 'Wohin gehst du heute?', exampleTr: 'Bugün nereye gidiyorsun?', note: 'wohin hareket yönünü sorar.', category: 'Soru Kalıpları'),
  ];

  static final List<Modul1LessonEntry> _pronouns = [
    _entry(de: 'ich', tr: 'ben', pron: 'ih', exampleDe: 'Ich lerne Deutsch.', exampleTr: 'Ben Almanca öğreniyorum.', note: 'Birinci tekil kişi.', category: 'Zamirler'),
    _entry(de: 'du', tr: 'sen', pron: 'du', exampleDe: 'Du bist sehr nett.', exampleTr: 'Sen çok naziksin.', note: 'Samimi hitapta kullanılır.', category: 'Zamirler'),
    _entry(de: 'er', tr: 'o (erkek)', pron: 'ea', exampleDe: 'Er kommt aus Köln.', exampleTr: 'O Köln’den geliyor.', note: 'Erkek kişi için.', category: 'Zamirler'),
    _entry(de: 'sie', tr: 'o (kadın) / onlar / siz', pron: 'zii', exampleDe: 'Sie wohnt in Berlin.', exampleTr: 'O Berlin’de yaşıyor.', note: 'Bağlama göre anlamı değişir.', category: 'Zamirler'),
    _entry(de: 'es', tr: 'o (cansız)', pron: 'es', exampleDe: 'Es ist kalt.', exampleTr: 'Hava soğuk.', note: 'Hava cümlelerinde çok gelir.', category: 'Zamirler'),
    _entry(de: 'wir', tr: 'biz', pron: 'via', exampleDe: 'Wir lernen zusammen.', exampleTr: 'Birlikte öğreniyoruz.', note: 'Birlikte iş yaparken kullan.', category: 'Zamirler'),
    _entry(de: 'ihr', tr: 'siz', pron: 'ia', exampleDe: 'Ihr seid hier neu.', exampleTr: 'Siz burada yenisiniz.', note: 'Samimi çoğul hitap.', category: 'Zamirler'),
    _entry(de: 'Sie', tr: 'siz (resmî)', pron: 'zii', exampleDe: 'Wie heißen Sie?', exampleTr: 'Adınız ne?', note: 'Resmî hitapta büyük harfle yazılır.', category: 'Zamirler'),
    _entry(de: 'sie', tr: 'onlar', pron: 'zii', exampleDe: 'Sie kommen heute nicht.', exampleTr: 'Onlar bugün gelmiyor.', note: 'Küçük s ile onlar anlamına gelir.', category: 'Zamirler'),
    _entry(de: 'mich', tr: 'beni', pron: 'miş', exampleDe: 'Er sieht mich.', exampleTr: 'O beni görüyor.', note: 'Akkusativ hâlde kullanılır.', category: 'Zamirler'),
    _entry(de: 'dir', tr: 'sana', pron: 'dia', exampleDe: 'Ich helfe dir.', exampleTr: 'Sana yardım ediyorum.', note: 'Dativ hâlde çok geçer.', category: 'Zamirler'),
  ];

  static final List<Modul1LessonEntry> _verbs = [
    _entry(de: 'sein', tr: 'olmak', pron: 'zayn', exampleDe: 'Ich bin müde.', exampleTr: 'Yorgunum.', note: 'En temel fiillerden biri.', category: 'Temel Fiiller'),
    _entry(de: 'haben', tr: 'sahip olmak', pron: 'haabın', exampleDe: 'Ich habe Zeit.', exampleTr: 'Vaktim var.', note: 'Sahiplik ve birçok kalıpta kullanılır.', category: 'Temel Fiiller'),
    _entry(de: 'kommen', tr: 'gelmek', pron: 'kommın', exampleDe: 'Ich komme aus Izmir.', exampleTr: 'İzmir’den geliyorum.', note: 'Köken ve hareket için temel fiil.', category: 'Temel Fiiller'),
    _entry(de: 'wohnen', tr: 'oturmak / yaşamak', pron: 'vohnın', exampleDe: 'Ich wohne in Köln.', exampleTr: 'Köln’de yaşıyorum.', note: 'Adres ve şehir cümlelerinde gerekir.', category: 'Temel Fiiller'),
    _entry(de: 'lernen', tr: 'öğrenmek', pron: 'lernın', exampleDe: 'Ich lerne jeden Tag Deutsch.', exampleTr: 'Her gün Almanca öğreniyorum.', note: 'Senin ana fiillerinden biri.', category: 'Temel Fiiller'),
    _entry(de: 'arbeiten', tr: 'çalışmak', pron: 'arbaytın', exampleDe: 'Heute arbeite ich in der Werkstatt.', exampleTr: 'Bugün atölyede çalışıyorum.', note: 'İş cümlelerinde ana fiil.', category: 'Temel Fiiller'),
    _entry(de: 'machen', tr: 'yapmak', pron: 'mahın', exampleDe: 'Was machst du heute?', exampleTr: 'Bugün ne yapıyorsun?', note: 'Çok genel ve güçlü fiil.', category: 'Temel Fiiller'),
    _entry(de: 'gehen', tr: 'gitmek', pron: 'geeyn', exampleDe: 'Ich gehe nach Hause.', exampleTr: 'Eve gidiyorum.', note: 'Hareket cümlelerinin temelidir.', category: 'Temel Fiiller'),
    _entry(de: 'sprechen', tr: 'konuşmak', pron: 'şprehın', exampleDe: 'Ich spreche ein bisschen Deutsch.', exampleTr: 'Biraz Almanca konuşuyorum.', note: 'Dil cümlelerinde çok işe yarar.', category: 'Temel Fiiller'),
    _entry(de: 'verstehen', tr: 'anlamak', pron: 'ferşteeyn', exampleDe: 'Ich verstehe das nicht.', exampleTr: 'Bunu anlamıyorum.', note: 'Dil öğrenirken çok kritik fiil.', category: 'Temel Fiiller'),
    _entry(de: 'fragen', tr: 'sormak', pron: 'fraagen', exampleDe: 'Ich frage meinen Lehrer.', exampleTr: 'Öğretmenime soruyorum.', note: 'Soru kalıplarıyla birlikte çalış.', category: 'Temel Fiiller'),
    _entry(de: 'antworten', tr: 'cevap vermek', pron: 'antvortın', exampleDe: 'Ich antworte sofort.', exampleTr: 'Hemen cevap veriyorum.', note: 'fragen ile takım olur.', category: 'Temel Fiiller'),
    _entry(de: 'hören', tr: 'duymak / dinlemek', pron: 'hörın', exampleDe: 'Ich höre den Satz noch einmal.', exampleTr: 'Cümleyi bir kez daha dinliyorum.', note: 'Dinleme bölümünün fiili.', category: 'Temel Fiiller'),
    _entry(de: 'lesen', tr: 'okumak', pron: 'leezın', exampleDe: 'Ich lese einen kurzen Text.', exampleTr: 'Kısa bir metin okuyorum.', note: 'ie burada uzun i verir.', category: 'Temel Fiiller'),
    _entry(de: 'schreiben', tr: 'yazmak', pron: 'şraybın', exampleDe: 'Ich schreibe neue Wörter auf.', exampleTr: 'Yeni kelimeleri yazıyorum.', note: 'ei yine ay sesi verir.', category: 'Temel Fiiller'),
    _entry(de: 'buchstabieren', tr: 'harf harf söylemek', pron: 'buhştabiirın', exampleDe: 'Können Sie das bitte buchstabieren?', exampleTr: 'Bunu lütfen harf harf söyler misiniz?', note: 'Alfabe ile doğrudan bağlantılı.', category: 'Temel Fiiller'),
  ];

  static final List<Modul1LessonEntry> _dailySentences = [
    _entry(de: 'Ich bin heute zu Hause.', tr: 'Bugün evdeyim.', pron: 'ih bin hoytı tsu hauze', exampleDe: 'Ich bin heute zu Hause und lerne Deutsch.', exampleTr: 'Bugün evdeyim ve Almanca öğreniyorum.', note: 'Günlük durum cümlesi.', category: 'Günlük Cümleler'),
    _entry(de: 'Heute arbeite ich in der Werkstatt.', tr: 'Bugün atölyede çalışıyorum.', pron: 'hoytı arbayte ih in dea verkştat', exampleDe: 'Heute arbeite ich in der Werkstatt bis sechs Uhr.', exampleTr: 'Bugün atölyede saat altıya kadar çalışıyorum.', note: 'Senin hayatına çok uygun cümle.', category: 'Günlük Cümleler'),
    _entry(de: 'Am Abend trinke ich Tee.', tr: 'Akşam çay içerim.', pron: 'am aabınt trinke ih tee', exampleDe: 'Am Abend trinke ich Tee und telefoniere.', exampleTr: 'Akşam çay içerim ve telefonla konuşurum.', note: 'Rutin anlatmak için güzel başlangıç.', category: 'Günlük Cümleler'),
    _entry(de: 'Ich lerne jeden Tag Deutsch.', tr: 'Her gün Almanca öğreniyorum.', pron: 'ih lerne yedın taak doyç', exampleDe: 'Ich lerne jeden Tag neue Wörter.', exampleTr: 'Her gün yeni kelimeler öğreniyorum.', note: 'Motivasyon cümlesi.', category: 'Günlük Cümleler'),
    _entry(de: 'Bitte sprechen Sie langsam.', tr: 'Lütfen yavaş konuşun.', pron: 'bite şprehın zii langzaam', exampleDe: 'Bitte sprechen Sie langsam, ich lerne noch.', exampleTr: 'Lütfen yavaş konuşun, hâlâ öğreniyorum.', note: 'Gerçek hayatta çok iş yapar.', category: 'Günlük Cümleler'),
    _entry(de: 'Ich verstehe das nicht.', tr: 'Bunu anlamıyorum.', pron: 'ih ferştee das niht', exampleDe: 'Entschuldigung, ich verstehe das nicht.', exampleTr: 'Affedersiniz, bunu anlamıyorum.', note: 'Kriz anı cümlesi.', category: 'Günlük Cümleler'),
    _entry(de: 'Kannst du mir helfen?', tr: 'Bana yardım edebilir misin?', pron: 'kanst du mia helfın', exampleDe: 'Kannst du mir bitte helfen?', exampleTr: 'Lütfen bana yardım edebilir misin?', note: 'Hem işte hem günlük hayatta lazım.', category: 'Günlük Cümleler'),
    _entry(de: 'Ich habe heute keine Zeit.', tr: 'Bugün vaktim yok.', pron: 'ih haabe hoytı kaynı tsayt', exampleDe: 'Ich habe heute keine Zeit, vielleicht morgen.', exampleTr: 'Bugün vaktim yok, belki yarın.', note: 'Nazikçe reddetme cümlesi.', category: 'Günlük Cümleler'),
    _entry(de: 'Wo ist der Bahnhof?', tr: 'İstasyon nerede?', pron: 'vo ist dea baanhof', exampleDe: 'Entschuldigung, wo ist der Bahnhof?', exampleTr: 'Affedersiniz, istasyon nerede?', note: 'Yol sorma cümlesi.', category: 'Günlük Cümleler'),
    _entry(de: 'Bis später, mach’s gut.', tr: 'Sonra görüşürüz, kendine iyi bak.', pron: 'bis şpeeter mahs guut', exampleDe: 'Okay, bis später, mach’s gut.', exampleTr: 'Tamam, sonra görüşürüz, kendine iyi bak.', note: 'Samimi kapanış cümlesi.', category: 'Günlük Cümleler'),
    _entry(de: 'Wie heißt du?', tr: 'Adın ne?', pron: 'vi hayst du', exampleDe: 'Hallo, wie heißt du?', exampleTr: 'Merhaba, adın ne?', note: 'Tanışmanın temel taşı.', category: 'Günlük Cümleler'),
    _entry(de: 'Ich bin dreißig Jahre alt.', tr: 'Otuz yaşındayım.', pron: 'ih bin draysig yaare alt', exampleDe: 'Ich bin dreißig Jahre alt und arbeite viel.', exampleTr: 'Otuz yaşındayım ve çok çalışıyorum.', note: 'Yaş söylemek için ezberlik cümle.', category: 'Günlük Cümleler'),
    _entry(de: 'Heute ist Dienstag, der achte April.', tr: 'Bugün Salı, sekiz Nisan.', pron: 'hoytı ist diinstaak dea ahtı april', exampleDe: 'Heute ist Dienstag, der achte April.', exampleTr: 'Bugün Salı, sekiz Nisan.', note: 'Gün ve tarih birlikte kurulur.', category: 'Günlük Cümleler'),
    _entry(de: 'Meine Nummer ist null eins zwei drei.', tr: 'Numaram sıfır bir iki üç.', pron: 'maynı numır ist nul ayns tsvay drii', exampleDe: 'Meine Nummer ist null eins zwei drei.', exampleTr: 'Numaram sıfır bir iki üç.', note: 'Sayıları tek tek net söyle.', category: 'Günlük Cümleler'),
    _entry(de: 'Im Winter ist es kalt, aber im Sommer ist es warm.', tr: 'Kışın hava soğuk, ama yazın sıcak.', pron: 'im vintır ist es kalt aba im zomır ist es varm', exampleDe: 'Im Winter ist es kalt, aber im Sommer ist es warm.', exampleTr: 'Kışın hava soğuk ama yazın sıcak.', note: 'Mevsim ve hava cümlesi.', category: 'Günlük Cümleler'),
  ];
}
