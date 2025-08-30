import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/game.dart';
import 'services/signalr_service.dart';

class GameScoringPage extends StatefulWidget {
  final Game game;

  const GameScoringPage({super.key, required this.game});

  @override
  State<GameScoringPage> createState() => _GameScoringPageState();
}

class _GameScoringPageState extends State<GameScoringPage> {
  late int _points1;
  late int _points2;

  @override
  void initState() {
    super.initState();
    _points1 = widget.game.points1;
    _points2 = widget.game.points2;
  }

  void _updateScore(int team, int change) async {
    int newPoints1 = _points1;
    int newPoints2 = _points2;

    if (team == 1) {
      newPoints1 = (_points1 + change).clamp(
        0,
        6,
      ); // Prevent negative scores and max 6
    } else {
      newPoints2 = (_points2 + change).clamp(
        0,
        6,
      ); // Prevent negative scores and max 6
    }

    // Check if combined score would exceed 6
    if (newPoints1 + newPoints2 > 6) {
      return; // Don't allow the change if it would exceed the limit
    }

    // Apply the changes
    if (team == 1) {
      _points1 = newPoints1;
    } else {
      _points2 = newPoints2;
    }

    setState(() {});

    try {
      final signalR = Provider.of<SignalRService>(context, listen: false);
      await signalR.sendGameScoreUpdate(_points1, _points2, widget.game.id);
    } catch (e) {
      // Revert the change if the update failed
      if (team == 1) {
        _points1 = widget.game.points1;
      } else {
        _points2 = widget.game.points2;
      }
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update score: $e')));
      }
    }
  }

  // Helper method to determine team area color based on match result
  Color _getTeamAreaColor(int team) {
    // Check if match is over (one team has 4+ points or both have 3 points)
    if (_points1 >= 4) {
      // Würzburg won - both teams show blue
      return const Color(0xFF2196F3);
    } else if (_points2 >= 4) {
      // Kitzingen won - both teams show red
      return const Color(0xFFF44336);
    } else if (_points1 == 3 && _points2 == 3) {
      // Tie - both teams show yellow
      return const Color(0xFFFFEB3B);
    } else {
      // Match not over yet - use default team colors
      return team == 1 ? Colors.blue.shade50 : Colors.red.shade50;
    }
  }

  // Helper method to determine border color based on match result
  Color _getTeamBorderColor(int team) {
    if (_points1 >= 4) {
      // Würzburg won - both teams show blue borders
      return const Color(0xFF2196F3);
    } else if (_points2 >= 4) {
      // Kitzingen won - both teams show red borders
      return const Color(0xFFF44336);
    } else if (_points1 == 3 && _points2 == 3) {
      // Tie - both teams show darker yellow borders
      return const Color(0xFFFFC107);
    } else {
      // Match not over yet - use default team border colors
      return team == 1 ? Colors.blue.shade200 : Colors.red.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final team1Players = widget.game.playerNames.take(2).toList();
    final team2Players = widget.game.playerNames.skip(2).toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF959F96), Color(0xFFE5E5E5), Color(0xFFE5E5E5)],
            stops: [0.0, 0.7, 1.0],
            radius: 0.8,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F2D9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.golf_course,
                            size: 32,
                            color: Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.game.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Teams side by side
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Würzburg (Left Side)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _getTeamAreaColor(1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            border: Border.all(
                              color: _getTeamBorderColor(1),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'WÜRZBURG',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...team1Players.map(
                                (player) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    player,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '$_points1',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () => _updateScore(1, -1),
                                    child: Icon(
                                      Icons.remove,
                                      size: 32,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _updateScore(1, 1),
                                    child: Icon(
                                      Icons.add,
                                      size: 32,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Kitzingen (Right Side)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _getTeamAreaColor(2),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            border: Border.all(
                              color: _getTeamBorderColor(2),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'KITZINGEN',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...team2Players.map(
                                (player) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    player,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '$_points2',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () => _updateScore(2, -1),
                                    child: Icon(
                                      Icons.remove,
                                      size: 32,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _updateScore(2, 1),
                                    child: Icon(
                                      Icons.add,
                                      size: 32,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE1F2D9),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Back to Games',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/leaderboard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
