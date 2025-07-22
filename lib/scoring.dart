import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../providers/flight_score_provider.dart';
import 'models/hole.dart';
import 'services/signalr_service.dart';
import 'leaderboard.dart';
import 'landingpage.dart';
import 'scores_summary_page.dart';

class ScoreManagementPage extends StatefulWidget {
  final int initialHole;

  const ScoreManagementPage({super.key, this.initialHole = 0});

  @override
  State<ScoreManagementPage> createState() => _ScoreManagementPageState();
}

class _ScoreManagementPageState extends State<ScoreManagementPage> {
  final int totalHoles = 18;
  late int currentHoleIndex;
  PageController? _pageController;
  bool _showSuccessMessage = false;

  void updateScore(BuildContext context, String playerId, int delta) {
    final scoreProvider = Provider.of<FlightScoreProvider>(
      context,
      listen: false,
    );
    final oldScore =
        scoreProvider.getScore(playerId, currentHoleIndex.toString()) ?? 0;
    final newScore = (oldScore + delta).clamp(1, 12);

    scoreProvider.updateScore(
      playerId: playerId,
      holeId: currentHoleIndex.toString(),
      score: newScore,
    );
  }

  Future<void> sendScoresToBackend(BuildContext context, int holeIndex) async {
    final scoreProvider = Provider.of<FlightScoreProvider>(
      context,
      listen: false,
    );

    final Map<String, Map<String, int>> scoreData = {};

    for (final player in scoreProvider.players) {
      final String playerId = player.id;
      final Map<String, int>? playerScores = scoreProvider.getPlayerScores(
        playerId,
      );

      if (playerScores != null) {
        for (final entry in playerScores.entries) {
          final int rawScore = entry.value;

          final int scoreRelativeToPar =
              rawScore - scoreProvider.holes[int.parse(entry.key)].par;

          scoreData.putIfAbsent(playerId, () => {});
          scoreData[playerId]![entry.key] = scoreRelativeToPar;
        }
      }
    }

    // Replace with your real tournamentId
    final String tournamentId = scoreProvider.tournamentId;

    // Send to SignalR hub method "SendScoreUpdate"

    final signalR = Provider.of<SignalRService>(context, listen: false);

    if (signalR.isConnected) {
      signalR.sendScoreUpdate([scoreData, tournamentId]).catchError((e) {
        print("Failed to send score update: $e");
      });
    } else {
      print('Not connected');
    }
  }

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

  bool _areAllHolesScored() {
    final scoreProvider = Provider.of<FlightScoreProvider>(
      context,
      listen: false,
    );

    for (final player in scoreProvider.players) {
      for (int i = 0; i < totalHoles; i++) {
        final score = scoreProvider.getScore(player.id, i.toString());
        if (score == null || score == 0) {
          return false;
        }
      }
    }
    return true;
  }

  void _showFinalConfirmationDialog(BuildContext context) {
    final allScored = _areAllHolesScored();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                allScored ? Icons.check_circle : Icons.warning,
                color: allScored ? const Color(0xFF2E7D32) : Colors.orange,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                allScored ? 'Round Complete!' : 'Round Finished',
                style: TextStyle(
                  color: allScored ? const Color(0xFF2E7D32) : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            allScored
                ? 'All scores have been submitted successfully. Would you like to view the complete scores summary?'
                : 'Some holes may not have scores recorded. Would you like to view the current scores summary anyway?',
            style: const TextStyle(fontSize: 16),
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
    final players = Provider.of<FlightScoreProvider>(context).players;
    final holes = Provider.of<FlightScoreProvider>(context).holes;

    // Initialize controller if null
    if (_pageController == null) {
      _pageController = PageController(initialPage: currentHoleIndex);
    }

    if (holes.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                final hole = holes[index];

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
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          const Text(
                                            'Loch ',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            '${hole.number}',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (index == totalHoles - 1)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2E7D32),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Text(
                                            'FINAL HOLE',
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
                                  child: Text('${hole.length} m'),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Text(
                                    'Par ${hole.par} | SI ${hole.strokeIndex}',
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
                          child: Column(
                            children: players.map((player) {
                              final score =
                                  Provider.of<FlightScoreProvider>(
                                    context,
                                  ).getScore(
                                    player.id,
                                    currentHoleIndex.toString(),
                                  ) ??
                                  0;
                              final nameParts = player.name.split(' ');

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        25,
                                        255,
                                        255,
                                        255,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
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
                                      child: Row(
                                        children: [
                                          // Player name - left aligned with proper spacing
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 16,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    nameParts[0],
                                                    style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (nameParts.length > 1)
                                                    Text(
                                                      nameParts
                                                          .sublist(1)
                                                          .join(' '),
                                                      style: const TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.black,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Score controls - right aligned
                                          Expanded(
                                            flex: 3,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    size: 40,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () => updateScore(
                                                    context,
                                                    player.id,
                                                    -1,
                                                  ),
                                                ),
                                                Text(
                                                  '$score',
                                                  style: const TextStyle(
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 40,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () => updateScore(
                                                    context,
                                                    player.id,
                                                    1,
                                                  ),
                                                ),
                                              ],
                                            ),
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
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Send scores button
                            GestureDetector(
                              onTap: () async {
                                await sendScoresToBackend(
                                  context,
                                  currentHoleIndex,
                                );
                                setState(() {
                                  _showSuccessMessage = true;
                                });

                                // Hide message after 1 second and handle navigation
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (mounted) {
                                    setState(() {
                                      _showSuccessMessage = false;
                                    });

                                    // Check if this is the last hole
                                    if (currentHoleIndex == totalHoles - 1) {
                                      // Show confirmation dialog for last hole
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
                                  }
                                });
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.send,
                                      size: 24,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Send',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.leaderboard,
                                      size: 24,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Board',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Home button
                            GestureDetector(
                              onTap: () async {
                                // Disconnect from SignalR if connected
                                final signalR = Provider.of<SignalRService>(
                                  context,
                                  listen: false,
                                );
                                await signalR.stopConnection();

                                // Navigate back to landing page and clear the stack
                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LandingPage(),
                                    ),
                                    (route) =>
                                        false, // Remove all previous routes
                                  );
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.home,
                                      size: 24,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Home',
                                      style: TextStyle(
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
          // Success message overlay
          if (_showSuccessMessage)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(230, 255, 255, 255),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF2E7D32),
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Scores Sent Successfully!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
