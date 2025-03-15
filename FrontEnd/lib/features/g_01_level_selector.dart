import 'package:flutter/material.dart';

class LevelSelector extends StatelessWidget {
  final int totalLevels;
  final int currentLevel;
  final List<bool> completedLevels;
  final Function(int) onLevelSelected;

  const LevelSelector({
    Key? key,
    required this.totalLevels,
    required this.currentLevel,
    required this.completedLevels,
    required this.onLevelSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF0D3445);
    final Color primaryLightColor = Color(0xFF164C64);

    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalLevels,
        itemBuilder: (context, index) {
          bool isUnlocked = _isLevelUnlocked(index);
          bool isCompleted = completedLevels[index];
          bool isCurrent = index == currentLevel;

          return GestureDetector(
            onTap: () {
              if (isUnlocked) {
                onLevelSelected(index);
              } else {
                _showLevelLockedMessage(context);
              }
            },
            child: Container(
              width: 50,
              margin: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isCurrent
                    ? primaryColor
                    : isCompleted
                        ? Colors.green.shade500
                        : isUnlocked
                            ? primaryLightColor.withOpacity(0.7)
                            : Colors.grey.shade400,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? Colors.white : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check, color: Colors.white)
                    : !isUnlocked
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(
                                Icons.lock,
                                color: Colors.white.withOpacity(0.8),
                                size: 18,
                              ),
                            ],
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isLevelUnlocked(int level) {
    // First level is always unlocked
    if (level == 0) return true;

    // A level is unlocked if the previous level is completed
    return completedLevels[level - 1];
  }

  void _showLevelLockedMessage(BuildContext context) {
    // Show a centered modal dialog instead of a snackbar
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D3445),
                  Color(0xFF164C64),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Level Locked',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Complete the previous level to unlock this one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF0D3445),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Got it',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
