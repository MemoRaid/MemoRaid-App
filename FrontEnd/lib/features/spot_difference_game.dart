import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this for HapticFeedback
import 'dart:math';
import 'dart:async';

class SpotDifferenceGame extends StatefulWidget {
  const SpotDifferenceGame({Key? key}) : super(key: key);

  @override
  _SpotDifferenceGameState createState() => _SpotDifferenceGameState();
}

class _SpotDifferenceGameState extends State<SpotDifferenceGame>
    with TickerProviderStateMixin {
  // Game state variables
  int score = 0;
  int currentLevel = 1;
  int foundDifferences = 0;
  int totalDifferences = 5;
  List<bool> differencesFound = List.generate(5, (_) => false);
  Timer? _timer;
  int _timeRemaining = 120; // 2 minutes per level

  // Animation controllers
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  // Marker positions for found differences
  List<Map<String, dynamic>> markers = [];

  final Color baseColor = const Color(0xFF0D3445);
  final Color accentColor = const Color(0xFF2196F3);

  // Sample image pairs
  final List<Map<String, dynamic>> levels = [
    {
      'originalImage': 'lib/assets/images/spot1.jpeg',
      'modifiedImage': 'lib/assets/images/spot2.jpeg',
      'description': 'Find differences between these two images',
      'hotspots': [
        // These values should be updated to match the actual differences in your images
        {'x': 150, 'y': 170, 'radius': 30, 'hint': 'Look at the top left area'},
        {'x': 320, 'y': 220, 'radius': 30, 'hint': 'Check the middle section'},
        {
          'x': 200,
          'y': 300,
          'radius': 30,
          'hint': 'Notice anything different in the bottom half?'
        },
        {
          'x': 380,
          'y': 180,
          'radius': 30,
          'hint': 'Look for color or object changes'
        },
        {
          'x': 100,
          'y': 250,
          'radius': 30,
          'hint': 'Something is missing or added here'
        },
      ],
    },
    // More levels would be added here
  ];

  // Add these new variables
  bool showingHintAnimation = false;
  Map<String, dynamic>? hintHotspot;
  Timer? _hintTimer;
  bool firstTimePlaying = true;
  bool showOverlay = false;
  double overlayOpacity = 0.5;  
ese variables for wrong click animation
  @overrideTimer;
  void initState() {nimation = false;
    super.initState();  Offset? wrongClickPosition;
= true;
    // Initialize timer
    _startTimer();  @override

    // Initialize animations
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),timer
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(oller = AnimationController(
        CurvedAnimation(
            parent: _pulseAnimationController, curve: Curves.easeInOut));      vsync: this,

    // Show tutorial on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {ouble>(begin: 1.0, end: 1.2).animate(
      if (firstTimePlaying) {
        _showTutorial();     parent: _pulseAnimationController, curve: Curves.easeInOut));
      }
    }); // Show tutorial on first load
  }    WidgetsBinding.instance.addPostFrameCallback((_) {
irstTimePlaying) {
  @overrideial();
  void dispose() {
    _timer?.cancel();
    _pulseAnimationController.dispose();
    _hintTimer?.cancel();
    super.dispose();override
  }  void dispose() {

  void _startTimer() {ntroller.dispose();
    _timer?.cancel();
    _timeRemaining = 120; // Reset timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {;
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;er() {
        } else {
          _timer?.cancel();eset timer
          _showTimeUpDialog();r = Timer.periodic(const Duration(seconds: 1), (timer) {
        }State(() {
      }); if (_timeRemaining > 0) {
    });       _timeRemaining--;
  }        } else {

  String _formatTime(int seconds) {;
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}'; });
  }  }

  @override
  Widget build(BuildContext context) {
    final currentLevelData = levels[currentLevel - 1];    int secs = seconds % 60;
oString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: baseColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: baseColor.withOpacity(0.8),lData = levels[currentLevel - 1];
        elevation: 0,
        title: Text(
          'Spot the Difference',Color,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,),
            color: Colors.white.withOpacity(0.95),ation: 0,
          ),tle: Text(
        ),e Difference',
        actions: [tStyle(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 12),acity(0.95),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),s: [
            ),
            child: Row(t EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [t: 12),
                const Icon(Icons.emoji_events,
                    color: Colors.amberAccent, size: 20),city(0.15),
                const SizedBox(width: 8),adius: BorderRadius.circular(20),
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,ccent, size: 20),
                    color: Colors.white,t SizedBox(width: 8),
                  ),xt(
                ),  'Score: $score',
              ],    style: const TextStyle(
            ),        fontSize: 16,
          ),          fontWeight: FontWeight.w600,
        ],            color: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              baseColor,
              baseColor
                  .withBlue(baseColor.blue + 15)
                  .withGreen(baseColor.green + 10),gin: Alignment.topCenter,
            ],end: Alignment.bottomCenter,
          ),  colors: [
        ),
        child: SafeArea(
          child: Column(Blue(baseColor.blue + 15)
            children: [aseColor.green + 10),
              // Game info bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(20, vertical: 12),
                      color: Colors.black.withOpacity(0.1),sets.fromLTRB(16, 8, 16, 0),
                      blurRadius: 8,
                      offset: const Offset(0, 4),r: Colors.white.withOpacity(0.1),
                    ),rderRadius: BorderRadius.circular(16),
                  ],boxShadow: [
                ),ow(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,ius: 8,
                  children: [ffset(0, 4),
                    // Level progress
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gnment.spaceBetween,
                          'Level $currentLevel',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,xisAlignment.start,
                            color: Colors.white,en: [
                          ),xt(
                        ),
                        const SizedBox(height: 4),onst TextStyle(
                        Container( 16,
                          width: 150,t: FontWeight.bold,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),t SizedBox(height: 4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: foundDifferences / totalDifferences,ration(
                            child: Container(ity(0.2),
                              decoration: BoxDecoration((5),
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.lightBlueAccent,erLeft,
                                    Colors.blueAccenttor: foundDifferences / totalDifferences,
                                  ], Container(
                                ),
                                borderRadius: BorderRadius.circular(5),gradient: const LinearGradient(
                              ),    colors: [
                            ),        Colors.lightBlueAccent,
                          ),          Colors.blueAccent
                        ),
                        const SizedBox(height: 4),   ),
                        Text(
                          '$foundDifferences/$totalDifferences differences found',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),nst SizedBox(height: 4),
                        ),Text(
                      ],    '$foundDifferences/$totalDifferences differences found',
                    ),yle: TextStyle(
                    // TimerntSize: 12,
                    Container(ity(0.8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _timeRemaining < 30
                            ? Colors.redAccent.withOpacity(0.3)
                            : Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,ainer(
                      ),ts.all(12),
                      child: AnimatedBuilder(
                        animation: _pulseAnimationController,
                        builder: (context, child) {thOpacity(0.3)
                          return Transform.scale((0.15),
                            scale: _timeRemaining < 30
                                ? _pulseAnimation.value
                                : 1.0,lder(
                            child: Text(er,
                              _formatTime(_timeRemaining),d) {
                              style: TextStyle(ale(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _timeRemaining < 30
                                    ? Colors.redAccent
                                    : Colors.white,ormatTime(_timeRemaining),
                              ),style: TextStyle(
                            ),    fontSize: 18,
                          );      fontWeight: FontWeight.bold,
                        },        color: _timeRemaining < 30
                      ),              ? Colors.redAccent
                    ),                : Colors.white,
                  ],            ),
                ),            ),
              ),                          );

              // Instructions card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amberAccent.withOpacity(0.3),eInsets.symmetric(horizontal: 12, vertical: 8),
                    width: 1,in: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  ),coration: BoxDecoration(
                ),lors.amberAccent.withOpacity(0.15),
                child: Row(s: BorderRadius.circular(12),
                  children: [r.all(
                    const Icon(withOpacity(0.3),
                      Icons.lightbulb_outline,
                      color: Colors.amberAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        levels[currentLevel - 1]['description'],,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,SizedBox(width: 8),
                        ),nded(
                      ),child: Text(
                    ),currentLevel - 1]['description'],
                    IconButton(nst TextStyle(
                      icon: Icon(
                        showOverlay ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          showOverlay = !showOverlay;wOverlay ? Icons.visibility_off : Icons.visibility,
                        });color: Colors.white70,
                      },
                      tooltip: showOverlay ? 'Hide Overlay' : 'Show Overlay',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),  setState(() {
                    ),      showOverlay = !showOverlay;
                  ],      });
                ),      },
              ),                      tooltip: showOverlay ? 'Hide Overlay' : 'Show Overlay',

              // Game images - Modified to stack vertically for landscape imagesonstraints: const BoxConstraints(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),r landscape images
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),r: Colors.white.withOpacity(0.05),
                        ),rderRadius: BorderRadius.circular(20),
                      ],boxShadow: [
                    ),
                    child: ClipRRect(,
                      borderRadius: BorderRadius.circular(20),: 10,
                      child: Column(
                        // Changed from Row to Column
                        children: [
                          // Original image
                          Expanded(
                            child: Stack(rcular(20),
                              fit: StackFit.expand,
                              children: [olumn
                                GestureDetector(
                                  onTapDown: (details) =>
                                      _checkDifference(details, true),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 1),pDown: (details) =>
                                    ),details, true),
                                    child: Image.asset(
                                      currentLevelData['originalImage'],
                                      fit: BoxFit.contain, // Changed to contain
                                      errorBuilder: (ctx, obj, trace) =>ors.white.withOpacity(0.1),
                                          Container(
                                        color: baseColor.withOpacity(0.5),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,in, // Changed to contain
                                            children: [ obj, trace) =>
                                              const Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                color: Colors.white70,
                                                size: 48,AxisSize: MainAxisSize.min,
                                              ),
                                              const SizedBox(height: 12), Icon(
                                              Text(
                                                'Original Image',pported_outlined,
                                                style: TextStyle(,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 16,t SizedBox(height: 12),
                                                ),xt(
                                              ),  'Original Image',
                                            ],    style: TextStyle(
                                          ),        color: Colors.white
                                        ),              .withOpacity(0.8),
                                      ),            fontSize: 16,
                                    ),            ),
                                  ),            ),
                                ),
                                // Draw markers for this image
                                ...markers.map((marker) {
                                  return Positioned(
                                    left: marker['x'] - 15,
                                    top: marker['y'] - 15,
                                    child: CircleAvatar(
                                      radius: 15,is image
                                      backgroundColor:
                                          Colors.greenAccent.withOpacity(0.7),
                                      child: const Icon(] - 15,
                                        Icons.check,
                                        color: Colors.white,Avatar(
                                        size: 20,dius: 15,
                                      ),backgroundColor:
                                    ),      Colors.greenAccent.withOpacity(0.7),
                                  ); const Icon(
                                }).toList(),                                        Icons.check,

                                // Add hint animation circle
                                if (showingHintAnimation && hintHotspot != null)
                                  Positioned(
                                    left: hintHotspot!['x'] - 25,
                                    top: hintHotspot!['y'] - 25,
                                    child: AnimatedBuilder(
                                      animation: _pulseAnimationController,
                                      builder: (context, child) {&& hintHotspot != null)
                                        return Container(
                                          width: 50,!['x'] - 25,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,nController,
                                            border: Border.all(
                                              color: Colors.yellowAccent
                                                  .withOpacity(
                                                0.6 +
                                                    (_pulseAnimation.value -n(
                                                            1.0) *circle,
                                                        0.4,er: Border.all(
                                              ),lors.yellowAccent
                                              width: 3,    .withOpacity(
                                            ),    0.6 +
                                          ),          (_pulseAnimation.value -
                                        );                    1.0) *
                                      },                  0.4,
                                    ),          ),
                                  ),                                              width: 3,

                                // Show debug overlay if enabled
                                if (showOverlay)
                                  ...levels[currentLevel - 1]['hotspots']
                                      .map<Widget>((hotspot) {
                                    final index = levels[currentLevel - 1]
                                            ['hotspots']
                                        .indexOf(hotspot);
                                    final found = differencesFound[index];                                if (showOverlay)
el - 1]['hotspots']
                                    return Positioned(
                                      left: hotspot['x'] - 30,entLevel - 1]
                                      top: hotspot['y'] - 30,]
                                      child: Container(otspot);
                                        width: 60,ifferencesFound[index];
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,,
                                          border: Border.all(- 30,
                                            color: found
                                                ? Colors.greenAccent
                                                    .withOpacity(overlayOpacity)
                                                : Colors.redAccent.withOpacity(
                                                    overlayOpacity),hape.circle,
                                            width: 2,rder: Border.all(
                                          ),nd
                                          color: found
                                              ? Colors.greenAccent.withOpacity(yOpacity)
                                                  overlayOpacity * 0.3)y(
                                              : Colors.redAccent.withOpacity(
                                                  overlayOpacity * 0.2),  width: 2,
                                        ),
                                        child: Center(
                                          child: Text(nAccent.withOpacity(
                                            '${index + 1}',ity * 0.3)
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                  overlayOpacity + 0.2),
                                              fontWeight: FontWeight.bold, Center(
                                            ),ild: Text(
                                          ),  '${index + 1}',
                                        ),    style: TextStyle(
                                      ),        color: Colors.white.withOpacity(
                                    );    overlayOpacity + 0.2),
                                  }).toList(),              fontWeight: FontWeight.bold,
                              ],              ),
                            ),              ),
                          ),                                        ),

                          // Divider - horizontal now);
                                  }).toList(),

                                // Add wrong click animation for original imagecolor: accentColor.withOpacity(0.6),
                                if (showWrongClickAnimation && wrongClickPosition != null && isOriginalImage)                          ),
                                  Positioned(
                                    left: wrongClickPosition!.dx - 20,ed image
                                    top: wrongClickPosition!.dy - 20,
                                    child: FadeTransition(
                                      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(it.expand,
                                        CurvedAnimation(
                                          parent: _pulseAnimationController,
                                          curve: const Interval(0.0, 1.0),
                                        ),nce(details, false),
                                      ),
                                      child: Container(tion(
                                        width: 40,
                                        height: 40,ors.white.withOpacity(0.1),
                                        decoration: BoxDecoration(    width: 1),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.redAccent, width: 2),
                                        ),
                                        child: const Center( contain
                                          child: Icon((ctx, obj, trace) =>
                                            Icons.close,
                                            color: Colors.redAccent,or.withOpacity(0.5),
                                            size: 20,
                                          ),
                                        ),e: MainAxisSize.min,
                                      ),
                                    ),con(
                                  ),
                              ],ed_outlined,
                            ),lors.white70,
                          ),size: 48,

                          // Divider - horizontal now SizedBox(height: 12),
                          Container(
                            height: 4,
                            color: accentColor.withOpacity(0.6),
                          ),
ity(0.8),
                          // Modified imagefontSize: 16,
                          Expanded(),
                            child: Stack(),
                              fit: StackFit.expand,],
                              children: [),
                                GestureDetector(),
                                  onTapDown: (details) =>),
                                      _checkDifference(details, false),),
                                  child: Container(),
                                    decoration: BoxDecoration(
                                      border: Border.all(image
                                          color: Colors.white.withOpacity(0.1),er) {
                                          width: 1),
                                    ),,
                                    child: Image.asset(5,
                                      currentLevelData['modifiedImage'],Avatar(
                                      fit: BoxFit.contain, // Changed to contain
                                      errorBuilder: (ctx, obj, trace) =>
                                          Container(cent.withOpacity(0.7),
                                        color: baseColor.withOpacity(0.5),con(
                                        child: Center(
                                          child: Column(lors.white,
                                            mainAxisSize: MainAxisSize.min,size: 20,
                                            children: [),
                                              const Icon(),
                                                Icons
                                                    .image_not_supported_outlined,                                }).toList(),
                                                color: Colors.white70,
                                                size: 48,
                                              ),ntAnimation && hintHotspot != null)
                                              const SizedBox(height: 12),
                                              Text(,
                                                'Modified Image',- 25,
                                                style: TextStyle(
                                                  color: Colors.whiteontroller,
                                                      .withOpacity(0.8),child) {
                                                  fontSize: 16,iner(
                                                ),
                                              ),
                                            ],(
                                          ),cle,
                                        ),
                                      ),lowAccent
                                    ),thOpacity(
                                  ),
                                ),on.value -
                                // Draw markers for this image1.0) *
                                ...markers.map((marker) {        0.4,
                                  return Positioned(
                                    left: marker['x'] - 15,width: 3,
                                    top: marker['y'] - 15,),
                                    child: CircleAvatar(),
                                      radius: 15,);
                                      backgroundColor:},
                                          Colors.greenAccent.withOpacity(0.7),),
                                      child: const Icon(                                  ),
                                        Icons.check,
                                        color: Colors.white,erlay if enabled (for second image too)
                                        size: 20,
                                      ),'hotspots']
                                    ),
                                  );[currentLevel - 1]
                                }).toList(),

                                // Add hint animation circle for this image too                                    final found = differencesFound[index];
                                if (showingHintAnimation && hintHotspot != null)
                                  Positioned(
                                    left: hintHotspot!['x'] - 25,,
                                    top: hintHotspot!['y'] - 25, - 30,
                                    child: AnimatedBuilder(iner(
                                      animation: _pulseAnimationController,
                                      builder: (context, child) {
                                        return Container((
                                          width: 50,cle,
                                          height: 50,.all(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all()
                                              color: Colors.yellowAccentithOpacity(
                                                  .withOpacity(verlayOpacity),
                                                0.6 +width: 2,
                                                    (_pulseAnimation.value -
                                                            1.0) *
                                                        0.4,Opacity(
                                              ),
                                              width: 3,city(
                                            ),        overlayOpacity * 0.2),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
acity(
                                // Show debug overlay if enabled (for second image too)
                                if (showOverlay)fontWeight: FontWeight.bold,
                                  ...levels[currentLevel - 1]['hotspots']),
                                      .map<Widget>((hotspot) {),
                                    final index = levels[currentLevel - 1]),
                                            ['hotspots']),
                                        .indexOf(hotspot);
                                    final found = differencesFound[index];  }).toList(),
],
                                    return Positioned(),
                                      left: hotspot['x'] - 30,),
                                      top: hotspot['y'] - 30,],
                                      child: Container(),
                                        width: 60,),
                                        height: 60,),
                                        decoration: BoxDecoration(),
                                          shape: BoxShape.circle,              ),
                                          border: Border.all(
                                            color: foundntrols
                                                ? Colors.greenAccent
                                                    .withOpacity(overlayOpacity)
                                                : Colors.redAccent.withOpacity(zontal: 20),
                                                    overlayOpacity),romLTRB(16, 0, 16, 16),
                                            width: 2,
                                          ),
                                          color: foundborderRadius: BorderRadius.circular(16),
                                              ? Colors.greenAccent.withOpacity(
                                                  overlayOpacity * 0.3)
                                              : Colors.redAccent.withOpacity(gnment: MainAxisAlignment.spaceEvenly,
                                                  overlayOpacity * 0.2),
                                        ),
                                        child: Center(ghtbulb_outline,
                                          child: Text(
                                            '${index + 1}',,
                                            style: TextStyle(color: Colors.amber,
                                              color: Colors.white.withOpacity(
                                                  overlayOpacity + 0.2),
                                              fontWeight: FontWeight.bold,sh,
                                            ),
                                          ),
                                        ),color: Colors.blueAccent,
                                      ),
                                    );
                                  }).toList(),it_to_app,

                                // Add wrong click animation for modified imageor.of(context).pop(),
                                if (showWrongClickAnimation && wrongClickPosition != null && !isOriginalImage)color: Colors.redAccent,
                                  Positioned(),
                                    left: wrongClickPosition!.dx - 20,],
                                    top: wrongClickPosition!.dy - 20,),
                                    child: FadeTransition(),
                                      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(],
                                        CurvedAnimation(),
                                          parent: _pulseAnimationController,),
                                          curve: const Interval(0.0, 1.0),),
                                        ), );
                                      ),  }
                                      child: Container(
                                        width: 40,({
                                        height: 40,,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle, onPressed,
                                          border: Border.all(color: Colors.redAccent, width: 2),quired Color color,
                                        ),
                                        child: const Center(con(
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.redAccent,withOpacity(0.2),
                                            size: 20,
                                          ),etric(horizontal: 20, vertical: 12),
                                        ),
                                      ),
                                    ),side: BorderSide(color: color.withOpacity(0.5), width: 1),
                                  ),),
                              ],
                            ),con, size: 20),
                          ),ext(
                        ],
                      ),xtStyle(
                    ),
                  ),fontWeight: FontWeight.bold,
                ),),
              ),),
    );
  }

  void _checkDifference(TapDownDetails details, bool isOriginal) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    final hotspots = levels[currentLevel - 1]['hotspots'];

    for (int i = 0; i < hotspots.length; i++) {
      if (differencesFound[i]) continue;

      final hotspot = hotspots[i];
      final dx = localPosition.dx - hotspot['x'];
      final dy = localPosition.dy - hotspot['y'];
      final distance = sqrt(dx * dx + dy * dy);

      if (distance <= hotspot['radius']) {
        setState(() {
          differencesFound[i] = true;
          foundDifferences++;
          score += 10 + (_timeRemaining ~/ 10); // Bonus points for speed

          // Add marker for the found difference
          markers.add({
            'x': hotspot['x'],
            'y': hotspot['y'],
          });

          // Show animation and check level completion
          if (foundDifferences >= totalDifferences) {
            _timer?.cancel();
            _showLevelCompleteDialog();
          } else {
            _showFoundDifferenceAnimation();
          }
        });
        break;
      }
    }
  }

  void _showFoundDifferenceAnimation() {
    // Show a more visually appealing animation
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent),
            const SizedBox(width: 10),
            const Text(
              'Difference found!',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '+${10 + (_timeRemaining ~/ 10)} pts',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: baseColor,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: baseColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Time\'s Up!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_off, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              'You found $foundDifferences of $totalDifferences differences.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Your score: $score points',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child: const Text('Exit Game'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                foundDifferences = 0;
                differencesFound =
                    List.generate(totalDifferences, (_) => false);
                markers.clear();
                _startTimer();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showLevelCompleteDialog() {
    // Calculate completion bonus
    int timeBonus = _timeRemaining * 2;
    int totalScore = score + timeBonus;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: baseColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 28),
            const SizedBox(width: 10),
            const Text('Level Complete!',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              'You found all $totalDifferences differences!',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Base Score:',
                    style: TextStyle(color: Colors.white70)),
                Text(
                  '$score pts',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Time Bonus:',
                    style: TextStyle(color: Colors.white70)),
                Text(
                  '$timeBonus pts',
                  style: const TextStyle(
                      color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(color: Colors.white30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Score:',
                    style: TextStyle(color: Colors.white)),
                Text(
                  '$totalScore pts',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to home
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
            ),
            child: const Text('Exit Game'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _goToNextLevel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }

  void _goToNextLevel() {
    if (currentLevel < levels.length) {
      setState(() {
        currentLevel++;
        foundDifferences = 0;
        differencesFound = List.generate(totalDifferences, (_) => false);
        markers.clear();
        _startTimer();
      });
    } else {
      // Game complete
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: baseColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.star, color: Colors.amberAccent, size: 28),
              SizedBox(width: 10),
              Text('Congratulations!', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                'You completed all levels!',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: accentColor.withOpacity(0.2),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: accentColor.withOpacity(0.5),
                      child: Text(
                        score.toString(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'You\'ve earned a spot on the leaderboard!',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to previous screen
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
              child: const Text('Exit Game'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to home
                // In a real app, you'd navigate to the leaderboard here
                // Navigator.of(context).pushNamed('/achievements');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              child: const Text('View Leaderboard'),
            ),
          ],
        ),
      );
    }
  }

  void _showHint() {
    // Find the first unfound difference
    int hintIndex = differencesFound.indexWhere((found) => !found);
    if (hintIndex >= 0) {
      final hotspot = levels[currentLevel - 1]['hotspots'][hintIndex];

      // Reduce score when using hint
      setState(() {
        score -= 5;
        if (score < 0) score = 0;

        // Save hotspot for animation
        hintHotspot = hotspot;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: baseColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amberAccent, size: 24),
              SizedBox(width: 10),
              Text('Hint', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hotspot['hint'] ??
                    'Look carefully at both images - there\'s a difference in one area!',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.touch_app,
                    color: Colors.blueAccent,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '-5 points for using hint',
                  style: TextStyle(
                    color: Colors.redAccent.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Show hint animation for 3 seconds
                setState(() {
                  showingHintAnimation = true;
                });

                _hintTimer?.cancel();
                _hintTimer = Timer(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      showingHintAnimation = false;
                      hintHotspot = null;
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Show Hint'),
            ),
          ],
        ),
      );
    }
  }

  void _restartLevel() {
    setState(() {
      foundDifferences = 0;
      differencesFound = List.generate(totalDifferences, (_) => false);
      markers.clear();
      score = score > 10 ? score - 10 : 0; // Small penalty for restarting
      _startTimer();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Level restarted'),
        backgroundColor: baseColor,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTutorial() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: baseColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.lightBlueAccent, size: 28),
            const SizedBox(width: 10),
            const Text('How to Play', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Find $totalDifferences differences between the two images',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              '2. Tap directly on the difference when you spot it',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              '3. Be quick! You earn more points for finding differences faster',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              '4. Use hints if you\'re stuck, but you\'ll lose 5 points',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '5. Enable the visibility overlay for help while learning',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timelapse, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      'You have ${_formatTime(_timeRemaining)} to finish each level',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              firstTimePlaying = false;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Playing'),
          ),
        ],
      ),
    );
  }
}
