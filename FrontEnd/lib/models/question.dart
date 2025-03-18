class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final int difficulty;
  final int points;
  
  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.difficulty,
    required this.points,
  });
            
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correct_option_index'],
      difficulty: json['difficulty'],
      points: json['points'],
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