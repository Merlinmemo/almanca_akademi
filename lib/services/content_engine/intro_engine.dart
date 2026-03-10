import 'dart:math';

class IntroBriefing {
  final String headline;
  final String summaryTr;
  final List<String> goalsTr;
  final List<String> rulesTr;
  final String motivationTr;

  const IntroBriefing({
    required this.headline,
    required this.summaryTr,
    required this.goalsTr,
    required this.rulesTr,
    required this.motivationTr,
  });
}

class IntroEngine {
  IntroEngine._();
  static final IntroEngine I = IntroEngine._();

  IntroBriefing generate({
    required String moduleCode,
  }) {
    final rnd = Random();

    final bank = _bankFor(moduleCode);
    final pick = bank[rnd.nextInt(bank.length)];
    return pick;
  }

  Random _seeded(String s) => Random(_hash32(s));

  int _hash32(String s) {
    int h = 2166136261;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 16777619) & 0x7fffffff;
    }
    return h;
  }

  List<IntroBriefing> _bankFor(String moduleCode) {
    switch (moduleCode) {
      case "modul4":
        return _shopping();
      case "modul5":
        return _daily();
      case "modul8":
        return _work();
      default:
        return _core();
    }
  }

  List<IntroBriefing> _core() => const [
        IntroBriefing(
          headline: "Modül Başlangıcı: Temel Konuşma",
          summaryTr:
              "Bu modül, en temel cümle kurma refleksini başlatır. Hedef: kısa, net, doğru sırayla konuşmak.",
          goalsTr: [
            "Selamlaşma ve kendini tanıtma",
            "Basit fiillerle cümle kurma",
            "Dinleyip anlamı seçme",
            "Kısa konuşma görevleri",
          ],
          rulesTr: [
            "Günde 15 dk bile yeter; önemli olan süreklilik.",
            "Bilmiyorsan çekinme: önce dinle, sonra tekrar et.",
            "Hız değil doğruluk: cümle düzeni otursun.",
          ],
          motivationTr: "Bugün 1 adım atıyorsun. Almanya’da o adım, kapı açar.",
        ),
      ];

  List<IntroBriefing> _shopping() => const [
        IntroBriefing(
          headline: "Modül: Alışveriş",
          summaryTr:
              "Market/dükkan senaryoları. Hedef: temel kelimeler + fiyat sorma + basit istek cümleleri.",
          goalsTr: [
            "Gıda ve market kelimeleri",
            "‘Bu ne kadar?’ kalıbı",
            "Satın alma cümleleri",
            "Dinleme: kısa market cümleleri",
          ],
          rulesTr: [
            "Kelimeleri ezberleme; 3 kez gör → 1 kez söyle.",
            "Yanlış normal. Önemli olan aynı hatayı sürdürmemek.",
          ],
          motivationTr: "Kasada takılmayacaksın. Cümle kısa, özgüven büyük.",
        ),
      ];

  List<IntroBriefing> _daily() => const [
        IntroBriefing(
          headline: "Modül: Günlük Hayat",
          summaryTr:
              "Günlük rutin: kalkmak, yemek, mola, gitmek… Hedef: günlük cümleleri otomatikleştirmek.",
          goalsTr: [
            "Rutin fiillerle cümle kurma",
            "Zaman ifadeleri (bugün/yarın/şimdi)",
            "Dinleme + tekrar",
            "Konuşma: günlük 3 cümle",
          ],
          rulesTr: [
            "Cümleyi önce oku, sonra dinle, sonra kendin söyle.",
            "TTS’yi sonuna kadar dinle; yarım bırakma.",
          ],
          motivationTr: "Dil, günlük hayatla öğrenilir. Günlük hayatı ele geçiriyoruz.",
        ),
      ];

  List<IntroBriefing> _work() => const [
        IntroBriefing(
          headline: "Modül: İş",
          summaryTr:
              "İş ortamı: ofis/şantiye, toplantı, rapor, zaman… Hedef: iş cümlelerinde rahatlık.",
          goalsTr: [
            "İş ortamı kelimeleri",
            "Basit iş cümleleri",
            "Dinleme: iş senaryosu",
            "Konuşma: işte 2-3 cümle",
          ],
          rulesTr: [
            "İş dili net olur: kısa cümle kur, doğru telaffuz et.",
            "Hata yaparsan düzelt ve devam et; durmak yok.",
          ],
          motivationTr: "Ustalık elinde. Dil de eline geçecek.",
        ),
      ];
}