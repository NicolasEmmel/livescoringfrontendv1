import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flight_score_provider.dart';
import '../models/leaderboard.dart';
import 'services/signalr_service.dart';
import 'scoring.dart';
import 'landingpage.dart';

class LeaderboardPage extends StatelessWidget {
  final String? source; // 'landing' or 'scoring'
  final int? currentHole; // Current hole when coming from scoring page

  const LeaderboardPage({super.key, this.source, this.currentHole});

  @override
  Widget build(BuildContext context) {
    final leaderboard = Provider.of<FlightScoreProvider>(context).leaderboard;
    final signalR = Provider.of<SignalRService>(context);

    // Sort leaderboard entries by toPar score (best score first)
    final sortedEntries = leaderboard?.entries.toList() ?? [];
    sortedEntries.sort((a, b) => a.toPar.compareTo(b.toPar));

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
                            await signalR.startConnection(
                              'xxx',
                              flightId: 'xxx',
                            );
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
              : leaderboard == null
              ? const Center(
                  child: Text(
                    'No leaderboard data available.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                )
              : Column(
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
                    // Leaderboard entries
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Header row
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  // Position header
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'POS',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  // Name header
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Text(
                                        'PLAYER',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Thru header
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'THRU',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  // To Par header
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'TO PAR',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Entries list
                            Expanded(
                              child: ListView.builder(
                                itemCount: sortedEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = sortedEntries[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
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
                                          color: Colors.black26,
                                          blurRadius: 1,
                                          spreadRadius: 0,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Position
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        // Player name
                                        Expanded(
                                          flex: 3,
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
                                                  entry.name.split(' ').first,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (entry.name
                                                        .split(' ')
                                                        .length >
                                                    1)
                                                  Text(
                                                    entry.name
                                                        .split(' ')
                                                        .sublist(1)
                                                        .join(' '),
                                                    style: const TextStyle(
                                                      fontSize: 16,
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
                                        // Thru
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${entry.thru}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        // To Par
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            entry.toPar > 0
                                                ? '+${entry.toPar}'
                                                : '${entry.toPar}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: entry.toPar > 0
                                                  ? Colors.red.shade700
                                                  : entry.toPar < 0
                                                  ? Colors.green.shade700
                                                  : Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
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
                      ),
                    ),
                    // Bottom navigation
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
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
                          child: GestureDetector(
                            onTap: () async {
                              if (source == 'landing') {
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
                                    (route) =>
                                        false, // Remove all previous routes
                                  );
                                }
                              } else {
                                // Go back to scoring page with current hole
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScoreManagementPage(
                                      initialHole: currentHole ?? 0,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  source == 'landing'
                                      ? Icons.home
                                      : Icons.score,
                                  size: 24,
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  source == 'landing' ? 'Home' : 'Score',
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
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
