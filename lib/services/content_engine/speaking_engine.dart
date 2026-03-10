import 'dart:math';

class SpeakingTask {
  final String title;
  final String instructionTr;
  final String exampleDe;
  final String exampleTr;

  const SpeakingTask({
    required this.title,
    required this.instructionTr,
    required this.exampleDe,
    required this.exampleTr,
  });
}

class SpeakingEngine {
  SpeakingEngine._();
  static final SpeakingEngine I = SpeakingEngine._();

  List<SpeakingTask> generateTasks({
    required String moduleCode,
    int count = 8,
  }) {
    final rnd = Random();

    final bank = _bankFor(moduleCode);
    final tasks = <SpeakingTask>[];

    for (int i = 0; i < count; i++) {
      final t = bank[rnd.nextInt(bank.length)];
      tasks.add(t);
    }

    // aynı task ard arda gelmesin diye
    tasks.shuffle(rnd);
    return tasks;
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

  List<SpeakingTask> _bankFor(String moduleCode) {
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

  List<SpeakingTask> _core() => const [
        SpeakingTask(
          title: "Kendini tanıt",
          instructionTr: "Kısa tanıtım yap. Adını söyle ve Almanca öğrendiğini söyle.",
          exampleDe: "Hallo! Ich heiße Mehmet. Ich lerne Deutsch.",
          exampleTr: "Merhaba! Benim adım Mehmet. Ben Almanca öğreniyorum.",
        ),
        SpeakingTask(
          title: "Nerede olduğunu söyle",
          instructionTr: "Şu an nerede olduğunu söyle.",
          exampleDe: "Ich bin zu Hause.",
          exampleTr: "Ben evdeyim.",
        ),
        SpeakingTask(
          title: "Bugün ne yapıyorsun?",
          instructionTr: "Bugün ne yaptığını söyle (1 cümle).",
          exampleDe: "Heute arbeite ich.",
          exampleTr: "Bugün çalışıyorum.",
        ),
        SpeakingTask(
          title: "Teşekkür et",
          instructionTr: "Nezaket cümlesi kur: teşekkür et ve rica ederim de.",
          exampleDe: "Danke! Bitte!",
          exampleTr: "Teşekkürler! Rica ederim!",
        ),
      ];

  List<SpeakingTask> _shopping() => const [
        SpeakingTask(
          title: "Marketteyim",
          instructionTr: "Markete gittiğini söyle.",
          exampleDe: "Ich gehe in den Supermarkt.",
          exampleTr: "Markete gidiyorum.",
        ),
        SpeakingTask(
          title: "Satın alıyorum",
          instructionTr: "Ekmek ve su aldığını söyle.",
          exampleDe: "Ich kaufe Brot und Wasser.",
          exampleTr: "Ekmek ve su satın alıyorum.",
        ),
        SpeakingTask(
          title: "Fiyat sor",
          instructionTr: "Fiyat sorusu sor.",
          exampleDe: "Wie viel kostet das?",
          exampleTr: "Bu ne kadar?",
        ),
      ];

  List<SpeakingTask> _daily() => const [
        SpeakingTask(
          title: "Kahvaltı",
          instructionTr: "Kahvaltı yaptığını söyle.",
          exampleDe: "Ich mache Frühstück.",
          exampleTr: "Kahvaltı yapıyorum.",
        ),
        SpeakingTask(
          title: "Mola",
          instructionTr: "Mola verdiğini söyle.",
          exampleDe: "Ich mache eine Pause.",
          exampleTr: "Mola veriyorum.",
        ),
        SpeakingTask(
          title: "Park",
          instructionTr: "Parka gittiğini söyle.",
          exampleDe: "Ich gehe in den Park.",
          exampleTr: "Parka gidiyorum.",
        ),
      ];

  List<SpeakingTask> _work() => const [
        SpeakingTask(
          title: "Ofisteyim",
          instructionTr: "Ofiste çalıştığını söyle.",
          exampleDe: "Ich arbeite im Büro.",
          exampleTr: "Ofiste çalışıyorum.",
        ),
        SpeakingTask(
          title: "Toplantı",
          instructionTr: "Toplantı yaptığını söyle.",
          exampleDe: "Wir machen ein Meeting.",
          exampleTr: "Biz toplantı yapıyoruz.",
        ),
        SpeakingTask(
          title: "Rapor",
          instructionTr: "Rapor hazırladığını söyle.",
          exampleDe: "Ich mache einen Bericht.",
          exampleTr: "Rapor hazırlıyorum.",
        ),
      ];
}
