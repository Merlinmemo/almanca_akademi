import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class CertificateScreen extends StatelessWidget {
  final String studentName;
  final String moduleTitle;
  final String moduleCode;
  final int totalXp;

  const CertificateScreen({
    super.key,
    required this.studentName,
    required this.moduleTitle,
    required this.moduleCode,
    required this.totalXp,
  });

  @override
  Widget build(BuildContext context) {
    final p = ProgressService();

    return Scaffold(
      appBar: AppBar(title: const Text("Sertifika")),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: FutureBuilder<String?>(
          future: p.getModuleCompletedDate(moduleCode),
          builder: (context, snap) {
            final date = snap.data ?? "—";

            return Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Icon(Icons.workspace_premium, size: 54),
                        const SizedBox(height: 10),
                        const Text(
                          "TAMAMLAMA SERTİFİKASI",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            children: [
                              const Text("Bu sertifika şunadır:", style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 6),
                              Text(studentName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 10),
                              Text(moduleTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                              const SizedBox(height: 10),
                              Text("Tarih: $date", style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 6),
                              Text("Toplam XP: $totalXp", style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Bu belge, modülü başarıyla tamamladığını doğrular.",
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text("Ana Ekrana Dön"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}