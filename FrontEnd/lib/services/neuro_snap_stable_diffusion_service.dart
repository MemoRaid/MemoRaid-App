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
