// lib/services/memory_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/memory.dart';

class MemoryService {
  final String baseUrl = 'http://127.0.0.1:5000/api';  
  //final String baseUrl = 'http://localhost:5000/api';
  
  // Use a test patient ID for now
  final String testPatientId = '11111111-1111-1111-1111-111111111111'; // Replace with actual ID
  
  Future<List<Memory>> getPatientMemories() async {
    try {
      print('Requesting memories from: $baseUrl/memories/user/$testPatientId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/memories/user/$testPatientId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['memories'] as List)
            .map((m) => Memory.fromJson(m))
            .toList();
      } else {
        throw Exception('Failed to load memories');
      }
    } catch (e) {
      print('Exception details: $e');
      throw Exception('Error getting memories: $e');
    }
  }
}