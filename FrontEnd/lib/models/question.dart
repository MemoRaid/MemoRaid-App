class Question {
  final String id;
  final String question;
  final List<String> options;
  final int difficulty;
  final int points;
  final int correctOptionIndex;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.difficulty,
    required this.points,
    required this.correctOptionIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question_text'],
      options: List<String>.from(json['options']),
      difficulty: json['difficulty_level'],
      points: json['points'],
      correctOptionIndex: json['correct_option_index'],
    );
  }
}

class Memory {
  final String id;
  final String photoUrl;
  final String briefDescription;

  Memory({
    required this.id,
    required this.photoUrl,
    required this.briefDescription,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'],
      photoUrl: json['photo_url'],
      briefDescription: json['brief_description'],
    );
  }
}