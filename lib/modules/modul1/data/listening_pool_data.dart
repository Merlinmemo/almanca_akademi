class ListeningQuestion {
  final String german;
  final String correct;
  final List<String> options;
  final String pronunciation;

  const ListeningQuestion({
    required this.german,
    required this.correct,
    required this.options,
    required this.pronunciation,
  });
}

const listeningPoolData = [
  ListeningQuestion(german: 'Guten Morgen', correct: 'Günaydın', options: ['Günaydın', 'İyi akşamlar', 'Hoşça kal'], pronunciation: 'gu:tın morgın'),
  ListeningQuestion(german: 'Ich lerne Deutsch.', correct: 'Almanca öğreniyorum.', options: ['Almanca öğreniyorum.', 'Ben Almanya’da yaşıyorum.', 'Ben çalışıyorum.'], pronunciation: 'ih lernı doyş'),
  ListeningQuestion(german: 'Wie heißt du?', correct: 'Adın ne?', options: ['Nerelisin?', 'Adın ne?', 'Kaç yaşındasın?'], pronunciation: 'vi haysst du'),
  ListeningQuestion(german: 'Danke schön.', correct: 'Çok teşekkür ederim.', options: ['Lütfen.', 'Çok teşekkür ederim.', 'Görüşürüz.'], pronunciation: 'danke şö:n'),
];
