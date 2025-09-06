import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'leaderboard.dart';
import 'landingpage.dart';
import 'scores_summary_page.dart';
import 'models/mulligan_cup_flight.dart';
import 'models/mulligan_hole_score.dart';
import 'models/mulligan_cup_game.dart';
import 'models/mulligan_player_score.dart';
import 'providers/mulligan_cup_provider.dart';
import 'services/signalr_service.dart';
import 'wheel_of_fortune_page.dart';

class ScoreManagementPage extends StatefulWidget {
  final int initialHole;
  final MulliganCupFlight? flight;

  const ScoreManagementPage({super.key, this.initialHole = 0, this.flight});

  @override
  State<ScoreManagementPage> createState() => _ScoreManagementPageState();
}

class _ScoreManagementPageState extends State<ScoreManagementPage> {
  final int totalHoles = 18;
  late int currentHoleIndex;
  PageController? _pageController;

  // State for UI elements - now managed by MulliganCupProvider

  // Get players from game data or flight
  List<Map<String, dynamic>> _getPlayers(BuildContext context) {
    final mulliganCupProvider = Provider.of<MulliganCupProvider>(
      context,
      listen: false,
    );

    // First try to get players from current game data
    if (mulliganCupProvider.currentGame != null &&
        mulliganCupProvider.currentGame!.players.isNotEmpty) {
      return mulliganCupProvider.currentGame!.players.map((player) {
        return {
          'id': '${player.id}',
          'name': player.name,
          'handicap': player.handicap,
          'gender': player.gender,
        };
      }).toList();
    }

    // Fallback to flight data
    if (widget.flight != null && widget.flight!.players.isNotEmpty) {
      return widget.flight!.players.asMap().entries.map((entry) {
        return {'id': '${entry.key + 1}', 'name': entry.value};
      }).toList();
    }

    // Return empty list if no data available
    return [];
  }

  final List<Map<String, dynamic>> _dummyHoles = [
    {'number': 1, 'length': 350, 'par': 4, 'strokeIndex': 8},
    {'number': 2, 'length': 420, 'par': 4, 'strokeIndex': 4},
    {'number': 3, 'length': 180, 'par': 3, 'strokeIndex': 16},
    {'number': 4, 'length': 520, 'par': 5, 'strokeIndex': 2},
    {'number': 5, 'length': 380, 'par': 4, 'strokeIndex': 6},
    {'number': 6, 'length': 160, 'par': 3, 'strokeIndex': 18},
    {'number': 7, 'length': 450, 'par': 4, 'strokeIndex': 3},
    {'number': 8, 'length': 200, 'par': 3, 'strokeIndex': 14},
    {'number': 9, 'length': 480, 'par': 5, 'strokeIndex': 1},
    {'number': 10, 'length': 320, 'par': 4, 'strokeIndex': 12},
    {'number': 11, 'length': 140, 'par': 3, 'strokeIndex': 17},
    {'number': 12, 'length': 400, 'par': 4, 'strokeIndex': 7},
    {'number': 13, 'length': 550, 'par': 5, 'strokeIndex': 1},
    {'number': 14, 'length': 360, 'par': 4, 'strokeIndex': 9},
    {'number': 15, 'length': 170, 'par': 3, 'strokeIndex': 15},
    {'number': 16, 'length': 430, 'par': 4, 'strokeIndex': 5},
    {'number': 17, 'length': 190, 'par': 3, 'strokeIndex': 13},
    {'number': 18, 'length': 500, 'par': 5, 'strokeIndex': 2},
  ];

  @override
  void initState() {
    super.initState();
    currentHoleIndex = widget.initialHole;
    _pageController = PageController(initialPage: currentHoleIndex);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  bool _getLadyCheckbox(String playerId, int holeIndex) {
    final mulliganCupProvider = Provider.of<MulliganCupProvider>(
      context,
      listen: false,
    );

    // First check if user has set this value
    if (mulliganCupProvider.ladyCheckboxes.containsKey(
      '${playerId}_$holeIndex',
    )) {
      return mulliganCupProvider.getLadyCheckbox(playerId, holeIndex);
    }

    // Fallback to game data if available
    if (mulliganCupProvider.currentGame != null) {
      final player = mulliganCupProvider.currentGame!.players.firstWhere(
        (p) => p.id.toString() == playerId,
        orElse: () => MulliganPlayerScore(
          id: 0,
          name: '',
          handicap: 0.0,
          gender: '',
          drunkBackClubs: 0,
          scores: [],
        ),
      );

      final holeScore = player.scores.firstWhere(
        (s) => s.holeNumber == holeIndex + 1,
        orElse: () => MulliganHoleScore(
          holeNumber: holeIndex + 1,
          strokes: 0,
          mulligan: false,
          putts: 0,
          lady: false,
        ),
      );

      return holeScore.lady;
    }

    return false;
  }

  void _setLadyCheckbox(String playerId, int holeIndex, bool value) {
    final mulliganCupProvider = Provider.of<MulliganCupProvider>(
      context,
      listen: false,
    );
    mulliganCupProvider.setLadyCheckbox(playerId, holeIndex, value);
  }

  bool _getMulliganCheckbox(String playerId, int holeIndex) {
    final mulliganCupProvider = Provider.of<MulliganCupProvider>(
      context,
      listen: false,
    );

    // First check if user has set this value
    if (mulliganCupProvider.mulliganCheckboxes.containsKey(
      '${playerId}_$holeIndex',
    )) {
      return mulliganCupProvider.getMulliganCheckbox(playerId, holeIndex);
    }

    // Fallback to game data if available
    if (mulliganCupProvider.currentGame != null) {
      final player = mulliganCupProvider.currentGame!.players.firstWhere(
        (p) => p.id.toString() == playerId,
        orElse: () => MulliganPlayerScore(
          id: 0,
          name: '',
          handicap: 0.0,
          gender: '',
          drunkBackClubs: 0,
          scores: [],
        ),
      );

      final holeScore = player.scores.firstWhere(
        (s) => s.holeNumber == holeIndex + 1,
        orElse: () => MulliganHoleScore(
          holeNumber: holeIndex + 1,
          strokes: 0,
          mulligan: false,
          putts: 0,
          lady: false,
        ),
      );

      return holeScore.mulligan;
    }

    return false;
  }

  void _setMulliganCheckbox(String playerId, int holeIndex, bool value) {
    final mulliganCupProvider = Provider.of<MulliganCupProvider>(
      context,
      listen: false,
    );
    mulliganCupProvider.setMulliganCheckbox(playerId, holeIndex, value);
  }

  int _getPuttsCounter(String playerId, int holeIndex) {
    final mulliganCupProvider = Provider.of<MulliganCupProvider>(
      context,
      listen: false,
    );

    // First check if user has set this value
    if (mulliganCupProvider.puttsCounters.containsKey(
      '${playerId}_$holeIndex',
    )) {
      return mulliganCupProvider.getPuttsCounter(playerId, holeIndex);
    }

    // Fallback to game data if available
    if (mulliganCupProvider.currentGame != null) {
      final player = mulliganCupProvider.currentGame!.players.firstWhere(
        (p) => p.id.toString() == playerId,
        orElse: () => MulliganPlayerScore(
          id: 0,
          name: '',
          handicap: 0.0,
          gender: '',
          drunkBackClubs: 0,
          scores: [],
        ),
      );

      final holeScore = player.scores.firstWhere(
        (s) => s.holeNumber == holeIndex + 1,
        orElse: () => MulliganHoleScore(
          holeNumber: holeIndex + 1,
          strokes: 0,
          mulligan: false,
          putts: 0,
          lady: false,
        ),
      );

      return holeScore.putts;
    }

    return 0;
  }

  void _setPuttsCounter(String playerId, int holeIndex, int value) {
    final mulliganCupProvider = Provider.of<MulliganCupProvider>(
      context,
      listen: false,
    );
    mulliganCupProvider.setPuttsCounter(playerId, holeIndex, value);
  }

  void _incrementScore(String playerId, int holeIndex) {
    final currentScore = _getScore(playerId, holeIndex, context);
    final mulliganCupProvider = Provider.of<MulliganCupProvider>(
      context,
      listen: false,
    );
    mulliganCupProvider.setScore(playerId, holeIndex, currentScore + 1);
  }

  void _decrementScore(String playerId, int holeIndex) {
    final currentScore = _getScore(playerId, holeIndex, context);
    if (currentScore > 1) {
      final mulliganCupProvider = Provider.of<MulliganCupProvider>(
        context,
        listen: false,
      );
      mulliganCupProvider.setScore(playerId, holeIndex, currentScore - 1);
    }
  }

  Future<void> _sendScoresToBackend(BuildContext context) async {
    try {
      final signalR = Provider.of<SignalRService>(context, listen: false);
      final mulliganCupProvider = Provider.of<MulliganCupProvider>(
        context,
        listen: false,
      );

      // Get current game or create a new one
      MulliganCupGame? currentGame = mulliganCupProvider.currentGame;

      if (currentGame == null) {
        // Create a basic game object if none exists
        currentGame = MulliganCupGame(
          id: widget.flight?.id ?? 0,
          players: _getPlayers(context).map((player) {
            final playerId = player['id'];
            final playerName = player['name'];

            // Include all scores from the current game data
            List<MulliganHoleScore> playedScores = [];
            for (int holeIndex = 0; holeIndex < totalHoles; holeIndex++) {
              // Get the score data (prioritizes user input, falls back to game data)
              final score = _getScore(playerId, holeIndex, context);
              final putts = _getPuttsCounter(playerId, holeIndex);
              final mulligan = _getMulliganCheckbox(playerId, holeIndex);
              final lady = _getLadyCheckbox(playerId, holeIndex);

              // Only include holes that have been played (score > 0 or any other data)
              if (score > 0 || putts > 0 || mulligan || lady) {
                playedScores.add(
                  MulliganHoleScore(
                    holeNumber: holeIndex + 1,
                    strokes: score,
                    mulligan: mulligan,
                    putts: putts,
                    lady: lady,
                  ),
                );
              }
            }

            return MulliganPlayerScore(
              id: int.parse(playerId),
              name: playerName,
              handicap: 0.0,
              gender: '',
              drunkBackClubs: 0,
              scores: playedScores,
            );
          }).toList(),
        );
      } else {
        // Update existing game with current scores
        final updatedPlayers = currentGame.players.map((player) {
          final playerId = player.id.toString();

          // Include all scores from the current game data
          List<MulliganHoleScore> playedScores = [];
          for (int holeIndex = 0; holeIndex < totalHoles; holeIndex++) {
            // Get the score data (prioritizes user input, falls back to game data)
            final score = _getScore(playerId, holeIndex, context);
            final putts = _getPuttsCounter(playerId, holeIndex);
            final mulligan = _getMulliganCheckbox(playerId, holeIndex);
            final lady = _getLadyCheckbox(playerId, holeIndex);

            // Only include holes that have been played (score > 0 or any other data)
            if (score > 0 || putts > 0 || mulligan || lady) {
              playedScores.add(
                MulliganHoleScore(
                  holeNumber: holeIndex + 1,
                  strokes: score,
                  mulligan: mulligan,
                  putts: putts,
                  lady: lady,
                ),
              );
            }
          }

          return MulliganPlayerScore(
            id: player.id,
            name: player.name,
            handicap: player.handicap,
            gender: player.gender,
            drunkBackClubs: player.drunkBackClubs,
            scores: playedScores,
          );
        }).toList();

        currentGame = MulliganCupGame(
          id: currentGame.id,
          players: updatedPlayers,
        );
      }

      // Send to backend
      print('📤 Sending game update to backend...');
      print('📤 Game data: ${currentGame.toJson()}');
      await signalR.sendMulliganCupGameUpdate(currentGame.toJson());
      print('📤 Game update sent successfully');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scores sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error sending scores: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending scores: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getScore(String playerId, int holeIndex, BuildContext context) {
    final mulliganCupProvider = Provider.of<MulliganCupProvider>(
      context,
      listen: false,
    );

    // First check if user has manually set a score
    final userScore = mulliganCupProvider.getScore(playerId, holeIndex);
    if (userScore > 0) {
      return userScore;
    }

    // Try to get real score from game data
    if (mulliganCupProvider.currentGame != null) {
      final player = mulliganCupProvider.currentGame!.players.firstWhere(
        (p) => p.id.toString() == playerId,
        orElse: () => mulliganCupProvider.currentGame!.players.first,
      );

      final holeScore = player.scores.firstWhere(
        (s) => s.holeNumber == holeIndex + 1, // Convert 0-based to 1-based
        orElse: () => MulliganHoleScore(
          holeNumber: holeIndex + 1,
          strokes: 0,
          mulligan: false,
          putts: 0,
          lady: false,
        ),
      );

      return holeScore.strokes;
    }

    // Return default score if no data available
    return 0;
  }

  void _showFinalConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 32),
              SizedBox(width: 12),
              Text(
                'Round Complete!',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Alle Scores wurden erfolgreich gesendet. Möchtest du die vollständige Scoreübersicht ansehen?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate to scores summary page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScoresSummaryPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('View Summary'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<MulliganCupProvider>(
      builder: (context, mulliganCupProvider, child) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF959F96),
                      Color(0xFFE5E5E5),
                      Color(0xFFE5E5E5),
                    ],
                    stops: [0.0, 0.7, 1.0],
                    radius: 0.8,
                  ),
                ),
                child: PageView.builder(
                  itemCount: totalHoles,
                  controller: _pageController!,
                  onPageChanged: (index) {
                    setState(() => currentHoleIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final hole = _dummyHoles[index];

                    return SafeArea(
                      child: Column(
                        children: [
                          SizedBox(
                            height: screenHeight / 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
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
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              const Text(
                                                'Loch ',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Text(
                                                '${hole['number']}',
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (index == totalHoles - 1)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2E7D32),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'FINALES LOCH',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: Text('${hole['length']} m'),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Text(
                                        'Par ${hole['par']} | SI ${hole['strokeIndex']}',
                                      ),
                                    ),
                                    const Center(
                                      child: Icon(Icons.golf_course, size: 64),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _getPlayers(context).map((player) {
                                    final score = _getScore(
                                      player['id'],
                                      currentHoleIndex,
                                      context,
                                    );
                                    final nameParts = player['name'].split(' ');

                                    return Container(
                                      height:
                                          180, // Increased height to prevent overflow
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            25,
                                            255,
                                            255,
                                            255,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 2,
                                              spreadRadius: 1,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Player name and score row
                                                Row(
                                                  children: [
                                                    // Player name - left aligned
                                                    Expanded(
                                                      flex:
                                                          4, // Increased flex for better proportion
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            nameParts[0],
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          if (nameParts.length >
                                                              1)
                                                            Text(
                                                              nameParts
                                                                  .sublist(1)
                                                                  .join(' '),
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Score controls - right aligned
                                                    Expanded(
                                                      flex:
                                                          3, // Increased flex for better proportion
                                                      child: Column(
                                                        children: [
                                                          // Schläge label
                                                          const Text(
                                                            'Schläge',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          // Score counter
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              IconButton(
                                                                icon: const Icon(
                                                                  Icons.remove,
                                                                  size: 24,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                onPressed: () {
                                                                  _decrementScore(
                                                                    player['id']
                                                                        .toString(),
                                                                    currentHoleIndex,
                                                                  );
                                                                },
                                                              ),
                                                              Text(
                                                                '$score',
                                                                style: const TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: const Icon(
                                                                  Icons.add,
                                                                  size: 24,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                onPressed: () {
                                                                  _incrementScore(
                                                                    player['id']
                                                                        .toString(),
                                                                    currentHoleIndex,
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // Additional controls row
                                                Row(
                                                  children: [
                                                    // Lady checkbox
                                                    Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Checkbox(
                                                            value: _getLadyCheckbox(
                                                              player['id'],
                                                              currentHoleIndex,
                                                            ),
                                                            onChanged: (value) {
                                                              _setLadyCheckbox(
                                                                player['id'],
                                                                currentHoleIndex,
                                                                value ?? false,
                                                              );
                                                            },
                                                            activeColor:
                                                                const Color(
                                                                  0xFF2E7D32,
                                                                ),
                                                            materialTapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                          ),
                                                          const Flexible(
                                                            child: Text(
                                                              'Lady',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Mulligan checkbox
                                                    Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Checkbox(
                                                            value: _getMulliganCheckbox(
                                                              player['id'],
                                                              currentHoleIndex,
                                                            ),
                                                            onChanged: (value) {
                                                              _setMulliganCheckbox(
                                                                player['id'],
                                                                currentHoleIndex,
                                                                value ?? false,
                                                              );
                                                            },
                                                            activeColor:
                                                                const Color(
                                                                  0xFF2E7D32,
                                                                ),
                                                            materialTapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                          ),
                                                          const Flexible(
                                                            child: Text(
                                                              'Mulligan',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Putts counter
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                            'Putts',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              IconButton(
                                                                icon: const Icon(
                                                                  Icons.remove,
                                                                  size: 24,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                onPressed: () {
                                                                  final currentPutts =
                                                                      _getPuttsCounter(
                                                                        player['id'],
                                                                        currentHoleIndex,
                                                                      );
                                                                  _setPuttsCounter(
                                                                    player['id'],
                                                                    currentHoleIndex,
                                                                    currentPutts -
                                                                        1,
                                                                  );
                                                                },
                                                              ),
                                                              Text(
                                                                '${_getPuttsCounter(player['id'], currentHoleIndex)}',
                                                                style: const TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: const Icon(
                                                                  Icons.add,
                                                                  size: 24,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                onPressed: () {
                                                                  final currentPutts =
                                                                      _getPuttsCounter(
                                                                        player['id'],
                                                                        currentHoleIndex,
                                                                      );
                                                                  _setPuttsCounter(
                                                                    player['id'],
                                                                    currentHoleIndex,
                                                                    currentPutts +
                                                                        1,
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
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
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Send scores button
                                GestureDetector(
                                  onTap: () async {
                                    // Send current scores to backend
                                    await _sendScoresToBackend(context);

                                    // Show confirmation dialog for last hole
                                    if (currentHoleIndex == totalHoles - 1) {
                                      _showFinalConfirmationDialog(context);
                                    } else {
                                      // Go to next hole
                                      _pageController?.nextPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 70,
                                    height: 70,
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
                                        const Icon(
                                          Icons.send,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Send',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Randomizer button
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WheelOfFortunePage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 70,
                                    height: 70,
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
                                        const Icon(
                                          Icons.casino,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Random',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Leaderboard button
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LeaderboardPage(
                                          source: 'scoring',
                                          currentHole: currentHoleIndex,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 70,
                                    height: 70,
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
                                        const Icon(
                                          Icons.leaderboard,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Board',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Home button
                                GestureDetector(
                                  onTap: () {
                                    // Navigate back to landing page and clear the stack
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LandingPage(),
                                      ),
                                      (route) =>
                                          false, // Remove all previous routes
                                    );
                                  },
                                  child: Container(
                                    width: 70,
                                    height: 70,
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
                                        const Icon(
                                          Icons.home,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Home',
                                          style: TextStyle(
                                            fontSize: 9,
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
            ],
          ),
        );
      },
    );
  }
}
