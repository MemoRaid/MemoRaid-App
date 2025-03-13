import 'dart:convert';
import 'package:http/http.dart' as http;

class APIConfig {
  static const String geminiApiKey = 'AIzaSyDYbi91NcZrDPD-jbYXwkwP9hb6BR0smzQ';
  static const String geminiApiUrlBase =
      'https://generativelanguage.googleapis.com/v1';
  static const String modelsEndpoint = '$geminiApiUrlBase/models';

  // Recommended models to try in order of preference
  static List<String> recommendedModels = [];

  // Get the preferred model name
  static String getPreferredModelName() {
    if (recommendedModels.isNotEmpty) {
      // Return the first compatible model
      return recommendedModels.first;
    }

    // If we didn't get any models from the API yet, use one of the known working models
    final knownWorkingModels = [
      'models/gemini-1.5-pro',
      'models/gemini-1.5-pro-002',
      'models/gemini-1.5-flash',
      'models/gemini-2.0-flash'
    ];

    return knownWorkingModels.first;
  }

  // Fetch available models from API
  static Future<List<String>> getAvailableModels() async {
    try {
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
        return [];
      }
    } catch (e) {
      print('❌ Error fetching models: $e');
      return [];
    }
  }

  // Filter and sort models by preference
  static List<String> _filterRecommendedModels(List<String> allModels) {
    // Priority order for models (newest/best first)
    final preferenceOrder = [
      'models/gemini-2.0-flash',
      'models/gemini-1.5-pro',
      'models/gemini-1.5-flash',
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
    // but exclude embedding models which don't support chat
    if (filteredModels.isEmpty && allModels.isNotEmpty) {
      for (String model in allModels) {
        if (!model.contains('embedding')) {
          filteredModels.add(model);
          print('⚠️ Using fallback model: $model');
        }
      }
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
    final models = await getAvailableModels();
    if (models.isEmpty) {
      print('❌ No available models found.');
      return;
    }

    print('📋 Top recommended model for chatbot: ${getPreferredModelName()}');
  }
}
