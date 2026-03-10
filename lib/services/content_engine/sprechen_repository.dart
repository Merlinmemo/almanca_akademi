import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../../models/generated_content_models.dart';
import 'sentence_engine.dart';

/// SprechenRepository
/// - assets/data/sprechen/sprechen_<moduleCode>.json okur.
/// - Yoksa sprechen_default.json
/// - Yoksa SentenceEngine fallback
///
/// ÖNEMLİ:
/// - JSON'dan okunan "tüm" pattern'ları cache'ler.
/// - loadRandom her çağrıda cache'den rastgele subset üretir (aynı 10 takılmasın).
class SprechenRepository {
  SprechenRepository._();
  static final SprechenRepository I = SprechenRepository._();

  final Map<String, List<SentencePattern>> _fullCache = {}; // moduleCode -> all patterns

  Future<List<SentencePattern>> loadRandom({
    required String moduleCode,
    int level = 4,
    int count = 10,
  }) async {
    final all = await _loadAll(moduleCode: moduleCode, level: level);

    if (all.isEmpty) return const [];

    // Random subset (fresh on each call)
    final rnd = Random(DateTime.now().microsecondsSinceEpoch);
    final copy = List<SentencePattern>.from(all);
    copy.shuffle(rnd);

    if (copy.length <= count) return copy;
    return copy.take(count).toList();
  }

  Future<List<SentencePattern>> _loadAll({required String moduleCode, int level = 4}) async {
    if (_fullCache.containsKey(moduleCode)) return _fullCache[moduleCode]!;

    final modulePath = 'assets/data/sprechen/sprechen_$moduleCode.json';
    final defaultPath = 'assets/data/sprechen/sprechen_default.json';

    List<SentencePattern> patterns = await _tryLoadFromAsset(modulePath);
    if (patterns.isEmpty) {
      patterns = await _tryLoadFromAsset(defaultPath);
    }

    if (patterns.isEmpty) {
      patterns = SentenceEngine.I.generatePatternSet(moduleCode: moduleCode, level: level, count: 50);
    }

    _fullCache[moduleCode] = patterns;
    return patterns;
  }

  Future<List<SentencePattern>> _tryLoadFromAsset(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map((m) => _patternFromJson(m))
          .where((p) => p.practiceOptions.isNotEmpty && p.exampleDe.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  SentencePattern _patternFromJson(Map<String, dynamic> m) {
    final options = (m['practiceOptions'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];

    return SentencePattern(
      title: (m['title'] ?? '').toString(),
      exampleDe: (m['exampleDe'] ?? '').toString(),
      exampleTr: (m['exampleTr'] ?? '').toString(),
      microRuleTitle: (m['microRuleTitle'] ?? 'Kural').toString(),
      microRuleText: (m['microRuleText'] ?? '').toString(),
      practiceOptions: options,
      correctIndex: (m['correctIndex'] is int) ? (m['correctIndex'] as int) : int.tryParse('${m['correctIndex']}') ?? 0,
    );
  }
}