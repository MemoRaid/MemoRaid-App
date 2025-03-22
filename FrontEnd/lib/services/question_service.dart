import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../memoraid_features/services/api_service.dart';

class QuestionService {
  final String baseUrl = 'http://127.0.0.1:5001/api';
  final ApiService _apiService = ApiService();

  Future<List<Question>> getMemoryQuestions(String memoryId) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) throw Exception('Not authenticated');

      print('Requesting questions for memory: $memoryId');

      final response = await http.get(
        Uri.parse('$baseUrl/questions/memory/$memoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
      final token = await _apiService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/quiz-results'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'memory_id': memoryId,
          'score': score,
          'correct_answers': correctAnswers,
          'total_questions': totalQuestions,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error saving quiz results: $e');
      return false;
    }
  }
}
