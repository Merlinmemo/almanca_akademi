import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/tts_service.dart';

class RepeatPackScreen extends StatelessWidget {
  final String title;
  final List<WordItem> wrongWords;

  const RepeatPackScreen({
    super.key,
    required this.title,
    required this.wrongWords,
  });

  Future<void> _speak(String de) async => TtsService.I.speakDe(de);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tekrar Paketi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text("Yanlış yaptığın kelimeler burada. Dinle → oku → tekrar et.",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    Text("Toplam: ${wrongWords.length}", style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: wrongWords.isEmpty
                  ? const Center(child: Text("Yanlış kelime yok. Temiz iş ✅"))
                  : ListView.builder(
                      itemCount: wrongWords.length,
                      itemBuilder: (context, i) {
                        final w = wrongWords[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(w.de, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                      const SizedBox(height: 6),
                                      Text("Okunuş: ${w.trPron}", style: const TextStyle(color: Colors.white70)),
                                      const SizedBox(height: 6),
                                      Text("Türkçe: ${w.tr}", style: const TextStyle(fontWeight: FontWeight.w700)),
                                      if (w.group != null && w.group!.trim().isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text("Kategori: ${w.group}", style: const TextStyle(color: Colors.white60)),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(icon: const Icon(Icons.volume_up), onPressed: () => _speak(w.de)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Geri Dön")),
            ),
          ],
        ),
      ),
    );
  }
}