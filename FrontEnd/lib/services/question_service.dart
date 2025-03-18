import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class QuestionService {
  final String baseUrl = 'http://localhost:5000/api'; // Change to your server IP

  Future<List<Question>> getMemoryQuestions(String memoryId) async {
    // For testing: use a known patient ID
    final String testPatientId = '00000000-0000-0000-0000-000000000000';
    
    final response = await http.get(
      Uri.parse('$baseUrl/questions/memory/$memoryId?patient_id=$testPatientId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['questions'] as List).map((q) => Question.fromJson(q)).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }
}