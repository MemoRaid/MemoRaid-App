import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class QuestionService {
  final String baseUrl = 'http://127.0.0.1:5000/api';
  
  // Use SAME patient ID as in memory_service.dart
  final String testPatientId = '11111111-1111-1111-1111-111111111111';
  
  Future<List<Question>> getMemoryQuestions(String memoryId) async {
    try {
      print('Requesting questions for memory: $memoryId with patient: $testPatientId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/questions/memory/$memoryId?patient_id=$testPatientId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['questions'] as List)
            .map((q) => Question.fromJson(q))
            .toList();
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting questions: $e');
      throw Exception('Error getting questions: $e');
    }
  }

  Future<bool> saveQuizResults({
    required String memoryId,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    try {
      print('Saving quiz results for memory: $memoryId, score: $score');
      
      final response = await http.post(
        Uri.parse('$baseUrl/quiz-results'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_id': testPatientId,
          'memory_id': memoryId,
          'score': score,
          'correct_answers': correctAnswers,
          'total_questions': totalQuestions,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error saving quiz results: $e');
      return false;
    }
  }
}