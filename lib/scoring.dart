import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../providers/flight_score_provider.dart';
import 'models/hole.dart';
import 'services/signalr_service.dart';
import 'leaderboard.dart';

class ScoreManagementPage extends StatefulWidget {
  const ScoreManagementPage({super.key});

  @override
  State<ScoreManagementPage> createState() => _ScoreManagementPageState();
}

class _ScoreManagementPageState extends State<ScoreManagementPage> {
  final int totalHoles = 18;
  int currentHoleIndex = 0;

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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final players = Provider.of<FlightScoreProvider>(context).players;
    final holes = Provider.of<FlightScoreProvider>(context).holes;

    if (holes.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF959F96), Color(0xFFE5E5E5), Color(0xFFE5E5E5)],
            stops: [0.0, 0.7, 1.0],
            radius: 0.8,
          ),
        ),
        child: PageView.builder(
          itemCount: totalHoles,
          controller: PageController(initialPage: currentHoleIndex),
          onPageChanged: (index) async {
            await sendScoresToBackend(context, currentHoleIndex);
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
                              color: Colors.black26,
                              blurRadius: 0.5,
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
                              child: Text(
                                'Hole ${hole.number}',
                                style: const TextStyle(fontSize: 16),
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
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    80,
                                    255,
                                    255,
                                    255,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 1,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          nameParts[0],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (nameParts.length > 1)
                                          Text(
                                            nameParts.sublist(1).join(' '),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () =>
                                            updateScore(context, player.id, -1),
                                      ),
                                      Text(
                                        '$score',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () =>
                                            updateScore(context, player.id, 1),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.leaderboard),
                      label: const Text("Go to Leaderboard"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaderboardPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
