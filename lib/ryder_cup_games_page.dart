import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'game_scoring_page.dart';
import 'services/signalr_service.dart';
import 'landingpage.dart';

class RyderCupGamesPage extends StatefulWidget {
  const RyderCupGamesPage({super.key});

  @override
  State<RyderCupGamesPage> createState() => _RyderCupGamesPageState();
}

class _RyderCupGamesPageState extends State<RyderCupGamesPage> {
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

                // Games Grid
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
                                color: const Color(0xFFE1F2D9),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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

                // Back to Landing Page Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        // Disconnect from SignalR and return to landing page
                        final signalR = Provider.of<SignalRService>(
                          context,
                          listen: false,
                        );
                        await signalR.stopConnection();

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LandingPage(),
                            ),
                            (route) => false, // Remove all previous routes
                          );
                        }
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home, size: 24, color: Colors.white),
                            SizedBox(height: 4),
                            Text(
                              'Home',
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
                  ),
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
