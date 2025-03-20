import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userData => _userData;

  // Initialize auth state on app start
  Future<void> init() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      try {
        final response = await _apiService.getUserProfile();
        _userData = response['user'];
        _isAuthenticated = true;
        notifyListeners();
      } catch (e) {
        await _storage.delete(key: 'jwt_token');
        _isAuthenticated = false;
      }
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await _apiService.googleSignIn(googleAuth.idToken!);

      await _apiService.setToken(response['token']);

      _userData = response['user'];
      _isAuthenticated = true;
      notifyListeners();

      return true;
    } catch (e) {
      print('Google sign-in error: $e');
      return false;
    }
  }

  // Regular email/password login
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);

      await _apiService.setToken(response['token']);

      _userData = response['user'];
      _isAuthenticated = true;
      notifyListeners();

      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final userData = {'name': name, 'email': email, 'password': password};

      print("Sending registration data to API: $userData");
      final response = await _apiService.register(userData);

      await _apiService.setToken(response['token']);

      _userData = response['user'];
      _isAuthenticated = true;
      notifyListeners();

      return true;
    } catch (e) {
      print('Registration error in auth service: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _apiService.removeToken();
    _isAuthenticated = false;
    _userData = null;
    notifyListeners();
  }

  // Add as new method
  Future<Map<String, dynamic>> registerWithVerification(
    String name,
    String email,
    String password,
  ) async {
    try {
      final userData = {
        'name': name,
        'email': email,
        'password': password,
        'requireVerification': true,
      };

      print("Sending registration data with verification flag: $userData");
      final response = await _apiService.register(userData);

      // Check if verification is required from response
      if (response['verificationRequired'] == true) {
        return {
          'status': 'verification_required',
          'message': 'Please check your email for verification code',
          'email': email,
        };
      }

      // If no verification needed, proceed as normal
      await _apiService.setToken(response['token']);
      _userData = response['user'];
      _isAuthenticated = true;
      notifyListeners();

      return {'status': 'success'};
    } catch (e) {
      print('Registration error in auth service: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // Add as new method
  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      final response = await _apiService.verifyEmail(email, code);

      if (response['success'] == true) {
        // If verification successful and returns token/user data
        if (response['token'] != null) {
          await _apiService.setToken(response['token']);
          _userData = response['user'];
          _isAuthenticated = true;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
     
      return false;
    }
  }

  // Add as new method to AuthService class
  Future<bool> requestEmailVerification(String email) async {
    try {
      await _apiService.requestEmailVerification(email);
      return true;
    } catch (e) {
      print('Request email verification error: $e');
      return false;
    }
  }
}
