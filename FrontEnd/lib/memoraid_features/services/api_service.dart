import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Replace with your backend URL
  static const String baseUrl =
      'http://localhost:5000/api'; // Your local network IP // Your local network IP
  // For Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // For iOS simulator

  final storage = const FlutterSecureStorage();

  // Get stored JWT token
  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  // Store JWT token
  Future<void> setToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  // Remove token (logout)
  Future<void> removeToken() async {
    await storage.delete(key: 'jwt_token');
  }

  // GET request
  Future<dynamic> get(String endpoint) async {
    final token = await getToken();
    print("DEBUGGING - Token for GET: $token"); // Debug print
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }

  // POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    print("DEBUGGING - Token for POST to $endpoint: $token"); // Debug print
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    return _handleResponse(response);
  }

  // Handle response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Google Sign-In
  Future<dynamic> googleSignIn(String idToken) async {
    return await post('auth/google', {'idToken': idToken});
  }

  // Email/Password Login
  Future<dynamic> login(String email, String password) async {
    return await post('auth/login', {'email': email, 'password': password});
  }

  // Registration
  Future<dynamic> register(Map<String, dynamic> userData) async {
    print("Attempting to register with data: $userData");
    try {
      final response = await post('auth/register', userData);
      print("Registration successful: $response");
      return response;
    } catch (e) {
      print("Registration error: $e");
      rethrow;
    }
  }

  // Get user profile
  Future<dynamic> getUserProfile() async {
    return await get('auth/me');
  }

  // Add as new methods to your ApiService class
  Future<dynamic> requestEmailVerification(String email) async {
    return await post('auth/request-verification', {'email': email});
  }

  Future<dynamic> verifyEmail(String email, String verificationCode) async {
    return await post('auth/verify-email', {
      'email': email,
      'code': verificationCode,
    });
  }
}