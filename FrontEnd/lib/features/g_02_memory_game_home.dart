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
