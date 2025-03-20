import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:math';

class ImagePair {
  final String firstImage;
  final String secondImage;
  final String description;
  final List<String> optionImages;
  final int hiddenImageIndex;
  final int difficulty;
  final String? firstImagePrompt; // New property for the first image prompt
  final String? secondImagePrompt; // New property for the second image prompt

  ImagePair({
    required this.firstImage,
    required this.secondImage,
    required this.description,
    required this.optionImages,
    required this.hiddenImageIndex,
    required this.difficulty,
    this.firstImagePrompt, // New property for the first image prompt
    this.secondImagePrompt, // New property for the second image prompt
  });
}
class StableDiffusionService {
  final String _baseUrl =
      'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';

  // Replace dynamic API key with hardcoded value
  String get _apiKey => '#';

  Future<String> generateImage(String prompt) async {
    try {
      // Add detailed logging to track the request process
      debugPrint('Sending request to Hugging Face for prompt: $prompt');

      final response = await http
          .post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': prompt}),
      )
          .timeout(
        // Add timeout to prevent hanging on slow responses
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('API request timed out after 60 seconds');
          throw Exception('API request timed out - check your connection');
        },
      );

      // Log the response status and headers for debugging
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        // The API returns binary image data
        final Uint8List bytes = response.bodyBytes;

        // Convert the image to a base64 string that can be used in Image.memory
        final base64Image = base64Encode(bytes);

        // Return as a data URL that can be used directly in an image widget
        return 'data:image/jpeg;base64,$base64Image';
      } else if (response.statusCode == 503) {
        // Model is loading - improve wait message
        debugPrint('Model is loading, retrying in 2 seconds...');
        await Future.delayed(const Duration(seconds: 2));
        return generateImage(prompt); // Retry
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Authentication error - this helps identify API key issues
        debugPrint(
            'Authentication error: Check your API key: ${response.body}');
        throw Exception(
            'API key error: ${response.statusCode} - Check that your API key is valid');
      } else {
        // Other errors
        debugPrint(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
        debugPrint('Error details: ${response.body}');
        throw Exception(
            'Failed to generate image: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Exception in generateImage: $e');
      throw Exception('Failed to generate image: $e');
    }
  }
