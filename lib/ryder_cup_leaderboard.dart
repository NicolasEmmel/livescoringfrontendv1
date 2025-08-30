import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'models/game.dart';
import 'services/signalr_service.dart';
import 'landingpage.dart';

class RyderCupLeaderboardPage extends StatefulWidget {
  final String? source; // 'landing' or 'scoring'
  final int? currentHole; // Current hole when coming from scoring page

  const RyderCupLeaderboardPage({super.key, this.source, this.currentHole});

  @override
  State<RyderCupLeaderboardPage> createState() =>
      _RyderCupLeaderboardPageState();
}

class _RyderCupLeaderboardPageState extends State<RyderCupLeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    final signalR = Provider.of<SignalRService>(context);

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
          child: signalR.isConnecting
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E7D32),
                        ),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Verbinde mit Server...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                )
              : signalR.connectionError != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Verbindungsfehler',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          signalR.connectionError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          signalR.clearError();
                          try {
                            await signalR.startConnection();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erneuter Verbindungsversuch fehlgeschlagen: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Erneut versuchen'),
                      ),
                    ],
                  ),
                )
              : Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    if (gameProvider.games.isEmpty) {
                      return const Center(
                        child: Text(
                          'No games available.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }

                    // Calculate team standings from games
                    final teamScores = _calculateTeamScores(gameProvider.games);
                    final totalPoints =
                        gameProvider.games.length; // 1 point per game
                    final pointsToWin = (totalPoints / 2).floor() + 1;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header section
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
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    size: 32,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'LEADERBOARD',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Overall Team Progress Bar Graph
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Gesamtstand',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),

                                // Full-width progress bar
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey.shade200,
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Progress bar content using Row layout
                                      Row(
                                        children: [
                                          // Würzburg progress (left side)
                                          Expanded(
                                            flex: teamScores['Würzburg']!
                                                .round(),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        18,
                                                      ),
                                                      bottomLeft:
                                                          Radius.circular(18),
                                                    ),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade600,
                                                    Colors.blue.shade400,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Middle gap (remaining points)
                                          Expanded(
                                            flex:
                                                totalPoints -
                                                teamScores['Würzburg']!
                                                    .round() -
                                                teamScores['Kitzingen']!
                                                    .round(),
                                            child: Container(
                                              color: Colors.transparent,
                                            ),
                                          ),

                                          // Kitzingen progress (right side)
                                          Expanded(
                                            flex: teamScores['Kitzingen']!
                                                .round(),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topRight: Radius.circular(
                                                        18,
                                                      ),
                                                      bottomRight:
                                                          Radius.circular(18),
                                                    ),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.red.shade600,
                                                    Colors.red.shade400,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Green winning threshold line in the middle
                                      Center(
                                        child: Container(
                                          width: 3,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2E7D32),
                                            borderRadius: BorderRadius.circular(
                                              1.5,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 2,
                                                spreadRadius: 0,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Progress labels
                                      Positioned.fill(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 12,
                                              ),
                                              child: Text(
                                                _formatScore(
                                                  teamScores['Würzburg']!,
                                                ),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 12,
                                              ),
                                              child: Text(
                                                _formatScore(
                                                  teamScores['Kitzingen']!,
                                                ),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Winning threshold text
                                Text(
                                  'Punkte zum Sieg: $pointsToWin',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 20),

                                // Team points underneath
                                Row(
                                  children: [
                                    // Würzburg
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade600,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue.shade600
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _formatScore(
                                              teamScores['Würzburg']!,
                                            ),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                          Text(
                                            'Würzburg',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Kitzingen
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade600,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.red.shade600
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _formatScore(
                                              teamScores['Kitzingen']!,
                                            ),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                          Text(
                                            'Kitzingen',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Game Type Summaries
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Game type summaries
                                ..._getGameTypeSummaries(
                                  gameProvider.games,
                                ).entries.map((gameTypeEntry) {
                                  final gameType = gameTypeEntry.key;
                                  final summary = gameTypeEntry.value;
                                  final totalGames = summary['totalGames'] ?? 0;
                                  final maxScore =
                                      totalGames; // 1 point per game
                                  final europeScore = (summary['Würzburg'] ?? 0)
                                      .toDouble();
                                  final usaScore = (summary['Kitzingen'] ?? 0)
                                      .toDouble();

                                  // Only show game types that have games
                                  if (totalGames == 0) {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          gameType,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Compact progress display
                                      Row(
                                        children: [
                                          // Würzburg progress
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Würzburg',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  child: FractionallySizedBox(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    widthFactor: maxScore > 0
                                                        ? europeScore / maxScore
                                                        : 0.0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        gradient:
                                                            LinearGradient(
                                                              colors: [
                                                                Colors
                                                                    .blue
                                                                    .shade500,
                                                                Colors
                                                                    .blue
                                                                    .shade300,
                                                              ],
                                                            ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _formatScore(
                                                            europeScore,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 16),

                                          // USA progress
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Kitzingen',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.red.shade700,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  child: FractionallySizedBox(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    widthFactor: maxScore > 0
                                                        ? usaScore / maxScore
                                                        : 0.0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        gradient:
                                                            LinearGradient(
                                                              colors: [
                                                                Colors
                                                                    .red
                                                                    .shade500,
                                                                Colors
                                                                    .red
                                                                    .shade300,
                                                              ],
                                                            ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _formatScore(
                                                            usaScore,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                      const SizedBox(height: 20),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Bottom navigation
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Games Scores Button
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/games-scores',
                                    );
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF2E7D32),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 1,
                                          spreadRadius: 0,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.scoreboard,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Scores',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Home/Back Button
                                GestureDetector(
                                  onTap: () async {
                                    if (widget.source == 'landing') {
                                      // Disconnect from SignalR and return to landing page
                                      final signalR =
                                          Provider.of<SignalRService>(
                                            context,
                                            listen: false,
                                          );
                                      await signalR.stopConnection();

                                      if (context.mounted) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LandingPage(),
                                          ),
                                          (route) =>
                                              false, // Remove all previous routes
                                        );
                                      }
                                    } else {
                                      // Go back
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFE1F2D9),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 1,
                                          spreadRadius: 0,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          widget.source == 'landing'
                                              ? Icons.home
                                              : Icons.arrow_back,
                                          size: 24,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.source == 'landing'
                                              ? 'Home'
                                              : 'Back',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  // Helper methods to calculate scores from games
  Map<String, double> _calculateTeamScores(List<Game> games) {
    double team1Total = 0;
    double team2Total = 0;

    for (final game in games) {
      // Each match is worth 1 point total
      if (game.points1 >= 4) {
        // Team 1 (Würzburg) wins the match with 1 point
        team1Total += 1;
      } else if (game.points2 >= 4) {
        // Team 2 (Kitzingen) wins the match with 1 point
        team2Total += 1;
      } else if (game.points1 == 3 && game.points2 == 3) {
        // Both teams tie with 0.5 points each
        team1Total += 0.5;
        team2Total += 0.5;
      }
      // If neither team reaches 4 points and it's not a 3-3 tie, no points awarded
    }

    return {'Würzburg': team1Total, 'Kitzingen': team2Total};
  }

  Map<String, Map<String, dynamic>> _getGameTypeSummaries(List<Game> games) {
    final Map<String, Map<String, dynamic>> gameTypeSummaries = {};

    // Initialize summaries for each game type
    gameTypeSummaries['Chapman'] = {
      'Würzburg': 0,
      'Kitzingen': 0,
      'totalGames': 0,
    };
    gameTypeSummaries['Best Ball'] = {
      'Würzburg': 0,
      'Kitzingen': 0,
      'totalGames': 0,
    };
    gameTypeSummaries['Einzel'] = {
      'Würzburg': 0,
      'Kitzingen': 0,
      'totalGames': 0,
    };

    // Group games by type and calculate match points
    for (final game in games) {
      // Determine game type based on game name or other criteria
      String gameType = 'Chapman'; // Default

      if (game.name.toLowerCase().contains('best') ||
          game.name.toLowerCase().contains('ball')) {
        gameType = 'Best Ball';
      } else if (game.name.toLowerCase().contains('einzel')) {
        gameType = 'Einzel';
      } else if (game.name.toLowerCase().contains('chapman')) {
        gameType = 'Chapman';
      }

      if (gameTypeSummaries.containsKey(gameType)) {
        // Calculate match points for this game
        if (game.points1 >= 4) {
          // Würzburg wins the match
          gameTypeSummaries[gameType]!['Würzburg'] =
              (gameTypeSummaries[gameType]!['Würzburg'] ?? 0) + 1;
        } else if (game.points2 >= 4) {
          // Kitzingen wins the match
          gameTypeSummaries[gameType]!['Kitzingen'] =
              (gameTypeSummaries[gameType]!['Kitzingen'] ?? 0) + 1;
        } else if (game.points1 == 3 && game.points2 == 3) {
          // Both teams tie
          gameTypeSummaries[gameType]!['Würzburg'] =
              (gameTypeSummaries[gameType]!['Würzburg'] ?? 0) + 0.5;
          gameTypeSummaries[gameType]!['Kitzingen'] =
              (gameTypeSummaries[gameType]!['Kitzingen'] ?? 0) + 0.5;
        }

        gameTypeSummaries[gameType]!['totalGames'] =
            (gameTypeSummaries[gameType]!['totalGames'] ?? 0) + 1;
      }
    }

    return gameTypeSummaries;
  }

  // Helper function to format scores - shows whole numbers without decimals
  String _formatScore(double score) {
    if (score.round() == score) {
      return score.round().toString();
    } else {
      return score.toStringAsFixed(1);
    }
  }
}
