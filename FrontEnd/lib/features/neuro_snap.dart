import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'services/neuro_snap_stable_diffusion_service.dart';
import 'services/neuro_snap_scoring_service.dart';
import 'neuro_snap_leaderboard_screen.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';

// Custom app theme colors
class AppColors {
  static const Color primaryDark = Color(0xFF0D3445);
  static const Color primaryMedium = Color(0xFF164B60);
  static const Color primaryLight = Color(0xFF2D6E8E);
  static const Color accentColor = Color(0xFF64CCC5);
  static const Color backgroundColor = Color(0xFFEEF5FF);
  static const Color textLight = Color(0xFFF8FBFF);
  static const Color textDark = Color(0xFF0A2730);
}
