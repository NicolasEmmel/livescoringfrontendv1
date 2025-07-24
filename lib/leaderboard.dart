import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flight_score_provider.dart';
import '../models/leaderboard.dart';
import 'services/signalr_service.dart';
import 'scoring.dart';
import 'landingpage.dart';

class LeaderboardPage extends StatefulWidget {
  final String? source; // 'landing' or 'scoring'
  final int? currentHole; // Current hole when coming from scoring page

  const LeaderboardPage({super.key, this.source, this.currentHole});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String selectedTournament = 'Male'; // Default to Male tournament

  final List<String> tournaments = ['Male', 'Senior'];

  @override
  Widget build(BuildContext context) {
    final leaderboard = Provider.of<FlightScoreProvider>(context).leaderboard;
    final signalR = Provider.of<SignalRService>(context);

    // Filter and process leaderboard entries
    final filteredEntries = _getFilteredEntries(leaderboard?.entries ?? []);
    final hasMultipleDays = _hasMultipleDays(leaderboard?.entries ?? []);

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
                              'xxx', // Only pass tournamentId, no flightId for leaderboard view
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

                    // Tournament selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: tournaments.map((tournament) {
                          final isSelected = selectedTournament == tournament;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedTournament = tournament;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF2E7D32)
                                        : const Color.fromARGB(
                                            80,
                                            255,
                                            255,
                                            255,
                                          ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _getTournamentDisplayName(tournament),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const SizedBox(height: 16),

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
                                  // Today header
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'R ${_getCurrentDay()}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  // Total header
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'ALL',
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
                              child: filteredEntries.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Keine Daten für diese Auswahl verfügbar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredEntries.length,
                                      itemBuilder: (context, index) {
                                        final entry = filteredEntries[index];
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 16,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        entry.name
                                                            .split(' ')
                                                            .first,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Colors.black,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                                              // Today score
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  _getTodayScore(entry),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: _getScoreColor(
                                                      _getTodayScoreValue(
                                                        entry,
                                                      ),
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              // Total score
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  _getTotalScore(entry),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: _getScoreColor(
                                                      _getTotalScoreValue(
                                                        entry,
                                                      ),
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
                    // Bottom navigation
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            if (widget.source == 'landing') {
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
                                    initialHole: widget.currentHole ?? 0,
                                  ),
                                ),
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
                                Icon(
                                  widget.source == 'landing'
                                      ? Icons.home
                                      : Icons.score,
                                  size: 24,
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.source == 'landing' ? 'Home' : 'Score',
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

  // Helper methods
  String _getTournamentDisplayName(String tournament) {
    switch (tournament) {
      case 'Male':
        return 'Herren';
      case 'Senior':
        return 'Senior';
      default:
        return tournament;
    }
  }

  int _getCurrentDay() {
    final leaderboard = Provider.of<FlightScoreProvider>(
      context,
      listen: false,
    ).leaderboard;
    if (leaderboard == null) return 1;

    final tournamentEntries = leaderboard.entries
        .where((entry) => entry.tournamentName == selectedTournament)
        .toList();

    if (tournamentEntries.isEmpty) return 1;

    // Get the latest day
    return tournamentEntries.map((e) => e.day).reduce((a, b) => a > b ? a : b);
  }

  bool _hasMultipleDays(List<LeaderboardEntry> entries) {
    final tournamentEntries = entries
        .where((entry) => entry.tournamentName == selectedTournament)
        .toList();

    if (tournamentEntries.isEmpty) return false;

    final days = tournamentEntries.map((e) => e.day).toSet();
    return days.length > 1;
  }

  List<LeaderboardEntry> _getFilteredEntries(List<LeaderboardEntry> entries) {
    // Filter by tournament
    final tournamentEntries = entries
        .where((entry) => entry.tournamentName == selectedTournament)
        .toList();

    if (tournamentEntries.isEmpty) return [];

    // Get the latest day
    final latestDay = tournamentEntries
        .map((e) => e.day)
        .reduce((a, b) => a > b ? a : b);

    // Get today's entries (latest day)
    final todayEntries = tournamentEntries
        .where((e) => e.day == latestDay)
        .toList();

    // Sort by total score
    todayEntries.sort((a, b) {
      final totalScoreA = _getTotalScoreValue(a);
      final totalScoreB = _getTotalScoreValue(b);
      return totalScoreA.compareTo(totalScoreB);
    });

    return todayEntries;
  }

  String _getTodayScore(LeaderboardEntry entry) {
    return entry.toPar > 0 ? '+${entry.toPar}' : '${entry.toPar}';
  }

  int _getTodayScoreValue(LeaderboardEntry entry) {
    return entry.toPar;
  }

  String _getTotalScore(LeaderboardEntry entry) {
    final totalValue = _getTotalScoreValue(entry);
    return totalValue > 0 ? '+$totalValue' : '$totalValue';
  }

  int _getTotalScoreValue(LeaderboardEntry entry) {
    final leaderboard = Provider.of<FlightScoreProvider>(
      context,
      listen: false,
    ).leaderboard;
    if (leaderboard == null) return entry.toPar;

    // Get all entries for this player in the selected tournament
    final playerEntries = leaderboard.entries
        .where(
          (e) =>
              e.playerId == entry.playerId &&
              e.tournamentName == selectedTournament,
        )
        .toList();

    // Sum up all toPar scores
    return playerEntries.fold(0, (sum, e) => sum + e.toPar);
  }

  Color _getScoreColor(int score) {
    if (score > 0) return Colors.red.shade700;
    if (score < 0) return Colors.green.shade700;
    return Colors.black87;
  }
}
