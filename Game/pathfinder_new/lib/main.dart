import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

//------------------------------------------------------------------------------
// APP ENTRY POINT AND CONFIGURATION
//------------------------------------------------------------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PathFinderApp());
}

class PathFinderApp extends StatelessWidget {
  const PathFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Path Finder',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D3445),
        scaffoldBackgroundColor: const Color(0xFF0D3445),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3445),
          brightness: Brightness.dark,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const StartScreen(),
    );
  }
}

//------------------------------------------------------------------------------
// DATA MODELS
//------------------------------------------------------------------------------

// Level data class to define each level's properties
class GameLevel {
  final int levelNumber;
  final int dotCount;
  final int sequenceLength;
  final bool dotsMove;
  final double movementSpeed;
  final bool shuffleAndStop; // New property for shuffle-then-stop behavior

  const GameLevel({
    required this.levelNumber,
    required this.dotCount,
    required this.sequenceLength,
    this.dotsMove = false,
    this.movementSpeed = 1.0,
    this.shuffleAndStop = false,
  });
}

// Define all game levels with adjusted difficulty for memory-impaired players
final List<GameLevel> gameLevels = [
  // STATIC LEVELS - Very gentle introduction
  const GameLevel(
    levelNumber: 1,
    dotCount: 3,
    sequenceLength: 3,
  ), // Easiest possible start
  const GameLevel(
    levelNumber: 2,
    dotCount: 4,
    sequenceLength: 3,
  ), // More dots but same sequence
  const GameLevel(
    levelNumber: 3,
    dotCount: 5,
    sequenceLength: 4,
  ), // Same dots, longer sequence
  // SHUFFLE-STOP LEVELS - Incremental movement introduction
  const GameLevel(
    levelNumber: 4,
    dotCount: 3, // Keep dot count same as level 3
    sequenceLength: 3, // Keep sequence same as level 3
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.4, // Very slow movement for introduction
  ),
  const GameLevel(
    levelNumber: 5,
    dotCount: 4, // Now increase dot count
    sequenceLength: 4, // Keep sequence length the same
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.5,
  ),
  const GameLevel(
    levelNumber: 6,
    dotCount: 5,
    sequenceLength: 4, // Now increase sequence length
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.6,
  ),
  const GameLevel(
    levelNumber: 7,
    dotCount: 5,
    sequenceLength: 4,
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.7,
  ),
  const GameLevel(
    levelNumber: 8,
    dotCount: 5,
    sequenceLength: 5,
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.8,
  ),
  const GameLevel(
    levelNumber: 9,
    dotCount: 6,
    sequenceLength: 5,
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.9,
  ),

  // CONTINUOUS MOVEMENT LEVELS - Most challenging
  const GameLevel(
    levelNumber: 10,
    dotCount: 5, // Fewer dots to compensate for continuous movement
    sequenceLength: 4, // Shorter sequence to compensate for difficulty
    dotsMove: true,
    movementSpeed: 0.6, // Slower speed for introduction
  ),
  const GameLevel(
    levelNumber: 11,
    dotCount: 5,
    sequenceLength: 5,
    dotsMove: true,
    movementSpeed: 0.6,
  ),
  const GameLevel(
    levelNumber: 12,
    dotCount: 6,
    sequenceLength: 5,
    dotsMove: true,
    movementSpeed: 0.7,
  ),
  const GameLevel(
    levelNumber: 13,
    dotCount: 6,
    sequenceLength: 6,
    dotsMove: true,
    movementSpeed: 0.8,
  ),
  const GameLevel(
    levelNumber: 14,
    dotCount: 7,
    sequenceLength: 6,
    dotsMove: true,
    movementSpeed: 0.9,
  ),
  const GameLevel(
    levelNumber: 15,
    dotCount: 7,
    sequenceLength: 7,
    dotsMove: true,
    movementSpeed: 1.0,
  ),
];

// Dot data class
class Dot {
  final int id;
  final Offset position;
  final double size;
  final bool isActive;
  final bool isHighlighted;

  Dot({
    required this.id,
    required this.position,
    required this.size,
    required this.isActive,
    required this.isHighlighted,
  });

  Dot copyWith({
    int? id,
    Offset? position,
    double? size,
    bool? isActive,
    bool? isHighlighted,
  }) {
    return Dot(
      id: id ?? this.id,
      position: position ?? this.position,
      size: size ?? this.size,
      isActive: isActive ?? this.isActive,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}

class LevelAchievement {
  final bool isNewHighScore;
  final bool isNewLevelUnlocked;
  final int previousHighScore;

  LevelAchievement({
    required this.isNewHighScore,
    required this.isNewLevelUnlocked,
    required this.previousHighScore,
  });

  // A special achievement is either a new high score or unlocking a new level
  bool get isSpecialAchievement => isNewHighScore || isNewLevelUnlocked;
}

// Wave layer model for background waves
class WaveLayer {
  final Color color;
  final double speed;
  final double amplitude;
  final double frequency;
  final double phase;
  final double heightFactor;

  WaveLayer({
    required this.color,
    required this.speed,
    required this.amplitude,
    required this.frequency,
    required this.phase,
    required this.heightFactor,
  });
}

// Background particle models
class ParticleNode {
  Offset position;
  final double size;
  final double speed;
  double angle; // Direction angle
  final double opacity;

  ParticleNode({
    required this.position,
    required this.size,
    required this.speed,
    required this.angle,
    required this.opacity,
  });

  void update(double time, Size screenSize) {
    // Move node slowly in its direction
    position = Offset(
      position.dx + cos(angle) * speed,
      position.dy + sin(angle) * speed,
    );

    // Wrap around when going off screen
    if (position.dx < -50)
      position = Offset(screenSize.width + 50, position.dy);
    if (position.dx > screenSize.width + 50)
      position = Offset(-50, position.dy);
    if (position.dy < -50)
      position = Offset(position.dx, screenSize.height + 50);
    if (position.dy > screenSize.height + 50)
      position = Offset(position.dx, -50);

    // Slightly adjust angle for smooth movement
    angle += (sin(time * 0.5) * 0.03);
  }
}

class Connection {
  final int startNodeIndex;
  final int endNodeIndex;
  final double maxDistance;
  final double thickness;

  Connection({
    required this.startNodeIndex,
    required this.endNodeIndex,
    required this.maxDistance,
    required this.thickness,
  });
}

class ParticleDot {
  Offset position;
  final double size;
  final double opacity;
  final double speed;
  double angle;

  ParticleDot({
    required this.position,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.angle,
  });

  void update(double time, Size screenSize) {
    // Apply slow movement in the dot's direction
    position = Offset(
      position.dx + cos(angle) * speed,
      position.dy + sin(angle) * speed,
    );

    // Wrap around screen edges
    if (position.dx < -50)
      position = Offset(screenSize.width + 50, position.dy);
    if (position.dx > screenSize.width + 50)
      position = Offset(-50, position.dy);
    if (position.dy < -50)
      position = Offset(position.dx, screenSize.height + 50);
    if (position.dy > screenSize.height + 50)
      position = Offset(position.dx, -50);

    // Slightly vary the angle for wandering effect
    angle += sin(time * 0.3) * 0.02;
  }
}

//------------------------------------------------------------------------------
// CUSTOM PAINTERS (VISUAL EFFECTS)
//------------------------------------------------------------------------------

// Wave background painter that creates flowing wave effect
class WaveBackgroundPainter extends CustomPainter {
  final List<WaveLayer> layers;
  final double time;

  WaveBackgroundPainter(this.layers, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in layers) {
      final path = Path();

      // Start at left bottom
      path.moveTo(0, size.height);

      // Calculate y position for each point on x-axis for curved wave
      final waveHeight = size.height * layer.heightFactor;
      final baseY = size.height - waveHeight;

      for (double x = 0; x <= size.width; x += 5) {
        final y = baseY +
            sin(x * layer.frequency + layer.phase + time * layer.speed) *
                layer.amplitude;
        path.lineTo(x, y);
      }

      // Complete the path
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      // Fill wave with gradient
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            layer.color.withOpacity(0.6),
            layer.color.withOpacity(0.3),
            layer.color.withOpacity(0.1),
          ],
        ).createShader(Rect.fromLTWH(0, baseY, size.width, waveHeight))
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveBackgroundPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

// Light spots painter for small glowing particles
class LightSpotsPainter extends CustomPainter {
  static const int spotCount = 50;
  final List<Offset> _positions = [];
  final List<double> _sizes = [];
  final List<double> _opacities = [];

  LightSpotsPainter() {
    final random = Random();
    for (int i = 0; i < spotCount; i++) {
      _positions.add(
        Offset(random.nextDouble() * 1000, random.nextDouble() * 1000),
      );
      _sizes.add(1 + random.nextDouble() * 4);
      _opacities.add(0.1 + random.nextDouble() * 0.5);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000;

    for (int i = 0; i < spotCount; i++) {
      // Calculate pulsating opacity
      final pulseRate = 0.5 + (_positions[i].dx * 0.001);
      final dynamicOpacity = _opacities[i] * (0.7 + sin(now * pulseRate) * 0.3);

      // Create a radial gradient for each light spot
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(dynamicOpacity),
            const Color(0xFF4ECDC4).withOpacity(0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(
              _positions[i].dx % size.width,
              _positions[i].dy % size.height,
            ),
            radius: _sizes[i] * 4,
          ),
        );

      // Draw the light spot
      canvas.drawCircle(
        Offset(_positions[i].dx % size.width, _positions[i].dy % size.height),
        _sizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Circuit pattern painter for logo background
class CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(size.width, size.height) / 2;
    final random = Random(12345); // Fixed seed for consistent pattern

    // Draw circuit lines
    for (int i = 0; i < 24; i++) {
      final angle1 = random.nextDouble() * pi * 2;
      final angle2 = random.nextDouble() * pi * 2;

      // Calculate points on circle
      final x1 = centerX + cos(angle1) * radius * 0.7;
      final y1 = centerY + sin(angle1) * radius * 0.7;
      final x2 = centerX + cos(angle2) * radius * 0.9;
      final y2 = centerY + sin(angle2) * radius * 0.9;

      // Line paint
      final paint = Paint()
        ..color = const Color(
          0xFF4ECDC4,
        ).withOpacity(0.4 + random.nextDouble() * 0.3)
        ..strokeWidth = 1 + random.nextDouble() * 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      final pulseRate = 0.5 + i * 0.1;
      final opacity = 0.3 + sin(now * pulseRate) * 0.2;

      // Add curve to path
      final path = Path();
      path.moveTo(x1, y1);

      // Control points for curve
      final midX = (x1 + x2) / 2;
      final midY = (y1 + y2) / 2;
      final ctrlX = midX + (random.nextDouble() - 0.5) * radius * 0.3;
      final ctrlY = midY + (random.nextDouble() - 0.5) * radius * 0.3;

      path.quadraticBezierTo(ctrlX, ctrlY, x2, y2);

      // Draw circuit path
      canvas.drawPath(path, paint);

      // Add nodes at endpoints with glowing effect
      final nodePaint = Paint()
        ..color = const Color(0xFF4ECDC4).withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x1, y1), 1.5, nodePaint);
      canvas.drawCircle(Offset(x2, y2), 2.0, nodePaint);
    }

    // Draw outer glowing ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4ECDC4).withOpacity(0.8),
          const Color(0xFF4ECDC4).withOpacity(0),
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      );

    canvas.drawCircle(Offset(centerX, centerY), radius * 0.85, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Network background painter
class NetworkBackgroundPainter extends CustomPainter {
  final List<ParticleNode> nodes;
  final List<Connection> connections;
  final double time;
  final Size size;

  NetworkBackgroundPainter({
    required this.nodes,
    required this.connections,
    required this.time,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Update nodes
    for (final node in nodes) {
      node.update(time, size);
    }

    // Draw connections
    for (final connection in connections) {
      final startNode = nodes[connection.startNodeIndex];
      final endNode = nodes[connection.endNodeIndex];

      final distance = (startNode.position - endNode.position).distance;

      if (distance <= connection.maxDistance) {
        // Calculate opacity based on distance
        final opacity = 1.0 - (distance / connection.maxDistance);

        // Create a gradient for the connection line
        final paint = Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF4ECDC4).withOpacity(opacity * 0.5),
              const Color(0xFF0D3445).withOpacity(opacity * 0.3),
            ],
          ).createShader(
            Rect.fromPoints(startNode.position, endNode.position),
          )
          ..strokeWidth = connection.thickness * opacity
          ..strokeCap = StrokeCap.round;

        // Draw the connection
        canvas.drawLine(startNode.position, endNode.position, paint);
      }
    }

    // Draw nodes
    for (final node in nodes) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(node.opacity),
            const Color(0xFF4ECDC4).withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(center: node.position, radius: node.size * 4),
        );

      canvas.drawCircle(node.position, node.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant NetworkBackgroundPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

// Light rays painter
class LightRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Origin point for light rays
    final origin = Offset(width * 0.5, height * -0.2);

    // Create rays with varying lengths and angles
    for (int i = 0; i < 8; i++) {
      final angle = (pi * i / 8) + (pi / 16);
      final rayLength = height * 1.5;

      final endX = origin.dx + cos(angle) * rayLength;
      final endY = origin.dy + sin(angle) * rayLength;

      final rayPath = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(endX, endY)
        ..lineTo(endX + width * 0.15, endY)
        ..lineTo(origin.dx, origin.dy)
        ..close();

      final rayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF135777).withOpacity(0.3),
            const Color(0xFF135777).withOpacity(0),
          ],
        ).createShader(Rect.fromPoints(origin, Offset(endX, endY)));

      canvas.drawPath(rayPath, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Subtle waves painter
class SubtleWavesPainter extends CustomPainter {
  final double time;

  SubtleWavesPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw multiple layers of subtle waves
    _drawWave(
      canvas: canvas,
      width: width,
      height: height,
      amplitude: 20,
      frequency: 0.015,
      phase: time * 0.2,
      yPosition: height * 0.75,
      color: const Color(0xFF4ECDC4).withOpacity(0.1),
    );

    _drawWave(
      canvas: canvas,
      width: width,
      height: height,
      amplitude: 15,
      frequency: 0.02,
      phase: time * -0.15,
      yPosition: height * 0.6,
      color: const Color(0xFF135777).withOpacity(0.07),
    );

    _drawWave(
      canvas: canvas,
      width: width,
      height: height,
      amplitude: 30,
      frequency: 0.01,
      phase: time * 0.1,
      yPosition: height * 0.9,
      color: const Color(0xFF0D3445).withOpacity(0.05),
    );
  }

  void _drawWave({
    required Canvas canvas,
    required double width,
    required double height,
    required double amplitude,
    required double frequency,
    required double phase,
    required double yPosition,
    required Color color,
  }) {
    final path = Path();

    // Start from left bottom
    path.moveTo(0, height);

    // Draw wave
    for (double x = 0; x <= width; x += 5) {
      final y = yPosition + sin(x * frequency + phase) * amplitude;
      path.lineTo(x, y);
    }

    // Complete path
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    // Fill with gradient
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, yPosition - amplitude, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SubtleWavesPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

// Hexagonal pattern painter for logo background
class HexagonalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(size.width, size.height) / 2;
    final random = Random(12345); // Fixed seed for consistent pattern

    // Draw hexagons around the circle
    for (int ring = 0; ring < 2; ring++) {
      final ringRadius = radius * (0.65 + ring * 0.3);
      final hexCount = 6 + ring * 2;

      for (int i = 0; i < hexCount; i++) {
        final angle = (2 * pi * i / hexCount);
        final x = centerX + cos(angle) * ringRadius;
        final y = centerY + sin(angle) * ringRadius;

        // Draw hexagon
        _drawHexagon(
          canvas,
          x,
          y,
          5 + random.nextDouble() * 5,
          const Color(0xFF4ECDC4).withOpacity(0.2 + random.nextDouble() * 0.2),
        );
      }
    }

    // Draw circuit-like connections
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final paint = Paint()
      ..color = const Color(0xFF4ECDC4).withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle1 = (2 * pi * i / 12);
      final angle2 = angle1 + pi / 6 + random.nextDouble() * (pi / 3);

      final r1 = radius * 0.7;
      final r2 = radius * 0.9;

      final x1 = centerX + cos(angle1) * r1;
      final y1 = centerY + sin(angle1) * r1;

      final x2 = centerX + cos(angle2) * r2;
      final y2 = centerY + sin(angle2) * r2;

      // Add pulsating effect based on time
      final glow = (sin(now + i) + 1) / 2;
      paint.color = const Color(0xFF4ECDC4).withOpacity(0.3 + glow * 0.3);

      // Draw path with curve for circuit-like effect
      final path = Path();
      path.moveTo(x1, y1);

      final ctrlX = (x1 + x2) / 2 + (random.nextDouble() - 0.5) * 20;
      final ctrlY = (y1 + y2) / 2 + (random.nextDouble() - 0.5) * 20;

      path.quadraticBezierTo(ctrlX, ctrlY, x2, y2);
      canvas.drawPath(path, paint);

      // Draw small nodes at the ends
      final nodePaint = Paint()
        ..color = const Color(0xFF4ECDC4).withOpacity(0.5 + glow * 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x1, y1), 2, nodePaint);
      canvas.drawCircle(Offset(x2, y2), 2, nodePaint);
    }
  }

  void _drawHexagon(
    Canvas canvas,
    double x,
    double y,
    double size,
    Color color,
  ) {
    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i;
      final xPoint = x + cos(angle) * size;
      final yPoint = y + sin(angle) * size;

      if (i == 0) {
        path.moveTo(xPoint, yPoint);
      } else {
        path.lineTo(xPoint, yPoint);
      }
    }

    path.close();

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Background animations for level selection screen
class LevelSelectBackgroundPainter extends CustomPainter {
  final double time;
  final Random _random = Random(42);

  LevelSelectBackgroundPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw flowing lines background
    _drawFlowingLines(canvas, size);

    // Draw subtle wave at bottom
    _drawWave(canvas, size);

    // Draw glowing particles
    _drawGlowingParticles(canvas, size);
  }

  void _drawFlowingLines(Canvas canvas, Size size) {
    final lineCount = 10;
    final lineWidth = 1.0;

    for (int i = 0; i < lineCount; i++) {
      final y = (size.height / (lineCount + 1)) * (i + 1);
      final path = Path();

      path.moveTo(0, y);

      final amplitude = 20.0 + _random.nextDouble() * 20;
      final frequency = 0.01 + _random.nextDouble() * 0.01;
      final phase = time * (0.1 + _random.nextDouble() * 0.2) + i;

      for (double x = 0; x <= size.width; x += 5) {
        path.lineTo(x, y + sin(x * frequency + phase) * amplitude);
      }

      final paint = Paint()
        ..color = const Color(0xFF4ECDC4).withOpacity(0.07 + (i % 3) * 0.02)
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth;

      canvas.drawPath(path, paint);
    }
  }

  void _drawWave(Canvas canvas, Size size) {
    final path = Path();

    final baseY = size.height * 0.9;
    path.moveTo(0, baseY);

    for (double x = 0; x <= size.width; x += 5) {
      final dx1 = sin(x * 0.01 + time * 0.2) * 15;
      final dx2 = sin(x * 0.02 + time * 0.1) * 10;
      path.lineTo(x, baseY + dx1 + dx2);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4ECDC4).withOpacity(0.2),
          const Color(0xFF4ECDC4).withOpacity(0),
        ],
      ).createShader(
        Rect.fromLTWH(0, baseY, size.width, size.height - baseY),
      );

    canvas.drawPath(path, paint);
  }

  void _drawGlowingParticles(Canvas canvas, Size size) {
    const particleCount = 30;

    for (int i = 0; i < particleCount; i++) {
      final x = ((time * (0.1 + i * 0.01)) % 2) * size.width;
      final y = ((i * 37) % size.height) + sin(time + i) * 20;

      final radius = 1.5 + sin(time * 0.8 + i) * 1.0;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(0.6),
            const Color(0xFF4ECDC4).withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(x, y), radius: radius * 4),
        );

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LevelSelectBackgroundPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

// Circuit pattern background for level tiles
class CircuitPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(12345);
    final lineCount = 6;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF4ECDC4).withOpacity(0.2);

    // Draw a few curved lines to resemble circuits
    for (int i = 0; i < lineCount; i++) {
      final path = Path();

      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;

      path.moveTo(startX, startY);

      for (int j = 0; j < 2; j++) {
        final endX = random.nextDouble() * size.width;
        final endY = random.nextDouble() * size.height;

        final controlX1 = startX + (endX - startX) * random.nextDouble();
        final controlY1 = startY + (endY - startY) * random.nextDouble();

        path.quadraticBezierTo(controlX1, controlY1, endX, endY);

        // Draw small "nodes" at points
        canvas.drawCircle(
          Offset(endX, endY),
          1.5,
          Paint()..color = const Color(0xFF4ECDC4).withOpacity(0.3),
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Game background painter for animated background
class GameBackgroundPainter extends CustomPainter {
  final double time;
  final List<ParticleDot> particles;

  GameBackgroundPainter({required this.time, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    // Update particle positions
    for (final particle in particles) {
      particle.update(time, size);
    }

    // Draw subtle background grid
    _drawGrid(canvas, size);

    // Draw flowing particles
    _drawParticles(canvas, size);

    // Draw subtle pulsating glow at bottom
    _drawBottomGlow(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final lineCount = 10;
    final horizontalSpacing = size.width / lineCount;
    final verticalSpacing = size.height / lineCount;

    final paint = Paint()
      ..color = const Color(0xFF4ECDC4).withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (int i = 1; i < lineCount; i++) {
      final x = horizontalSpacing * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 1; i < lineCount; i++) {
      final y = verticalSpacing * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Make opacity pulsate slightly
      final pulsingOpacity = particle.opacity *
          (0.7 + sin(time + particle.position.dx * 0.01) * 0.3);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(pulsingOpacity),
            const Color(0xFF4ECDC4).withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: particle.position,
            radius: particle.size * 6,
          ),
        );

      canvas.drawCircle(particle.position, particle.size, paint);
    }

    // Draw connections between some nearby particles
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final distance =
            (particles[i].position - particles[j].position).distance;
        if (distance < 100) {
          final opacity = (1 - distance / 100) * 0.1;

          final paint = Paint()
            ..color = const Color(0xFF4ECDC4).withOpacity(opacity)
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke;

          canvas.drawLine(particles[i].position, particles[j].position, paint);
        }
      }
    }
  }

  void _drawBottomGlow(Canvas canvas, Size size) {
    final centerY = size.height * 0.9;
    final glowRadius = size.width * 0.8;
    final glowOpacity = 0.05 + sin(time * 0.5) * 0.02;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4ECDC4).withOpacity(glowOpacity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, centerY),
          radius: glowRadius,
        ),
      );

    canvas.drawCircle(Offset(size.width / 2, centerY), glowRadius, paint);
  }

  @override
  bool shouldRepaint(covariant GameBackgroundPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

//------------------------------------------------------------------------------
// REUSABLE UI COMPONENTS
//------------------------------------------------------------------------------

class GlowingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const GlowingActionButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  State<GlowingActionButton> createState() => _GlowingActionButtonState();
}

class _GlowingActionButtonState extends State<GlowingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(_pulseController);

    _pulseController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.only(
                top: 2,
                left: 32,
                right: 32,
                bottom: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4ECDC4),
                    const Color(0xFF4ECDC4).withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  // Inner glow
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.3),
                    blurRadius: _pulseAnimation.value * 15,
                    spreadRadius: _pulseAnimation.value * 4,
                  ),
                  // Bottom shadow for 3D effect
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  color: _isPressed ? Colors.white70 : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(widget.text),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//------------------------------------------------------------------------------
// START SCREEN
//------------------------------------------------------------------------------

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonOpacityAnimation;
  late Animation<double> _scoreOpacityAnimation;

  // For new background animation
  final List<WaveLayer> _waveLayers = [];
  final Random _random = Random();
  final ValueNotifier<double> _timeNotifier = ValueNotifier(0);
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Logo animations - delayed start, elastic finish
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Button animations - start after logo
    _buttonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.elasticOut),
      ),
    );

    _buttonOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
      ),
    );

    // Score animation - last to appear
    _scoreOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Generate wave layers for background animation
    _generateWaveLayers();

    // Start the animation timer for waves
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _timeNotifier.value += 0.016; // Increments time for wave animation
    });

    // Start the entrance animation
    _controller.forward();
  }

  void _generateWaveLayers() {
    // Color scheme based on the #0D3445 theme with slight variations
    final List<Color> baseColors = [
      const Color(0xFF0D3445),
      const Color(0xFF125673),
      const Color(0xFF1A789B),
      const Color(0xFF4ECDC4),
    ];

    // Create multiple wave layers with different properties
    for (int i = 0; i < 5; i++) {
      final baseColor = baseColors[_random.nextInt(baseColors.length)];

      _waveLayers.add(
        WaveLayer(
          color: baseColor.withOpacity(0.07 + _random.nextDouble() * 0.08),
          speed: 0.3 + _random.nextDouble() * 0.7,
          amplitude: 20 + _random.nextDouble() * 40,
          frequency: 0.005 + _random.nextDouble() * 0.01,
          phase: _random.nextDouble() * pi * 2,
          heightFactor: 0.5 + _random.nextDouble() * 0.5,
        ),
      );
    }
  }

  // Removed unused _setupBackground method

  @override
  void dispose() {
    _controller.dispose();
    _animationTimer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Base gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D3445),
                  const Color(0xFF0A2A38),
                  const Color(0xFF061A25),
                ],
              ),
            ),
          ),

          // Dynamic wave background
          ValueListenableBuilder(
            valueListenable: _timeNotifier,
            builder: (context, time, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: WaveBackgroundPainter(_waveLayers, time),
              );
            },
          ),

          // Floating light particles
          CustomPaint(
            size: Size(size.width, size.height),
            painter: LightSpotsPainter(),
          ),

          // Main content with animations
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animation
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      // Digital circuit effect surrounding the logo
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return RadialGradient(
                            center: Alignment.center,
                            radius: 0.5,
                            colors: [
                              const Color(0xFF4ECDC4),
                              const Color(0xFF4ECDC4).withOpacity(0.3),
                            ],
                          ).createShader(bounds);
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: CircuitPainter(),
                            child: const Center(
                              child: Icon(
                                Icons.route,
                                size: 60,
                                color: Color(0xFF4ECDC4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [Color(0xFF4ECDC4), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'PATH FINDER',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Button animation - same as before
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _buttonOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _buttonScaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: GlowingActionButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 800),
                          pageBuilder: (_, animation, __) {
                            return FadeTransition(
                              opacity: animation,
                              child: const LevelSelectionScreen(),
                            );
                          },
                        ),
                      );
                    },
                    text: 'START GAME',
                  ),
                ),

                const SizedBox(height: 30),

                // High score animation - same as before
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _scoreOpacityAnimation.value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          20 * (1 - _scoreOpacityAnimation.value),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: FutureBuilder<int>(
                    future: _getHighScore(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: const Color(0xFF4ECDC4).withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4ECDC4).withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Color(0xFF4ECDC4),
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'HIGH SCORE: ${snapshot.data}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4ECDC4),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<int> _getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore') ?? 0;
  }
}

//------------------------------------------------------------------------------
// LEVEL SELECTION SCREEN
//------------------------------------------------------------------------------

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
    with SingleTickerProviderStateMixin {
  int unlockedLevel = 1;
  final ValueNotifier<double> _timeNotifier = ValueNotifier(0);
  Timer? _animationTimer;
  int? _hoveredLevel;

  // Animation controller for page entrance
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUnlockedLevel();

    // Setup animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start the animation timer for background effects
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _timeNotifier.value += 0.016;
    });

    // Start entrance animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationTimer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUnlockedLevel = prefs.getInt('unlockedLevel') ?? 1;

    setState(() {
      unlockedLevel = savedUnlockedLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Select Level',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FadeTransition(
        opacity: _fadeAnimation,
        child: FloatingActionButton(
          onPressed: _showResetConfirmation,
          backgroundColor: const Color(0xFFE63946),
          foregroundColor: Colors.white,
          elevation: 6,
          tooltip: 'Reset All Progress',
          child: const Icon(Icons.refresh),
        ),
      ),
      body: Stack(
        children: [
          // Background base gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D3445),
                  Color(0xFF042f46),
                  Color(0xFF021e2b),
                ],
              ),
            ),
          ),

          // Background animated waves
          ValueListenableBuilder(
            valueListenable: _timeNotifier,
            builder: (context, time, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: LevelSelectBackgroundPainter(time),
              );
            },
          ),

          // Level Grid content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -0.2),
                        end: Offset.zero,
                      ).animate(_controller),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF4ECDC4).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.gamepad,
                              color: Color(0xFF4ECDC4),
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Choose Your Challenge',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: gameLevels.length,
                        itemBuilder: (context, index) {
                          final level = gameLevels[index];
                          final isUnlocked = level.levelNumber <= unlockedLevel;
                          final isHovered = _hoveredLevel == level.levelNumber;

                          return FutureBuilder<int>(
                            future: _getLevelHighScore(level.levelNumber),
                            builder: (context, snapshot) {
                              final highScore = snapshot.data ?? 0;

                              return AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: isHovered ? 1.05 : 1.0,
                                child: GestureDetector(
                                  onTap: isUnlocked
                                      ? () {
                                          HapticFeedback.mediumImpact();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => GameScreen(
                                                level: level,
                                              ),
                                            ),
                                          ).then((_) {
                                            _loadUnlockedLevel();
                                          });
                                        }
                                      : null,
                                  onTapDown: (_) {
                                    setState(() {
                                      _hoveredLevel = level.levelNumber;
                                    });
                                  },
                                  onTapUp: (_) {
                                    setState(() {
                                      _hoveredLevel = null;
                                    });
                                  },
                                  onTapCancel: () {
                                    setState(() {
                                      _hoveredLevel = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: isUnlocked
                                          ? LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                const Color(0xFF125673),
                                                const Color(0xFF0D3445),
                                              ],
                                            )
                                          : LinearGradient(
                                              colors: [
                                                Colors.grey.shade800,
                                                Colors.grey.shade900,
                                              ],
                                            ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isUnlocked
                                              ? const Color(
                                                  0xFF4ECDC4,
                                                ).withOpacity(0.3)
                                              : Colors.black38,
                                          blurRadius: isHovered ? 12 : 5,
                                          spreadRadius: isHovered ? 2 : 0,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: isUnlocked
                                            ? const Color(
                                                0xFF4ECDC4,
                                              ).withOpacity(0.5)
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Background circuit pattern
                                        if (isUnlocked)
                                          CustomPaint(
                                            painter: CircuitPatternPainter(),
                                            size: Size.infinite,
                                          ),

                                        // Level content
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              width: isHovered && isUnlocked
                                                  ? 60
                                                  : 55,
                                              height: isHovered && isUnlocked
                                                  ? 60
                                                  : 55,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isUnlocked
                                                    ? const Color(
                                                        0xFF4ECDC4,
                                                      ).withOpacity(0.2)
                                                    : Colors.grey.shade700
                                                        .withOpacity(0.2),
                                                border: Border.all(
                                                  color: isUnlocked
                                                      ? const Color(
                                                          0xFF4ECDC4,
                                                        )
                                                      : Colors.grey.shade600,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${level.levelNumber}',
                                                  style: TextStyle(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                    color: isUnlocked
                                                        ? const Color(
                                                            0xFF4ECDC4,
                                                          )
                                                        : Colors.grey.shade400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            if (isUnlocked)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    level.dotsMove
                                                        ? Icons.moving
                                                        : Icons.grid_on,
                                                    color: const Color(
                                                      0xFF4ECDC4,
                                                    ).withOpacity(0.7),
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    level.dotsMove
                                                        ? "Moving"
                                                        : "Static",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (isUnlocked && highScore > 0)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4.0,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.emoji_events,
                                                      color: Color(0xFFFFD700),
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '$highScore',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),

                                        // Lock overlay
                                        if (!isUnlocked)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.lock,
                                                color: Colors.white70,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D3445),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFF4ECDC4).withOpacity(0.5),
            width: 2,
          ),
        ),
        title: const Text(
          'Reset All Progress?',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 50,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'This will reset all level unlocks and high scores. This action cannot be undone.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _resetAllProgress();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63946),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Reset unlocked levels back to 1
    await prefs.setInt('unlockedLevel', 1);

    // Reset overall high score
    await prefs.setInt('highScore', 0);

    // Reset all level high scores
    for (final level in gameLevels) {
      await prefs.remove('highScore_level_${level.levelNumber}');
    }

    // Update UI
    setState(() {
      unlockedLevel = 1;
    });

    // Show confirmation to user
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All progress has been reset'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<int> _getLevelHighScore(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore_level_$level') ?? 0;
  }
}

//------------------------------------------------------------------------------
// GAME SCREEN AND LOGIC
//------------------------------------------------------------------------------

class GameScreen extends StatefulWidget {
  final GameLevel level;

  const GameScreen({super.key, required this.level});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game constants
  static const int maxLives = 3;
  static const Duration sequenceDisplayDuration = Duration(
    milliseconds: 1000,
  ); // Longer display time
  static const Duration shuffleDuration = Duration(
    seconds: 5,
  ); // Longer shuffle time for better perception

  // Game state variables
  late int level;
  late int score;
  late int lives;
  late int dotCount;
  late int sequenceLength;
  late List<Dot> dots;
  late List<int> sequence;
  late int currentIndex;
  late bool showingSequence;
  late bool awaitingInput;
  late bool gameOver;
  late Random random;
  late int startTime;
  bool _isFirstBuild = true;
  int? countdownNumber;
  late bool dotsMove;
  late bool shuffleAndStop;
  Duration dotMovementDuration = const Duration(milliseconds: 1500);
  String gameStatusText = 'Get ready...'; // Status text to show to the player

  // Controllers for animations
  late List<AnimationController> moveControllers;
  late List<Animation<Offset>> moveAnimations;

  // Background animation variables
  final ValueNotifier<double> _backgroundTimeNotifier = ValueNotifier(0);
  Timer? _backgroundAnimationTimer;
  late List<ParticleDot> _backgroundParticles;

  // Add a list to track target positions of dots
  List<Offset> targetPositions = [];

  @override
  void initState() {
    super.initState();
    random = Random();
    moveControllers = [];
    moveAnimations = [];
    _initializeGame();

    // Initialize background effects
    _setupBackground();

    // Start background animation timer
    _backgroundAnimationTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) {
        _backgroundTimeNotifier.value += 0.016;
      },
    );
  }

  void _setupBackground() {
    // Generate background particles
    _backgroundParticles = List.generate(30, (index) {
      return ParticleDot(
        position: Offset(
          random.nextDouble() * 1000,
          random.nextDouble() * 2000,
        ),
        size: 1.0 + random.nextDouble() * 2.0,
        opacity: 0.1 + random.nextDouble() * 0.2,
        speed: 0.1 + random.nextDouble() * 0.2,
        angle: random.nextDouble() * pi * 2,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only generate levels after the first build to ensure context is available
    if (!_isFirstBuild) {
      _generateLevel();
    } else {
      _isFirstBuild = false;
      // Schedule level generation after the first frame is drawn
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _generateLevel();
        }
      });
    }
  }

  void _initializeGame() {
    // Initialize based on the passed level
    level = widget.level.levelNumber;
    score = 0;
    lives = maxLives;
    dotCount = widget.level.dotCount;
    sequenceLength = widget.level.sequenceLength;
    dotsMove = widget.level.dotsMove;
    shuffleAndStop = widget.level.shuffleAndStop;

    // Adjust movement speed based on level
    dotMovementDuration = Duration(
      milliseconds: (1500 / widget.level.movementSpeed).round(),
    );

    dots = [];
    sequence = [];
    currentIndex = 0;
    showingSequence = false;
    awaitingInput = false;
    gameOver = false;
    startTime = DateTime.now().millisecondsSinceEpoch;
  }

  void _generateLevel() {
    if (!mounted) return;

    // Clear previous level data
    dots.clear();
    sequence.clear();
    currentIndex = 0;

    // Generate dots and their positions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.7;
    final safeAreaInsets = MediaQuery.of(context).padding;

    // Calculate safe boundaries to keep dots fully on screen
    final dotSize = 60.0;
    final safeWidth = screenWidth - dotSize;
    final safeTop = 100.0 + safeAreaInsets.top; // Top padding + status bar
    final safeBottom = screenHeight - dotSize;

    // Maximum attempts to prevent infinite loops
    final maxAttempts = 100;

    // Generate dots with random positions within safe bounds, avoiding overlaps
    for (int i = 0; i < dotCount; i++) {
      bool validPosition = false;
      int attempts = 0;
      double xPos = 0;
      double yPos = 0;

      // Keep trying positions until finding one without overlaps or exceeding max attempts
      while (!validPosition && attempts < maxAttempts) {
        attempts++;
        xPos = random.nextDouble() * safeWidth;
        yPos = safeTop + random.nextDouble() * (safeBottom - safeTop);

        validPosition = true; // Assume position is valid until proven otherwise

        // Check against all previously placed dots
        for (var existingDot in dots) {
          // Calculate distance between dot centers
          final distance = (Offset(xPos, yPos) - existingDot.position).distance;
          // Minimum distance to avoid overlap (sum of radii with a small buffer)
          final minDistance = dotSize * 1.2;

          if (distance < minDistance) {
            validPosition = false; // This position overlaps, try again
            break;
          }
        }
      }

      // If couldn't find non-overlapping position after max attempts, use the last attempt anyway
      // This is a fallback to ensure the game can continue

      dots.add(
        Dot(
          id: i,
          position: Offset(xPos, yPos),
          size: dotSize,
          isActive: false,
          isHighlighted: false,
        ),
      );
    }

    // Generate random sequence only if we have dots
    if (dots.isNotEmpty) {
      // Use only the number of dots we need for the sequence
      List<int> indices = List.generate(dotCount, (index) => index);
      indices.shuffle(random);
      // Take only the required number of dots for the sequence
      sequence = indices.take(sequenceLength).toList();

      // Setup animation controllers for dot movement
      if (dotsMove) {
        _setupMovementAnimations();
      }

      // Start showing the sequence after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showSequence();
        }
      });
    }
  }

  void _setupMovementAnimations() {
    // Don't proceed if no dots
    if (dots.isEmpty) return;

    // Dispose old controllers if any
    for (var controller in moveControllers) {
      controller.dispose();
    }

    moveControllers = [];
    moveAnimations = [];
    targetPositions = List.filled(
        dots.length, Offset.zero); // Initialize target positions list

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.7;
    final safeAreaInsets = MediaQuery.of(context).padding;

    for (int i = 0; i < dots.length; i++) {
      // Create animation controller
      final controller = AnimationController(
        duration: dotMovementDuration,
        vsync: this,
      );

      // Calculate safe boundaries for this dot
      final dotSize = dots[i].size;
      final safeWidth = screenWidth - dotSize;
      final safeTop = 100.0 + safeAreaInsets.top; // Top padding + status bar
      final safeBottom = screenHeight - dotSize;

      // Find a position that doesn't overlap with other dots
      final newPosition = _findNonOverlappingPosition(
        i,
        safeWidth,
        safeTop,
        safeBottom,
        dotSize,
      );

      // Store the target position
      targetPositions[i] = newPosition;

      // Create tween animation
      final animation = Tween<Offset>(
        begin: dots[i].position,
        end: newPosition,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      // Add listener to update dot position
      animation.addListener(() {
        if (mounted && i < dots.length) {
          setState(() {
            dots[i] = dots[i].copyWith(position: animation.value);
          });
        }
      });

      moveControllers.add(controller);
      moveAnimations.add(animation);

      // When animation completes, start a new one in a different direction
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted && i < dots.length) {
          // Find a new non-overlapping position
          final newPosition = _findNonOverlappingPosition(
            i,
            safeWidth,
            safeTop,
            safeBottom,
            dotSize,
          );

          // Update the target position
          targetPositions[i] = newPosition;

          // Create a new tween animation with new positions
          final newAnimation = Tween<Offset>(
            begin: dots[i].position,
            end: newPosition,
          ).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );

          // Add listener to update dot position
          newAnimation.addListener(() {
            if (mounted && i < dots.length) {
              setState(() {
                dots[i] = dots[i].copyWith(position: newAnimation.value);
              });
            }
          });

          if (i < moveAnimations.length) {
            moveAnimations[i] = newAnimation;
          }

          controller.reset();
          controller.forward();
        }
      });
    }
  }

  // Improved helper method to find a position that doesn't overlap with other dots
  Offset _findNonOverlappingPosition(
    int dotIndex,
    double safeWidth,
    double safeTop,
    double safeBottom,
    double dotSize,
  ) {
    const maxAttempts = 50; // Increased attempts for better results
    int attempts = 0;

    while (attempts < maxAttempts) {
      // Generate random position
      final xPos = random.nextDouble() * safeWidth;
      final yPos = safeTop + random.nextDouble() * (safeBottom - safeTop);
      final testPosition = Offset(xPos, yPos);

      bool overlaps = false;

      // Check against all other dots (both current positions and target positions)
      for (int i = 0; i < dots.length; i++) {
        if (i == dotIndex) continue; // Skip checking against self

        // Check for overlap with current position
        final currentDistance = (testPosition - dots[i].position).distance;
        final minDistance =
            dotSize * 1.5; // Increased buffer for safer movement

        // Also check for overlap with target position if available
        final targetDistance =
            targetPositions.isNotEmpty && i < targetPositions.length
                ? (testPosition - targetPositions[i]).distance
                : double.infinity;

        if (currentDistance < minDistance || targetDistance < minDistance) {
          overlaps = true;
          break;
        }
      }

      // Also check path intersections to prevent dots from crossing paths
      if (!overlaps) {
        for (int i = 0; i < dots.length; i++) {
          if (i == dotIndex || i >= targetPositions.length) continue;

          // Simple line intersection check - if dots would cross paths
          if (_pathsIntersect(dots[dotIndex].position, testPosition,
              dots[i].position, targetPositions[i])) {
            overlaps = true;
            break;
          }
        }
      }

      if (!overlaps) {
        return testPosition; // Found a good position
      }

      attempts++;
    }

    // If we couldn't find a non-overlapping position after max attempts,
    // try to find the farthest position from all other dots
    double maxMinDistance = 0;
    Offset bestPosition = Offset(
      random.nextDouble() * safeWidth,
      safeTop + random.nextDouble() * (safeBottom - safeTop),
    );

    for (int attempt = 0; attempt < 20; attempt++) {
      final testX = random.nextDouble() * safeWidth;
      final testY = safeTop + random.nextDouble() * (safeBottom - safeTop);
      final testPos = Offset(testX, testY);

      double minDistanceToOtherDot = double.infinity;
      for (int i = 0; i < dots.length; i++) {
        if (i == dotIndex) continue;
        final dist = (testPos - dots[i].position).distance;
        minDistanceToOtherDot = min(minDistanceToOtherDot, dist);
      }

      if (minDistanceToOtherDot > maxMinDistance) {
        maxMinDistance = minDistanceToOtherDot;
        bestPosition = testPos;
      }
    }

    return bestPosition;
  }

  // Helper method to check if two line segments intersect (for path crossing detection)
  bool _pathsIntersect(Offset a, Offset b, Offset c, Offset d) {
    // Simple bounding box check first for efficiency
    if (max(a.dx, b.dx) < min(c.dx, d.dx) ||
        max(c.dx, d.dx) < min(a.dx, b.dx) ||
        max(a.dy, b.dy) < min(c.dy, d.dy) ||
        max(c.dy, d.dy) < min(a.dy, b.dy)) {
      return false;
    }

    // Only do more detailed check if bounding boxes overlap
    // This is a simple cross-product check for line segment intersection
    final abX = b.dx - a.dx;
    final abY = b.dy - a.dy;
    final acX = c.dx - a.dx;
    final acY = c.dy - a.dy;
    final adX = d.dx - a.dx;
    final adY = d.dy - a.dy;

    final cross1 = abX * acY - abY * acX;
    final cross2 = abX * adY - abY * adX;

    if (cross1 * cross2 > 0) return false;

    final cdX = d.dx - c.dx;
    final cdY = d.dy - c.dy;
    final caX = a.dx - c.dx;
    final caY = a.dy - c.dy;
    final cbX = b.dx - c.dx;
    final cbY = b.dy - c.dy;

    final cross3 = cdX * caY - cdY * caX;
    final cross4 = cdX * cbY - cdY * cbX;

    return cross3 * cross4 <= 0;
  }

  void _showSequence() {
    if (sequence.isEmpty) return; // Don't proceed with empty sequence

    setState(() {
      showingSequence = true;
      awaitingInput = false;
      gameStatusText = 'Watch carefully...';
    });

    // Show sequence one by one
    Future.forEach(List.generate(sequence.length, (index) => index), (
      index,
    ) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          // Reset all dots
          for (int i = 0; i < dots.length; i++) {
            dots[i] = dots[i].copyWith(isHighlighted: false, isActive: false);
          }

          // Highlight current dot in sequence
          final dotIndex = sequence[index];
          dots[dotIndex] = dots[dotIndex].copyWith(
            isHighlighted: true,
            isActive: true,
          );
        });
      }

      // Blink effect
      for (int i = 0; i < 2; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          setState(() {
            final dotIndex = sequence[index];
            dots[dotIndex] = dots[dotIndex].copyWith(
              isHighlighted: !dots[dotIndex].isHighlighted,
            );
          });
        }
      }

      // Wait for display duration
      await Future.delayed(sequenceDisplayDuration);

      // Turn off highlight
      if (mounted) {
        setState(() {
          final dotIndex = sequence[index];
          dots[dotIndex] = dots[dotIndex].copyWith(
            isHighlighted: false,
            isActive: false,
          );
        });
      }
    }).then((_) {
      if (mounted) {
        // For shuffle and stop levels, start shuffling first
        if (shuffleAndStop && dotsMove) {
          _startShufflePhase();
        } else {
          // Standard behavior - start countdown directly
          _startCountdown();
        }
      }
    });
  }

  // New method to handle the shuffle phase
  void _startShufflePhase() {
    setState(() {
      gameStatusText = 'Dots are shuffling...';
    });

    // Start dot movement
    for (var controller in moveControllers) {
      controller.forward();
    }

    // Set a timer to stop movement after shuffle duration
    Future.delayed(shuffleDuration, () {
      if (mounted) {
        // Stop all dot movements
        for (var controller in moveControllers) {
          controller.stop();
        }

        // Now start the countdown for player input
        _startCountdown();
      }
    });
  }

  void _startCountdown() {
    setState(() {
      countdownNumber = 3;
      gameStatusText = 'Get ready...';
    });

    // Countdown 3, 2, 1
    Future.forEach([2, 1, 0], (number) async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          countdownNumber = number;
        });
      }
    }).then((_) {
      if (mounted) {
        setState(() {
          countdownNumber = null;
          showingSequence = false;
          awaitingInput = true;
          gameStatusText = 'Your turn!';

          // Start dot movement for continuous movement levels
          if (dotsMove && !shuffleAndStop) {
            for (var controller in moveControllers) {
              controller.forward();
            }
          }
        });
      }
    });
  }

  void _handleDotTap(int dotId) {
    // Ignore taps if not awaiting input
    if (!awaitingInput || gameOver) return;

    final expectedDotId = sequence[currentIndex];

    if (dotId == expectedDotId) {
      // Correct tap
      setState(() {
        dots[dotId] = dots[dotId].copyWith(isHighlighted: true);
        score += 10;
        currentIndex++;
      });

      // Visual feedback for correct tap
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            dots[dotId] = dots[dotId].copyWith(isHighlighted: false);
          });
        }
      });

      // Check if the sequence is complete
      if (currentIndex >= sequence.length) {
        _handleLevelComplete();
      }
    } else {
      // Incorrect tap
      setState(() {
        lives--;
        score = max(0, score - 5);
      });

      // Visual feedback for wrong tap
      _showErrorAnimation();

      if (lives <= 0) {
        _handleGameOver();
      }
    }
  }

  void _handleLevelComplete() {
    // Stop dot movements
    if (dotsMove) {
      for (var controller in moveControllers) {
        controller.stop();
      }
    }

    // Calculate time bonus
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final timeElapsed = (endTime - startTime) / 1000; // Convert to seconds
    int timeBonus = max(
      0,
      100 - (timeElapsed.toInt() * 2),
    ); // 2 points per second

    // Calculate perfect bonus
    final perfectBonus = lives >= maxLives ? 50 : 0;

    setState(() {
      score += timeBonus;
      score += perfectBonus;
      awaitingInput = false;
    });

    // Check if this is a new high score and/or unlocks a new level
    _checkLevelAchievement().then((achievement) {
      if (!mounted) return;

      // Navigate to results screen instead of showing a dialog
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => GameResultsScreen(
            level: level,
            score: score,
            timeBonus: timeBonus,
            perfectBonus: perfectBonus,
            achievement: achievement,
            onContinue: () {
              Navigator.of(context).pop(); // Close results screen
              Navigator.of(context).pop(); // Return to level selection
            },
          ),
        ),
      );
    });
  }

  Future<LevelAchievement> _checkLevelAchievement() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if this is a new high score
    final currentLevelHigh = prefs.getInt('highScore_level_$level') ?? 0;
    final isNewHighScore = score > currentLevelHigh;

    // Save level high score if better than previous
    if (isNewHighScore) {
      await prefs.setInt('highScore_level_$level', score);
    }

    // Save overall high score if better than previous
    final currentHigh = prefs.getInt('highScore') ?? 0;
    if (score > currentHigh) {
      await prefs.setInt('highScore', score);
    }

    // Check if completing this level unlocks a new level
    final currentUnlockedLevel = prefs.getInt('unlockedLevel') ?? 1;
    bool isNewLevelUnlocked = false;

    if (level >= currentUnlockedLevel && level < gameLevels.length) {
      isNewLevelUnlocked = true;
      await prefs.setInt('unlockedLevel', level + 1);
    }

    return LevelAchievement(
      isNewHighScore: isNewHighScore,
      isNewLevelUnlocked: isNewLevelUnlocked,
      previousHighScore: currentLevelHigh,
    );
  }

  void _handleGameOver() {
    setState(() {
      gameOver = true;
      awaitingInput = false;
    });

    // Save high score
    _saveLevelHighScore(score);

    // Replace dialog with custom overlay
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => GameOverScreen(
          score: score,
          onRetry: () {
            Navigator.of(context).pop(); // Close game over screen
            setState(() {
              _initializeGame(); // Restart the current level
              _generateLevel();
            });
          },
          onExit: () {
            Navigator.of(context).pop(); // Close game over screen
            Navigator.of(context).pop(); // Return to level selection
          },
        ),
      ),
    );
  }

  Future<void> _saveLevelHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentLevelHigh = prefs.getInt('highScore_level_$level') ?? 0;

    if (score > currentLevelHigh) {
      await prefs.setInt('highScore_level_$level', score);
    }
  }

  void _showErrorAnimation() {
    // Flash the screen red
    OverlayEntry entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.red.withAlpha(76), // 0.3 opacity = 76/255
        ),
      ),
    );

    Overlay.of(context).insert(entry);

    Future.delayed(const Duration(milliseconds: 200), () {
      entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Level $level',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0D3445).withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4ECDC4),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D3445),
                  Color(0xFF042538),
                  Color(0xFF021824),
                ],
              ),
            ),
          ),

          // Animated background effects
          ValueListenableBuilder(
            valueListenable: _backgroundTimeNotifier,
            builder: (context, time, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: GameBackgroundPainter(
                  time: time,
                  particles: _backgroundParticles,
                ),
              );
            },
          ),

          // Game content
          Column(
            children: [
              // Increased space for status bar and app bar to avoid overlap
              SizedBox(height: MediaQuery.of(context).padding.top + 70),

              // Lives display with enhanced styling - moved down a bit
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      maxLives,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: index < lives ? 1.0 : 0.3,
                          child: Icon(
                            Icons.favorite,
                            color: index < lives ? Colors.red : Colors.grey,
                            size: 28,
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Game status indicator with improved styling
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: showingSequence
                      ? const Color(0xFF4ECDC4) // Now matches our theme
                      : (awaitingInput ? Colors.green : Colors.grey.shade700),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 3),
                      blurRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                width: double.infinity,
                child: Text(
                  gameStatusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // Game area
              Expanded(
                child: Stack(
                  children: [
                    // Dots display
                    for (final dot in dots)
                      Positioned(
                        left: dot.position.dx,
                        top: dot.position.dy,
                        child: GestureDetector(
                          onTap: () => _handleDotTap(dot.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width:
                                dot.isHighlighted ? dot.size * 1.3 : dot.size,
                            height:
                                dot.isHighlighted ? dot.size * 1.3 : dot.size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  dot.isHighlighted
                                      ? Colors.orange
                                      : const Color(0xFF4ECDC4),
                                  dot.isHighlighted
                                      ? Colors.orange.shade700
                                      : Colors.blue.shade700,
                                ],
                                center: const Alignment(-0.3, -0.3),
                                focal: const Alignment(-0.5, -0.5),
                                focalRadius: 0.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: dot.isHighlighted
                                      ? Colors.orange.withOpacity(0.8)
                                      : const Color(
                                          0xFF4ECDC4,
                                        ).withOpacity(0.4),
                                  blurRadius: dot.isHighlighted ? 20 : 10,
                                  spreadRadius: dot.isHighlighted ? 5 : 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 150),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: dot.isHighlighted ? 24 : 16,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text('${dot.id + 1}'),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Countdown overlay
                    if (countdownNumber != null)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: AnimatedScale(
                                scale: countdownNumber == 0 ? 1.5 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: countdownNumber == 0
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.blue.withOpacity(0.3),
                                    border: Border.all(
                                      color: countdownNumber == 0
                                          ? Colors.green
                                          : Colors.blue,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (countdownNumber == 0
                                                ? Colors.green
                                                : Colors.blue)
                                            .withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    countdownNumber == 0
                                        ? "GO!"
                                        : countdownNumber.toString(),
                                    style: TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(2, 2),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _backgroundAnimationTimer?.cancel();
    _backgroundTimeNotifier.dispose();

    for (var controller in moveControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

// New Game Results Screen
class GameResultsScreen extends StatelessWidget {
  final int level;
  final int score;
  final int timeBonus;
  final int perfectBonus;
  final LevelAchievement achievement;
  final VoidCallback onContinue;

  const GameResultsScreen({
    Key? key,
    required this.level,
    required this.score,
    required this.timeBonus,
    required this.perfectBonus,
    required this.achievement,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF0D3445),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: const Color(0xFF4ECDC4).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(
                    color: const Color(0xFF4ECDC4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  achievement.isSpecialAchievement
                      ? Icons.emoji_events
                      : Icons.check_circle,
                  size: 40,
                  color: achievement.isSpecialAchievement
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                achievement.isSpecialAchievement
                    ? 'Congratulations!'
                    : 'Level Complete',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              // Level description
              Text(
                'Level $level Completed',
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF4ECDC4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Scores
              _buildScoreRow('Base Score', score - timeBonus - perfectBonus),
              _buildScoreRow('Time Bonus', timeBonus),
              if (perfectBonus > 0)
                _buildScoreRow('Perfect Clear Bonus', perfectBonus),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                height: 2,
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
              ),

              _buildScoreRow('Final Score', score, isTotal: true),
              const SizedBox(height: 24),

              // Achievements
              if (achievement.isNewHighScore)
                _buildAchievementRow(
                  'New High Score!',
                  'Previous: ${achievement.previousHighScore}',
                  Icons.star,
                  const Color(0xFFFFD700),
                ),

              if (achievement.isNewLevelUnlocked)
                _buildAchievementRow(
                  'New Level Unlocked!',
                  'Keep going for more challenges',
                  Icons.lock_open,
                  const Color(0xFF4ECDC4),
                ),

              const SizedBox(height: 32),

              // Continue button
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 6,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, int value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 20 : 18,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          Text(
            '+$value',
            style: TextStyle(
              fontSize: isTotal ? 24 : 18,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF4ECDC4) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementRow(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// New Game Over screen
class GameOverScreen extends StatelessWidget {
  final int score;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const GameOverScreen({
    Key? key,
    required this.score,
    required this.onRetry,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF0D3445),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Game Over',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 24),

              // Score
              const Text(
                'Final Score',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Message
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Keep trying! You\'ll get better with practice.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onExit,
                      icon: const Icon(Icons.menu),
                      label: const Text('Menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.replay),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
