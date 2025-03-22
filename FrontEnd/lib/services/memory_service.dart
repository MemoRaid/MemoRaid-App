// lib/services/memory_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/memory.dart';
import '../memoraid_features/services/api_service.dart';

class MemoryService {
  final String baseUrl = 'http://127.0.0.1:5000/api';
  final ApiService _apiService = ApiService();

  Future<List<Memory>> getPatientMemories() async {
    try {
      // Get JWT token from secure storage via API service
      final token = await _apiService.getToken();
      if (token == null) throw Exception('Not authenticated');

      // Use the /me endpoint which will extract user ID from token on backend
      final response = await http.get(
        Uri.parse('$baseUrl/memories/user/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['memories'] as List)
            .map((m) => Memory.fromJson(m))
            .toList();
      } else {
        throw Exception('Failed to load memories: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception details: $e');
      throw Exception('Error getting memories: $e');
    }
  }
}
