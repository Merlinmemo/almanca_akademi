class QuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });
}

const quizPoolData = [
  QuizQuestion(question: '“eins” ne demek?', options: ['bir', 'iki', 'üç', 'on'], answer: 'bir'),
  QuizQuestion(question: '“Guten Tag” ne demek?', options: ['İyi geceler', 'İyi günler', 'Günaydın', 'Hoşça kal'], answer: 'İyi günler'),
  QuizQuestion(question: '“ich” ne demek?', options: ['sen', 'biz', 'ben', 'onlar'], answer: 'ben'),
  QuizQuestion(question: '“sein” ne demek?', options: ['gelmek', 'olmak', 'okumak', 'gitmek'], answer: 'olmak'),
  QuizQuestion(question: '“der Mann” ne demek?', options: ['kadın', 'masa', 'adam', 'çocuk'], answer: 'adam'),
];
