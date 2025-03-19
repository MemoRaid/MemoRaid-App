import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../features/g_02_theme.dart' as custom_theme;
import 'package:flutter/material.dart' hide Theme;

class MemoryGameHome extends StatefulWidget {
  final int initialLevel;
  final String initialTheme;
  final int initialTimeSeconds;

  const MemoryGameHome({
    super.key,
    this.initialLevel = 1,
    this.initialTheme = 'Hobbies',
    this.initialTimeSeconds = 90,
  });

  @override
  State<MemoryGameHome> createState() => _MemoryGameHomeState();
}

class _MemoryGameHomeState extends State<MemoryGameHome>
    with TickerProviderStateMixin {
  final Map<String, custom_theme.Theme> _themes = {
    'Family': custom_theme.Theme(
      name: 'Family',
      emojis: [
        '👨‍👩‍👧‍👦',
        '👵',
        '👴',
        '👨‍👩‍👦',
        '👩‍👧',
        '👨‍👧',
        '👩‍👦',
        '👨‍👦',
        '👩‍👧‍👦',
        '👨‍👧‍👦',
        '👩‍👩‍👦',
        '👨‍👨‍👦',
        '👪', // Added more emojis to accommodate 4x5 grid (20 cards = 10 pairs)
        '👶',
        '👧',
      ],
    ),

    'Places': custom_theme.Theme(
      name: 'Places',
      emojis: [
        '🏠',
        '🏢',
        '🏡',
        '🏫',
        '🏥',
        '🏦',
        '🏨',
        '🏩',
        '🏪',
        '🏫',
        '🏬',
        '🏭',
        '🏯', // Added more emojis for 4x5 grid
        '🏰',
        '⛪',
      ],
    ),

    'Hobbies': custom_theme.Theme(
      name: 'Hobbies',
      emojis: [
        '🎨',
        '🎸',
        '🎹',
        '🎤',
        '🎧',
        '🎮',
        '🎲',
        '🎯',
        '🎳',
        '🎽',
        '🎿',
        '🏀',
        '⚽', // Added more emojis for 4x5 grid
        '🏓',
        '🎭',
      ],
    ),
  };