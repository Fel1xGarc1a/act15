class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    String decodedQuestion = _decodeHtmlEntities(json['question']);
    String decodedCorrectAnswer = _decodeHtmlEntities(json['correct_answer']);
    
    List<String> decodedIncorrectAnswers = List<String>.from(
      json['incorrect_answers'].map((answer) => _decodeHtmlEntities(answer))
    );
    
    List<String> options = [...decodedIncorrectAnswers, decodedCorrectAnswer];
    options.shuffle();

    return Question(
      question: decodedQuestion,
      options: options,
      correctAnswer: decodedCorrectAnswer,
    );
  }
  
  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#039;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rdquo;', '"')
        .replaceAll('&ldquo;', '"');
  }
} 