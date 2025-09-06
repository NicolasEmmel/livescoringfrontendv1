import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mulligan_cup_provider.dart';
import 'models/mle.dart';

class FlightLeaderboardPage extends StatefulWidget {
  const FlightLeaderboardPage({super.key});

  @override
  State<FlightLeaderboardPage> createState() => _FlightLeaderboardPageState();
}

class _FlightLeaderboardPageState extends State<FlightLeaderboardPage> {
  // No filter needed - only one column for added score

  @override
  Widget build(BuildContext context) {
    final mulliganCupProvider = Provider.of<MulliganCupProvider>(context);
    final leaderboard = mulliganCupProvider.leaderboard;
    final flights = mulliganCupProvider.flights;

    // Calculate flight statistics
    final flightStats = _calculateFlightStats(
      leaderboard?.entries ?? [],
      flights,
    );

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
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Flight Leaderboard',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Flight leaderboard content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: flightStats.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flight,
                                size: 48,
                                color: Colors.black26,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Keine Flight-Daten verfügbar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Flights werden nach dem Start angezeigt',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            // Header row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Flight header
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'FLIGHT',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  // Players count header
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'PLAYERS',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  // Added score header
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'ADDED SCORE',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Flight entries
                            Expanded(
                              child: ListView.builder(
                                itemCount: flightStats.length,
                                itemBuilder: (context, index) {
                                  final flightStat = flightStats[index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Flight name
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Flight ${flightStat['flightNumber']}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              if (flightStat['players']
                                                  .isNotEmpty)
                                                Text(
                                                  flightStat['players'].join(
                                                    ', ',
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        // Players count
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${flightStat['playerCount']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        // Added Score
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '${flightStat['addedScore']}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: _getAddedScoreColor(
                                                flightStat['addedScore'] as int,
                                              ),
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateFlightStats(
    List<MLE> entries,
    List<dynamic> flights,
  ) {
    if (flights.isEmpty) return [];

    List<Map<String, dynamic>> flightStats = [];

    for (int i = 0; i < flights.length; i++) {
      final flight = flights[i];
      final flightPlayers = flight.players as List<String>;

      // Get entries for this flight
      final flightEntries = entries.where((entry) {
        return flightPlayers.any((player) {
          return entry.name.toLowerCase().contains(player.toLowerCase());
        });
      }).toList();

      if (flightEntries.isNotEmpty) {
        // Calculate highest scores
        final highestBrutto = flightEntries
            .map((e) => e.brutto)
            .reduce((a, b) => a > b ? a : b);
        final highestNetto = flightEntries
            .map((e) => e.netto)
            .reduce((a, b) => a > b ? a : b);

        // Calculate added score (highest brutto + highest netto)
        final addedScore = highestBrutto + highestNetto;

        flightStats.add({
          'flightNumber': i + 1,
          'players': flightPlayers,
          'playerCount': flightEntries.length,
          'brutto': highestBrutto,
          'netto': highestNetto,
          'addedScore': addedScore,
        });
      }
    }

    // Sort by added score (descending - highest first)
    flightStats.sort((a, b) {
      return (b['addedScore'] as int).compareTo(a['addedScore'] as int);
    });

    return flightStats;
  }

  Color _getAddedScoreColor(int addedScore) {
    // Higher added scores are better
    if (addedScore >= 100) return Colors.green;
    if (addedScore >= 70) return Colors.orange;
    return Colors.black87;
  }
}
