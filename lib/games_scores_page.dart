import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'game_scoring_page.dart';

class GamesScoresPage extends StatefulWidget {
  const GamesScoresPage({super.key});

  @override
  State<GamesScoresPage> createState() => _GamesScoresPageState();
}

class _GamesScoresPageState extends State<GamesScoresPage> {
  String _selectedGameType = '';

  List<String> get _gameTypes {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final types = <String>{};

    for (final game in gameProvider.games) {
      if (game.name.toLowerCase().contains('chapman')) {
        types.add('Chapman');
      } else if (game.name.toLowerCase().contains('best') ||
          game.name.toLowerCase().contains('ball')) {
        types.add('Best Ball');
      } else if (game.name.toLowerCase().contains('einzel')) {
        types.add('Einzel');
      }
    }

    final sortedTypes = types.toList()..sort();

    // Set default selection to first available type if none selected
    if (_selectedGameType.isEmpty && sortedTypes.isNotEmpty) {
      _selectedGameType = sortedTypes.first;
    }

    return sortedTypes;
  }

  List<dynamic> get _filteredGames {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    if (_selectedGameType.isEmpty) {
      return <dynamic>[];
    }

    return gameProvider.games.where((game) {
      final name = game.name.toLowerCase();
      switch (_selectedGameType) {
        case 'Chapman':
          return name.contains('chapman');
        case 'Best Ball':
          return name.contains('best') || name.contains('ball');
        case 'Einzel':
          return name.contains('einzel');
        default:
          return false;
      }
    }).toList();
  }

  // Helper method to determine game card color based on match result
  Color _getGameCardColor(dynamic game) {
    // Check if match is over (one team has 4+ points or both have 3 points)
    if (game.points1 >= 4) {
      // Würzburg won - use green color
      return const Color(0xFF4CAF50); // Green
    } else if (game.points2 >= 4) {
      // Kitzingen won - use red color
      return const Color(0xFFF44336); // Red
    } else if (game.points1 == 3 && game.points2 == 3) {
      // Tie - use yellow color
      return const Color(0xFFFFEB3B); // Yellow
    } else {
      // Match not over yet - use default light green
      return const Color(0xFFE1F2D9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF959F96), Color(0xFFE5E5E5), Color(0xFFE5E5E5)],
            stops: [0.0, 0.7, 1.0],
            radius: 0.8,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: Row(
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2E7D32),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Title - Expanded to fill remaining space
                        Expanded(
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.scoreboard,
                                size: 32,
                                color: Color(0xFF2E7D32),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'GAME SCORES',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Filter Buttons
                Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    if (gameProvider.games.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final gameTypes = _gameTypes;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: gameTypes.map((gameType) {
                            final isSelected = _selectedGameType == gameType;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGameType = gameType;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFE1F2D9),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: const Color(0xFF2E7D32),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    gameType,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Games Grid with Scores
                Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    if (gameProvider.games.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No games available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    final filteredGames = _filteredGames;

                    if (filteredGames.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No games found for selected type',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: filteredGames.map((game) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 64) / 2,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GameScoringPage(game: game),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getGameCardColor(game),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Player names
                                    ...game.playerNames.map(
                                      (playerName) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Text(
                                          playerName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Score display
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Würzburg score
                                        Column(
                                          children: [
                                            Text(
                                              'Würzburg',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${game.points1}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Kitzingen score
                                        Column(
                                          children: [
                                            Text(
                                              'Kitzingen',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${game.points2}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
