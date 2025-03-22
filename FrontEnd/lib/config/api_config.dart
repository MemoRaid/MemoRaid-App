import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;

class APIConfig {
  // Manual API key backup in case dotenv fails
  static String _manualApiKey = '';

  // Flag to track if we've attempted to initialize dotenv
  static bool _dotenvInitAttempted = false;

  // Get API key with better error handling
  static String get geminiApiKey {
    try {
      // First check if we have a manually set key
      if (_manualApiKey.isNotEmpty) {
        return _manualApiKey;
      }

      // Try to get the API key from dotenv
      if (isDotEnvInitialized()) {
        final key = dotenv.env['GEMINI_API_KEY'] ?? '';
        if (key.isNotEmpty) {
          return key;
        }
      }

      // Hard-coded fallback key - replace with your actual API key if dotenv keeps failing
      const fallbackApiKey = ''; // Add your API key here as a last resort
      if (fallbackApiKey.isNotEmpty) {
        print('⚠️ Using hard-coded fallback API key');
        return fallbackApiKey;
      }

      print('❌ Failed to get API key from any source');
      return '';
    } catch (e) {
      print('❌ Error accessing API key: $e');
      return '';
    }
  }

  // Allow manual setting of API key as fallback
  static void setApiKey(String key) {
    _manualApiKey = key;
    print('✅ API key manually set');
    // Reset initialization flags to try again with the new key
    _apiInitialized = false;
    _apiInitFailed = false;
  }

  // Initialize dotenv package
  static Future<bool> initializeDotenv() async {
    if (_dotenvInitAttempted) {
      return isDotEnvInitialized();
    }

    _dotenvInitAttempted = true;

    try {
      print('🔄 Initializing dotenv...');

      // Try to load from different possible locations
      const envPaths = [
        '.env',
        'assets/.env',
        '../.env',
        '../../.env',
      ];

      bool loaded = false;

      // Check if files exist before attempting to load
      for (var path in envPaths) {
        try {
          print('🔍 Checking for .env file at: $path');
          await dotenv.load(fileName: path);
          print('✅ Successfully loaded .env from: $path');
          loaded = true;
          break;
        } catch (e) {
          print('⚠️ Failed to load .env from $path: $e');
        }
      }

      if (!loaded) {
        print('⚠️ Could not find .env file. Trying to create a default one...');
        // If you want to create a default .env file, you could do so here
      }

      return isDotEnvInitialized();
    } catch (e) {
      print('❌ Error initializing dotenv: $e');
      return false;
    }
  }

  // Static initialize method to be called at app startup
  static Future<void> initialize() async {
    print('🚀 Initializing APIConfig...');

    // Try to initialize dotenv
    final dotenvInitialized = await initializeDotenv();
    print('📊 dotenv initialized: $dotenvInitialized');

    if (dotenvInitialized) {
      print('📋 Environment variables:');
      dotenv.env.forEach((key, value) {
        if (!key.contains('KEY') && !key.contains('SECRET')) {
          print('   $key: $value');
        } else {
          print('   $key: ****');
        }
      });
    }

    // Initialize models
    await listModels();
  }

  static const String geminiApiUrlBase =
      'https://generativelanguage.googleapis.com/v1';
  static const String modelsEndpoint = '$geminiApiUrlBase/models';

  // Define stable models that have high probability of working
  // Updated to remove deprecated models and prioritize newer models
  static const String STABLE_MODEL = 'models/gemini-1.5-flash';
  static const List<String> STABLE_MODELS = [
    'models/gemini-1.5-flash', // Recommended replacement for gemini-pro-vision
    'models/gemini-pro', // Still a stable fallback
  ];

  // Track API initialization status
  static bool _apiInitialized = false;
  static bool _apiInitFailed = false;

  // Pre-populate with stable models to ensure we always have something to use
  static List<String> recommendedModels = List.from(STABLE_MODELS);

  // Get the preferred model name
  static String getPreferredModelName() {
    // Return the first compatible model
    if (recommendedModels.isNotEmpty) {
      return recommendedModels.first;
    }

    // This is a double fallback in case recommendedModels got emptied somehow
    return STABLE_MODEL;
  }

  // Enhanced API key validation
  static bool isApiKeyValid() {
    final key = geminiApiKey;
    if (key.isEmpty) {
      print(
          '❌ API key is empty. Please check your .env file or set key manually.');
      return false;
    }

    if (key.length < 10) {
      print('❌ API key appears too short: ${key.length} characters');
      return false;
    }

    return true;
  }

  // Check dotenv initialization status
  static bool isDotEnvInitialized() {
    try {
      return dotenv.isInitialized;
    } catch (e) {
      print('❌ Error checking dotenv initialization: $e');
      return false;
    }
  }

  // Initialize API and validate key
  static Future<bool> initializeAPI() async {
    // Try to initialize dotenv first if it hasn't been attempted
    if (!_dotenvInitAttempted) {
      await initializeDotenv();
    }

    if (_apiInitialized) return true;
    if (_apiInitFailed) return false;

    // First check if API key appears valid
    if (!isApiKeyValid()) {
      _apiInitFailed = true;
      return false;
    }

    try {
      final key = geminiApiKey;
      if (key.isEmpty) {
        print('❌ API key is empty');
        _apiInitFailed = true;
        return false;
      }

      print(
          '🔑 Using API key: ${key.substring(0, min(5, key.length))}... (${key.length} chars)');

      // Add timeout to prevent hanging
      final response = await http
          .get(
        Uri.parse('$modelsEndpoint?key=$geminiApiKey'),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('❌ API initialization timed out');
          return http.Response('{"error":"timeout"}', 408);
        },
      );

      if (response.statusCode == 200) {
        _apiInitialized = true;
        print('✅ API initialized successfully');
        return true;
      } else {
        _apiInitFailed = true;
        print('❌ API initialization failed: Status ${response.statusCode}');
        print('Response: ${response.body}');

        // Check if error is related to API key
        if (response.body.contains("API key not valid")) {
          print('❌ Invalid API key. Please check your Gemini API key.');
        }

        return false;
      }
    } catch (e) {
      _apiInitFailed = true;
      print('❌ API initialization error: $e');

      // Add more detailed logging for NotInitializedError
      if (e.toString().contains('NotInitializedError')) {
        print('📢 CRITICAL: NotInitializedError detected');
        print('   Possible causes:');
        print(
            '   1. The dotenv package is not initialized - check if dotenv.load() was called');
        print('   2. The .env file is missing or has incorrect format');
        print('   3. There might be a problem with the Flutter asset loading');
        print('');
        print(
            '   Try setting the API key manually with APIConfig.setApiKey("your-api-key")');
      }

      return false;
    }
  }

  // Helper function for min operation
  static int min(int a, int b) => (a < b) ? a : b;

  // Fetch available models from API
  static Future<List<String>> getAvailableModels() async {
    try {
      // Try to initialize the API first
      final isInitialized = await initializeAPI();
      if (!isInitialized) {
        print('⚠️ API not initialized, using stable models as fallback');
        // Ensure recommendedModels contains stable models
        recommendedModels = List.from(STABLE_MODELS);
        return STABLE_MODELS;
      }

      final response = await http.get(
        Uri.parse('$modelsEndpoint?key=$geminiApiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List<dynamic>? ?? [];

        List<String> modelNames =
            models.map((model) => model['name'].toString()).toList();
        print('✅ Available Models: $modelNames');

        // Store recommended models in order of preference
        recommendedModels = _filterRecommendedModels(modelNames);

        return modelNames;
      } else {
        print('❌ Failed to fetch models: ${response.statusCode}');
        print('Response: ${response.body}');

        // Set recommended models to stable models as fallback
        recommendedModels = List.from(STABLE_MODELS);
        return STABLE_MODELS;
      }
    } catch (e) {
      print('❌ Error fetching models: $e');

      // Set recommended models to stable models as fallback
      recommendedModels = List.from(STABLE_MODELS);
      return STABLE_MODELS;
    }
  }

  // Filter and sort models by preference
  static List<String> _filterRecommendedModels(List<String> allModels) {
    // Priority order for models (newest/best first)
    final preferenceOrder = [
      'models/gemini-1.5-flash', // Recommended replacement for vision
      'models/gemini-1.5-pro', // Good for complex tasks
      'models/gemini-2.0-flash', // Newer model but check compatibility
      'models/gemini-pro', // Legacy but reliable
    ];

    // Build a list based on preference order
    List<String> filteredModels = [];

    for (String preferredModel in preferenceOrder) {
      // Find models that match or start with the preferred model name
      for (String model in allModels) {
        if (model.startsWith(preferredModel)) {
          filteredModels.add(model);
          // Print when we find a match
          print('✅ Found compatible model: $model');
        }
      }
    }

    // If we couldn't find any matches, add any available model as fallback
    // but exclude embedding models and deprecated models which don't support chat
    if (filteredModels.isEmpty && allModels.isNotEmpty) {
      for (String model in allModels) {
        if (!model.contains('embedding') &&
            !model.contains(
                'vision') && // Skip vision models as they're likely deprecated
            !model.contains('deprecated')) {
          filteredModels.add(model);
          print('⚠️ Using fallback model: $model');
        }
      }
    }

    // If we still have no models, ensure we include at least the stable model
    if (filteredModels.isEmpty) {
      filteredModels.add(STABLE_MODEL);
      print('⚠️ Using ultimate fallback model: $STABLE_MODEL');
    }

    if (filteredModels.isNotEmpty) {
      print('✅ Recommended models (in order): $filteredModels');
    } else {
      print('❌ No compatible models found!');
    }

    return filteredModels;
  }

  // List available models and their supported methods
  static Future<void> listModels() async {
    try {
      // If dotenv isn't initialized yet, try to initialize it
      if (!_dotenvInitAttempted) {
        await initializeDotenv();
      }

      print('🔍 Starting model discovery...');
      print('📊 dotenv initialized: ${isDotEnvInitialized()}');
      print('🔑 API key available: ${geminiApiKey.isNotEmpty ? "Yes" : "No"}');

      final models = await getAvailableModels();
      if (models.isEmpty) {
        print('❌ No available models found.');
        return;
      }

      print('📋 Top recommended model for chatbot: ${getPreferredModelName()}');
      print(
          'ℹ️ API initialized: $_apiInitialized, API init failed: $_apiInitFailed');
      print('ℹ️ Current model selection: ${getPreferredModelName()}');
    } catch (e) {
      print('❌ Error in listModels: $e');
      print('✅ Falling back to stable model: $STABLE_MODEL');
    }
  }

  // Check if the model is deprecated
  static bool isModelDeprecated(String modelName) {
    // List of known deprecated models
    final List<String> deprecatedModels = [
      'models/gemini-pro-vision',
      // Add other deprecated models as they are announced
    ];

    return deprecatedModels.any((model) => modelName.contains(model));
  }

  // Get alternative for deprecated model
  static String getAlternativeModel(String deprecatedModel) {
    // Map of deprecated models to recommended alternatives
    final Map<String, String> alternatives = {
      'models/gemini-pro-vision': 'models/gemini-1.5-flash',
    };

    // Return the alternative or the default stable model
    return alternatives[deprecatedModel] ?? STABLE_MODEL;
  }
}
