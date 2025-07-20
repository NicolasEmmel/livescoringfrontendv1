import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flight_score_provider.dart';
import 'landingpage.dart';
import 'services/signalr_service.dart';

class ScoresSummaryPage extends StatelessWidget {
  const ScoresSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scoreProvider = Provider.of<FlightScoreProvider>(context);
    final players = scoreProvider.players;
    final holes = scoreProvider.holes;

    return Scaffold(
      body: Container(
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.score, size: 32, color: Color(0xFF2E7D32)),
                      SizedBox(width: 12),
                      Text(
                        'ZUSAMMENFASSUNG',
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
              // Scores table
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Table header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1F2D9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Hole number header
                            Expanded(
                              flex: 1,
                              child: Text(
                                'LOCH',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Player headers
                            ...List.generate(players.length, (index) {
                              final nameParts = players[index].name.split(' ');
                              return Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      nameParts[0],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2E7D32),
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (nameParts.length > 1)
                                      Text(
                                        nameParts.sublist(1).join(' '),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E7D32),
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Holes rows
                      Expanded(
                        child: ListView.builder(
                          itemCount: holes.length,
                          itemBuilder: (context, holeIndex) {
                            final hole = holes[holeIndex];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(25, 255, 255, 255),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 1,
                                    spreadRadius: 0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Hole number and info
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${hole.number}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Par ${hole.par}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Player scores for this hole
                                  ...List.generate(players.length, (
                                    playerIndex,
                                  ) {
                                    final player = players[playerIndex];
                                    final score =
                                        scoreProvider.getScore(
                                          player.id,
                                          holeIndex.toString(),
                                        ) ??
                                        0;
                                    final relativeToPar = score - hole.par;

                                    Color scoreColor = Colors.black;
                                    if (relativeToPar > 0) {
                                      scoreColor = Colors.red.shade700;
                                    } else if (relativeToPar < 0) {
                                      scoreColor = Colors.green.shade700;
                                    }

                                    return Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: score == 0
                                              ? Colors.grey.shade200
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          score == 0 ? '-' : '$score',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: scoreColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Player totals row
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1F2D9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2E7D32),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Spacer to align with hole numbers column
                            Expanded(flex: 1, child: Container()),
                            // Player totals
                            ...List.generate(players.length, (playerIndex) {
                              final player = players[playerIndex];
                              final totalScore = scoreProvider.getTotalScore(
                                player.id,
                              );
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF2E7D32),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    '$totalScore',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom navigation
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back to Scoring button
                    Container(
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
                      child: GestureDetector(
                        onTap: () {
                          // Navigate back to scoring page (will return to last hole)
                          Navigator.pop(context);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.edit,
                              size: 24,
                              color: Colors.black,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Bearbeiten',
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
                    Container(
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
                      child: GestureDetector(
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
                              (route) => false, // Remove all previous routes
                            );
                          }
                        },
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
        ),
      ),
    );
  }
}
