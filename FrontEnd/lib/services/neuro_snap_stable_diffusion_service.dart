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
 // Add a test method to check API connectivity
  Future<bool> testApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse('https://api-inference.huggingface.co/status'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('API connection test status: ${response.statusCode}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('API connection test failed: $e');
      return false;
    }
  }

  Future<String> _generateImage(String prompt) async {
    return await generateImage(prompt);
  }

  Future<ImagePair> generateImagePair(
    String concept, {
    int difficulty = 1,
  }) async {
    try {
      // Generate two distinctly different images of the same concept
      final firstImage =
          await _generateImage('$concept from front view, detailed');

      // Make sure second image is distinctly different from first
      final secondImage = await _generateImage(
          '$concept from different angle, with different lighting and background');

      // Randomly select which image to hide
      final random = Random();
      final hiddenImageIndex = random.nextInt(2);

      // Get the image that will be hidden
      final targetImage = hiddenImageIndex == 0 ? firstImage : secondImage;

      // Generate distractor images that are similar to the target image
      final distractorImages = await _generateSimilarImages(
        concept: concept,
        targetImage: targetImage,
        numberOfImages: 3, // Generate 3 distractor images
        similarity: difficulty, // Higher difficulty = more similar images
      );

      // Combine the target image with distractors to create options
      final List<String> options = [...distractorImages];

      // Insert the real target at a random position
      final correctPosition = random.nextInt(options.length + 1);
      options.insert(correctPosition, targetImage);

      // Create a meaningful description
      String description = 'Remember this ${concept}';

      // Store the prompts used to generate images
      String prompt1 = "$concept from front view, detailed";
      String prompt2 =
          "$concept from different angle, with different lighting and background";

      return ImagePair(
        firstImage: firstImage,
        secondImage: secondImage,
        hiddenImageIndex: hiddenImageIndex,
        description: description,
        optionImages: options,
        difficulty: difficulty,
        firstImagePrompt: prompt1, // Include the prompt for the first image
        secondImagePrompt: prompt2, // Include the prompt for the second image
      );
    } catch (e) {
      throw Exception('Failed to generate images: $e');
    }
  }
